import Foundation

/// How hub content is matched to the channel the user is browsing.
enum ChannelScope {
    /// Strict match — only posts tagged to this exact channel id.
    static func matchesExact(scopeId: String, channelId: String?) -> Bool {
        guard let channelId, !channelId.isEmpty else { return false }
        return channelId == scopeId
    }

    /// Legacy city home mix: channel posts plus the shared `general` bucket
    /// and untagged posts. Prefer `matchesExact` for channel-specific surfaces.
    static func matches(cityId: String, channelId: String?) -> Bool {
        guard let channelId, !channelId.isEmpty else { return true }
        return channelId == cityId || channelId == "general"
    }
}
