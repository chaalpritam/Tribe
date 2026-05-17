import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var interactions: InteractionCache
    @StateObject private var store = HomeFeedStore()

    /// When set, scopes the feed to one channel (tribe detail).
    var channelId: String? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                HomeFeedItemsView(
                    store: store,
                    emptySubtitle: emptySubtitle,
                    onLoadMore: channelId == nil ? { Task { await store.loadMore() } } : nil
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
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
