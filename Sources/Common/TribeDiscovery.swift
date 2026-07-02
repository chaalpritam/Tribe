import Foundation

/// Joined vs discoverable tribe lists for Explore and Tribes surfaces.
enum TribeDiscovery {
    /// Tribes the user has joined, or the single tribe when browsing a sub-channel.
    @MainActor
    static func joinedTribes(app: AppState, activeChannel: Channel?) -> [Channel] {
        if let active = activeChannel, !active.isCity {
            return [active]
        }
        return app.joinedChannels.filter { !$0.isCity }
    }

    /// Non-city channels on the hub the user has not joined yet. Only shown at city scope.
    @MainActor
    static func discoverTribes(
        allChannels: [Channel],
        app: AppState,
        activeChannel: Channel?
    ) -> [Channel] {
        guard activeChannel?.isCity == true else { return [] }
        return allChannels
            .filter { !$0.isCity && !app.isJoined(channelId: $0.id) }
            .sorted { $0.memberCount > $1.memberCount }
    }
}
