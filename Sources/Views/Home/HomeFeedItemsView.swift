import SwiftUI

/// Feed cards driven by a `HomeFeedStore` (used inside `HomeFeedView` and tribe detail).
struct HomeFeedItemsView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var interactions: InteractionCache
    @ObservedObject var store: HomeFeedStore
    var emptySubtitle: String
    var onLoadMore: (() -> Void)?

    var body: some View {
        Group {
            if store.isLoading, store.items.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 48)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Theme.pageBackground)
            } else if let error = store.errorMessage, store.items.isEmpty {
                EmptyStateView(
                    symbol: "wifi.exclamationmark",
                    title: "Couldn't load feed",
                    message: error,
                    retryTitle: "Retry",
                    onRetry: { Task { await store.refresh() } }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Theme.pageBackground)
            } else if store.items.isEmpty {
                EmptyStateView(
                    symbol: "sparkles",
                    title: "Quiet neighborhood…",
                    message: emptySubtitle
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Theme.pageBackground)
            } else {
                if let error = store.errorMessage {
                    inlineErrorBanner(error)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Theme.pageBackground)
                }
                ForEach(Array(store.items.enumerated()), id: \.element.id) { index, item in
                    feedRow(item)
                        .onAppear {
                            guard index >= store.items.count - 2 else { return }
                            onLoadMore?()
                        }
                }
                loadMoreFooter
                    .listRowSeparator(.hidden)
                    .listRowBackground(Theme.pageBackground)
            }
        }
    }

    @ViewBuilder
    private var loadMoreFooter: some View {
        if store.isLoadingMore {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        } else if store.canLoadMore {
            Text("Scroll for more")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        } else if !store.items.isEmpty, store.feedChannelId == nil {
            Text("End of feed")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
    }

    private func inlineErrorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Text(message)
                .font(.caption)
                .foregroundStyle(Theme.error)
            Spacer()
            Button("Retry") { Task { await store.refresh() } }
                .font(.caption.weight(.semibold))
        }
        .padding(12)
        .background(Theme.error.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private func feedRow(_ item: FeedItem) -> some View {
        switch item {
        case .tweet(let tweet):
            TweetCardView(tweet: tweet)
                .environmentObject(app)
                .environmentObject(interactions)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Theme.pageBackground)
        case .event(let event):
            EventCardView(event: event)
                .environmentObject(app)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Theme.pageBackground)
        case .poll(let poll):
            PollCardView(poll: poll)
                .environmentObject(app)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Theme.pageBackground)
        case .task(let task):
            TaskCardView(task: task)
                .environmentObject(app)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Theme.pageBackground)
        case .crowdfund(let crowdfund):
            CrowdfundCardView(crowdfund: crowdfund)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Theme.pageBackground)
        }
    }
}
