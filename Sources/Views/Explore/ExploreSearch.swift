import Foundation

/// Grouped hub search hits for Explore, scoped to the active channel.
struct ExploreSearchResults: Equatable {
    var users: [User] = []
    var channels: [Channel] = []
    var tweets: [Tweet] = []
    var polls: [Poll] = []
    var events: [Event] = []
    var tasks: [TaskItem] = []
    var crowdfunds: [Crowdfund] = []

    var isEmpty: Bool {
        users.isEmpty && channels.isEmpty && tweets.isEmpty && polls.isEmpty
            && events.isEmpty && tasks.isEmpty && crowdfunds.isEmpty
    }

    var totalCount: Int {
        users.count + channels.count + tweets.count + polls.count
            + events.count + tasks.count + crowdfunds.count
    }
}

enum ExploreSearch {
    /// Minimum query length before hitting the hub.
    static let minQueryLength = 2

    @MainActor
    static func run(query: String, activeChannel: Channel?, api: HubClient) async -> ExploreSearchResults {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard q.count >= minQueryLength else { return ExploreSearchResults() }

        async let usersTask = (try? await api.searchUsers(q)) ?? []
        async let channelsTask = (try? await api.searchChannels(q)) ?? []
        async let tweetsTask = (try? await api.searchTweets(q)) ?? []
        async let pollsTask = (try? await api.searchPolls(q)) ?? []
        async let eventsTask = (try? await api.searchEvents(q)) ?? []
        async let tasksTask = (try? await api.searchTasks(q)) ?? []
        async let fundsTask = (try? await api.searchCrowdfunds(q)) ?? []

        return scoped(
            ExploreSearchResults(
                users: await usersTask,
                channels: await channelsTask,
                tweets: await tweetsTask,
                polls: await pollsTask,
                events: await eventsTask,
                tasks: await tasksTask,
                crowdfunds: await fundsTask
            ),
            activeChannel: activeChannel
        )
    }

    static func scoped(_ results: ExploreSearchResults, activeChannel: Channel?) -> ExploreSearchResults {
        guard let active = activeChannel else { return ExploreSearchResults() }
        let scopeId = active.id

        let matchesChannel = { (id: String?) in
            ChannelScope.matchesExact(scopeId: scopeId, channelId: id)
        }

        let channels = results.channels.filter { channel in
            if channel.id == scopeId { return true }
            if active.isCity { return !channel.isCity }
            return false
        }

        return ExploreSearchResults(
            users: results.users,
            channels: channels,
            tweets: results.tweets.filter { matchesChannel($0.channelId) },
            polls: results.polls.filter { matchesChannel($0.channelId) },
            events: results.events.filter { matchesChannel($0.channelId) },
            tasks: results.tasks.filter { matchesChannel($0.channelId) },
            crowdfunds: results.crowdfunds.filter { matchesChannel($0.channelId) }
        )
    }
}
