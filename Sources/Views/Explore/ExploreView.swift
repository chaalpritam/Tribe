import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var app: AppState

    @State private var searchText = ""
    @State private var debouncedQuery = ""
    @State private var debounceTask: Task<Void, Never>?

    @State private var channels: [Channel] = []
    @State private var feedItems: [FeedItem] = []
    @State private var searchUsers: [User] = []
    @State private var searchChannels: [Channel] = []
    @State private var searchTweets: [Tweet] = []
    @State private var loading = true
    @State private var searchLoading = false
    @State private var errorMessage: String?

    private var isSearching: Bool { debouncedQuery.count >= 2 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                searchBar
                if loading, channels.isEmpty, feedItems.isEmpty, !isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                } else if let errorMessage, channels.isEmpty, feedItems.isEmpty {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Theme.error)
                        .padding(.horizontal, 4)
                }

                if isSearching {
                    searchResults
                } else {
                    if !channels.isEmpty {
                        channelSection
                    }
                    discoveryFeed
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
        .task(id: app.currentCity?.id) { await loadDiscovery() }
        .refreshable {
            if isSearching {
                await runSearch()
            } else {
                await loadDiscovery()
            }
        }
        .onChange(of: searchText) { _, new in
            debounceTask?.cancel()
            debounceTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                if Task.isCancelled { return }
                await MainActor.run { debouncedQuery = new.trimmingCharacters(in: .whitespacesAndNewlines) }
            }
        }
        .onChange(of: debouncedQuery) { _, _ in
            if debouncedQuery.count >= 2 {
                Task { await runSearch() }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)
            TextField("Search everything…", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if searchLoading {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var channelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Tribes near you", subtitle: "Interest channels")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(channels.prefix(8)) { channel in
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "number")
                            .font(.title3)
                            .foregroundStyle(Theme.primary)
                        Text(channel.displayName)
                            .font(.subheadline.weight(.bold))
                            .lineLimit(2)
                        Text("\(FormatCount.compact(channel.memberCount)) members")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var discoveryFeed: some View {
        if feedItems.isEmpty, !loading {
            emptyDiscovery
        } else {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Discovery", subtitle: app.currentCity?.displayName ?? "Your city")
                LazyVStack(spacing: 12) {
                    ForEach(feedItems) { item in
                        exploreRow(item)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        if searchLoading, searchUsers.isEmpty, searchChannels.isEmpty, searchTweets.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
        } else if searchUsers.isEmpty, searchChannels.isEmpty, searchTweets.isEmpty {
            Text("No results for \"\(debouncedQuery)\"")
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
        } else {
            if !searchUsers.isEmpty {
                searchSection("People") {
                    ForEach(searchUsers) { user in
                        HStack(spacing: 12) {
                            UserAvatarView(tid: user.tid, initial: user.initial, size: 40, seed: user.username ?? user.tid)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.displayName)
                                    .font(.subheadline.weight(.bold))
                                Text(user.username.map { "@\($0).tribe" } ?? "#\(user.tid)")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                            FollowButton(targetTID: user.tid)
                        }
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            if !searchChannels.isEmpty {
                searchSection("Channels") {
                    ForEach(searchChannels) { channel in
                        Text(channel.displayName)
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            if !searchTweets.isEmpty {
                searchSection("Tweets") {
                    ForEach(searchTweets) { tweet in
                        TweetCardView(tweet: tweet)
                            .environmentObject(app)
                            .environmentObject(app.interactions)
                    }
                }
            }
        }
    }

    private func searchSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline.weight(.bold))
            content()
        }
    }

    @ViewBuilder
    private func exploreRow(_ item: FeedItem) -> some View {
        switch item {
        case .tweet(let tweet):
            TweetCardView(tweet: tweet)
                .environmentObject(app)
                .environmentObject(app.interactions)
        case .event(let event):
            EventCardView(event: event).environmentObject(app)
        case .poll(let poll):
            PollCardView(poll: poll).environmentObject(app)
        case .task(let task):
            TaskCardView(task: task).environmentObject(app)
        case .crowdfund(let crowdfund):
            CrowdfundCardView(crowdfund: crowdfund)
        }
    }

    private var emptyDiscovery: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(Theme.textSecondary.opacity(0.35))
            Text("Nothing to explore yet")
                .font(.headline)
            Text("Posts, polls, and events in \(app.currentCity?.displayName ?? "your city") will show up here.")
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
            Text(subtitle.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func loadDiscovery() async {
        guard let cityId = app.currentCity?.id else { return }
        loading = true
        errorMessage = nil
        defer { loading = false }
        do {
            async let channelsTask = app.api.fetchChannels()
            async let tweetsTask = app.api.fetchChannelFeed(cityId)
            async let eventsTask = app.api.fetchEvents(upcomingOnly: true)
            async let pollsTask = app.api.fetchPolls()
            async let tasksTask = app.api.fetchTasks()
            async let fundsTask = app.api.fetchCrowdfunds()

            let allChannels = try await channelsTask
            channels = allChannels.filter { !$0.isCity && ChannelScope.matches(cityId: cityId, channelId: $0.id) }

            let tweets = try await tweetsTask
            let events = try await eventsTask
            let polls = try await pollsTask
            let tasks = try await tasksTask
            let funds = try await fundsTask

            let tweetItems = tweets
                .filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) }
                .map { FeedItem.tweet($0) }
            let other = FeedMixer.mergeOther(
                events: events.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) },
                polls: polls.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) },
                tasks: tasks.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) },
                crowdfunds: funds.filter { ChannelScope.matches(cityId: cityId, channelId: $0.channelId) }
            )
            feedItems = FeedMixer.interleave(tweets: tweetItems, other: other)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func runSearch() async {
        guard debouncedQuery.count >= 2 else { return }
        searchLoading = true
        defer { searchLoading = false }
        let q = debouncedQuery
        async let users = try? app.api.searchUsers(q)
        async let chans = try? app.api.searchChannels(q)
        async let tweets = try? app.api.searchTweets(q)
        searchUsers = await users ?? []
        searchChannels = await chans ?? []
        searchTweets = await tweets ?? []
    }
}
