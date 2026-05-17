import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var interactions: InteractionCache
    @StateObject private var store = HomeFeedStore()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if store.isLoading, store.items.isEmpty {
                    ProgressView()
                        .padding(.vertical, 48)
                } else if let error = store.errorMessage, store.items.isEmpty {
                    emptyState(title: "Couldn't load feed", subtitle: error)
                } else if store.items.isEmpty {
                    emptyState(
                        title: "Quiet neighborhood…",
                        subtitle: "Be the first to share something in \(app.currentCity?.displayName ?? "your city")!"
                    )
                } else {
                    ForEach(store.items) { item in
                        feedRow(item)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
        .refreshable {
            await store.refresh()
        }
        .task(id: app.currentCity?.id) {
            store.attach(app: app)
            await store.refresh()
        }
        .onDisappear {
            store.detach()
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

    private func emptyState(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 64)
    }
}
