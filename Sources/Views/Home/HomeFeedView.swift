import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var interactions: InteractionCache
    @StateObject private var store = HomeFeedStore()

    /// When set, scopes the feed to one channel (tribe detail).
    var channelId: String? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                HomeFeedItemsView(
                    store: store,
                    emptySubtitle: emptySubtitle,
                    onLoadMore: channelId == nil ? { Task { await store.loadMore() } } : nil
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Theme.pageBackground)
        .refreshable {
            await store.refresh()
        }
        .task(id: channelId ?? app.currentCity?.id) {
            store.feedChannelId = channelId
            store.attach(app: app)
            await store.refresh()
        }
        .onDisappear {
            store.detach()
        }
    }

    private var emptySubtitle: String {
        if let channelId {
            return "Be the first to post in #\(channelId)."
        }
        return "Be the first to share something in \(app.currentCity?.displayName ?? "your city")!"
    }
}
