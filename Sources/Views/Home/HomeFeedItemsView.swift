import SwiftUI

/// Feed cards driven by a `HomeFeedStore` (used inside `HomeFeedView` and tribe detail).
struct HomeFeedItemsView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var interactions: InteractionCache
    @ObservedObject var store: HomeFeedStore
    var emptySubtitle: String

    var body: some View {
        Group {
            if store.isLoading, store.items.isEmpty {
                ProgressView()
                    .padding(.vertical, 48)
            } else if let error = store.errorMessage, store.items.isEmpty {
                feedEmpty(title: "Couldn't load feed", subtitle: error)
            } else if store.items.isEmpty {
                feedEmpty(title: "Quiet neighborhood…", subtitle: emptySubtitle)
            } else {
                ForEach(store.items) { item in
                    feedRow(item)
                }
            }
        }
    }

    @ViewBuilder
    private func feedRow(_ item: FeedItem) -> some View {
        switch item {
        case .tweet(let tweet):
            TweetCardView(tweet: tweet)
                .environmentObject(app)
                .environmentObject(interactions)
        case .event(let event):
            EventCardView(event: event)
                .environmentObject(app)
        case .poll(let poll):
            PollCardView(poll: poll)
                .environmentObject(app)
        case .task(let task):
            TaskCardView(task: task)
                .environmentObject(app)
        case .crowdfund(let crowdfund):
            CrowdfundCardView(crowdfund: crowdfund)
        }
    }

    private func feedEmpty(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
