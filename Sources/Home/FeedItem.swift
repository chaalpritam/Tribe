import Foundation

enum FeedItem: Identifiable, Hashable {
    case tweet(Tweet)
    case event(Event)
    case poll(Poll)
    case task(TaskItem)
    case crowdfund(Crowdfund)

    var id: String {
        switch self {
        case .tweet(let t): return "tweet-\(t.id)"
        case .event(let e): return "event-\(e.id)"
        case .poll(let p): return "poll-\(p.id)"
        case .task(let t): return "task-\(t.id)"
        case .crowdfund(let c): return "fund-\(c.id)"
        }
    }
}

enum FeedMixer {
    private static let tweetsPerSlot = 2

    /// 2 tweets → 1 other → 2 tweets → 1 other …
    static func interleave(tweets: [FeedItem], other: [FeedItem]) -> [FeedItem] {
        let tweetItems = tweets
        let otherItems = other
        var result: [FeedItem] = []
        var ti = 0
        var oi = 0
        while ti < tweetItems.count || oi < otherItems.count {
            for _ in 0..<tweetsPerSlot where ti < tweetItems.count {
                result.append(tweetItems[ti])
                ti += 1
            }
            if oi < otherItems.count {
                result.append(otherItems[oi])
                oi += 1
            }
        }
        return result
    }

    /// Round-robin event / poll / task / crowdfund buckets.
    static func mergeOther(
        events: [Event],
        polls: [Poll],
        tasks: [TaskItem],
        crowdfunds: [Crowdfund]
    ) -> [FeedItem] {
        var items: [FeedItem] = []
        let maxLen = max(events.count, polls.count, tasks.count, crowdfunds.count)
        for i in 0..<maxLen {
            if i < events.count { items.append(.event(events[i])) }
            if i < polls.count { items.append(.poll(polls[i])) }
            if i < tasks.count { items.append(.task(tasks[i])) }
            if i < crowdfunds.count { items.append(.crowdfund(crowdfunds[i])) }
        }
        return items
    }
}

enum ChannelScope {
    static func matches(cityId: String, channelId: String?) -> Bool {
        guard let channelId, !channelId.isEmpty else { return true }
        return channelId == cityId || channelId == "general"
    }
}
