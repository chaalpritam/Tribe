import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var interactions: InteractionCache
    @StateObject private var store = HomeFeedStore()

    /// When set, scopes the feed to one channel (tribe detail).
    var channelId: String? = nil

    var body: some View {
        Group {
            if store.isLoading, store.items.isEmpty {
                List {
                    ForEach(0..<5, id: \.self) { _ in
                        TweetSkeletonRow()
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.systemBackground))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            } else {
                List {
                    HomeFeedItemsView(
                        store: store,
                        emptySubtitle: emptySubtitle,
                        onLoadMore: channelId == nil ? { Task { await store.loadMore() } } : nil
                    )
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await store.refresh()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
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

private struct TweetSkeletonRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(Color(.tertiarySystemFill)).frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6).fill(Color(.tertiarySystemFill)).frame(width: 140, height: 11)
                RoundedRectangle(cornerRadius: 6).fill(Color(.tertiarySystemFill)).frame(maxWidth: .infinity).frame(height: 11)
                RoundedRectangle(cornerRadius: 6).fill(Color(.tertiarySystemFill)).frame(width: 220, height: 11)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.cardStroke.opacity(0.4))
                .frame(height: 0.5)
        }
        .redacted(reason: .placeholder)
    }
}
