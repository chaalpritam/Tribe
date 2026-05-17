import Foundation

@MainActor
final class HomeFeedStore: ObservableObject {
    @Published private(set) var items: [FeedItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var canLoadMore = false
    @Published var errorMessage: String?

    /// When set, loads a single channel feed instead of the current city home mix.
    var feedChannelId: String?

    private var nextCursor: String?
    private var cachedOther: [FeedItem] = []
    private var realtimeToken: UUID?
    private weak var app: AppState?

    func attach(app: AppState) {
        self.app = app
        HubRealtime.shared.setHubURL(app.hubBaseURL)
        if realtimeToken == nil {
            realtimeToken = HubRealtime.shared.subscribe { [weak self] event in
                Task { @MainActor in
                    await self?.handleRealtime(event)
                }
            }
        }
    }

    func detach() {
        if let realtimeToken {
            HubRealtime.shared.unsubscribe(realtimeToken)
            self.realtimeToken = nil
        }
    }

    func refresh() async {
        if let channelId = feedChannelId {
            await refresh(channelId: channelId)
        } else {
            await refresh(cityScope: app?.currentCity?.id)
        }
    }

    func loadMore() async {
        guard feedChannelId == nil,
              let cursor = nextCursor,
              !isLoadingMore,
              !isLoading else { return }
        guard let app, let cityId = app.currentCity?.id else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let page = try await app.api.fetchFeedPage(cursor: cursor)
            let fresh = page.tweets.filter {
                ChannelScope.matches(cityId: cityId, channelId: $0.channelId)
            }
            let existingHashes = Set(items.compactMap { item -> String? in
                if case .tweet(let t) = item { return t.hash }
                return nil
            })
            let newTweets = fresh.filter { !existingHashes.contains($0.hash) }
            let tweetItems = collectTweetItems(from: items) + newTweets.map { FeedItem.tweet($0) }
            nextCursor = page.cursor
            canLoadMore = page.cursor != nil
            items = FeedMixer.interleave(tweets: tweetItems, other: cachedOther)
            await app.interactions.ensureLoaded()
        } catch {
            app.toasts.show("Couldn't load more: \(error.localizedDescription)")
        }
    }

    func refresh(channelId: String) async {
        guard let app else { return }
        isLoading = true
        errorMessage = nil
        canLoadMore = false
        nextCursor = nil
        defer { isLoading = false }
        do {
            async let tweetsTask = app.api.fetchChannelFeed(channelId)
            async let eventsTask = app.api.fetchEvents(upcomingOnly: true)
            async let pollsTask = app.api.fetchPolls()
            async let tasksTask = app.api.fetchTasks()
            async let fundsTask = app.api.fetchCrowdfunds()

            let tweets = try await tweetsTask
            let events = try await eventsTask
            let polls = try await pollsTask
            let tasks = try await tasksTask
            let funds = try await fundsTask

            let matches = { (id: String?) in id == channelId }
            let tweetItems = tweets.map { FeedItem.tweet($0) }
            cachedOther = FeedMixer.mergeOther(
                events: events.filter { matches($0.channelId) },
                polls: polls.filter { matches($0.channelId) },
                tasks: tasks.filter { matches($0.channelId) },
                crowdfunds: funds.filter { matches($0.channelId) }
            )
            items = FeedMixer.interleave(tweets: tweetItems, other: cachedOther)
            await app.interactions.ensureLoaded()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refresh(cityScope cityId: String?) async {
        guard let app, let cityId else {
            items = []
            errorMessage = "No city selected."
            canLoadMore = false
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let pageTask = app.api.fetchFeedPage(cursor: nil)
            async let eventsTask = app.api.fetchEvents(upcomingOnly: true)
            async let pollsTask = app.api.fetchPolls()
            async let tasksTask = app.api.fetchTasks()
            async let fundsTask = app.api.fetchCrowdfunds()

            let page = try await pageTask
            let events = try await eventsTask
            let polls = try await pollsTask
            let tasks = try await tasksTask
            let funds = try await fundsTask

            let tweetItems = page.tweets
                .filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) }
                .map { FeedItem.tweet($0) }
            cachedOther = FeedMixer.mergeOther(
                events: events.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) },
                polls: polls.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) },
                tasks: tasks.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) },
                crowdfunds: funds.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) }
            )
            nextCursor = page.cursor
            canLoadMore = page.cursor != nil
            items = FeedMixer.interleave(tweets: tweetItems, other: cachedOther)
            await app.interactions.ensureLoaded()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleRealtime(_ event: HubRealtime.Event) async {
        guard event.name == "new_message" else { return }
        guard let app else { return }
        guard let type = jsonInt(event.data["type"]), type == 1 else { return }
        guard let hash = event.data["hash"] as? String else { return }
        do {
            let tweet = try await app.api.fetchTweet(hash: hash)
            if let channelId = feedChannelId {
                guard tweet.channelId == channelId || tweet.channelId == nil else { return }
            } else if let cityId = app.currentCity?.id {
                guard ChannelScope.matches(cityId: cityId, channelId: tweet.channelId) else { return }
            } else {
                return
            }
            prependTweet(tweet)
        } catch {
            await refresh()
        }
    }

    private func jsonInt(_ value: Any?) -> Int? {
        if let i = value as? Int { return i }
        if let d = value as? Double { return Int(d) }
        if let n = value as? NSNumber { return n.intValue }
        return nil
    }

    private func prependTweet(_ tweet: Tweet) {
        let newItem = FeedItem.tweet(tweet)
        guard !items.contains(where: { $0.id == newItem.id }) else { return }
        if let firstTweetIndex = items.firstIndex(where: {
            if case .tweet = $0 { return true }
            return false
        }) {
            items.insert(newItem, at: firstTweetIndex)
        } else {
            items.insert(newItem, at: 0)
        }
    }

    private func collectTweetItems(from items: [FeedItem]) -> [FeedItem] {
        items.compactMap { item in
            if case .tweet = item { return item }
            return nil
        }
    }
}
