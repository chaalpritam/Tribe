import SwiftUI

/// Read-only profile for another user, scoped to the active channel feed.
struct UserProfileView: View {
    @EnvironmentObject private var app: AppState

    let tid: String

    @State private var user: User?
    @State private var tweets: [Tweet] = []
    @State private var loading = true
    @State private var followListMode: FollowListView.Mode?

    private var handle: String {
        if let u = user?.username { return "@\(u).tribe" }
        return "@tid\(tid)"
    }

    var body: some View {
        Group {
            if loading, user == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let user {
                List {
                    header(user)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                    if tweets.isEmpty {
                        EmptyStateView(
                            symbol: "text.bubble",
                            title: "No posts in this channel",
                            message: "\(user.displayName) hasn't posted in \(app.activeChannel?.displayName ?? "this channel") yet."
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(tweets) { tweet in
                            TweetCardView(tweet: tweet)
                                .environmentObject(app)
                                .environmentObject(app.interactions)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color(.systemBackground))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Theme.pageBackground)
            } else {
                EmptyStateView(
                    symbol: "person.crop.circle.badge.questionmark",
                    title: "Profile unavailable",
                    message: "Couldn't load this user from the hub.",
                    retryTitle: "Retry",
                    onRetry: { Task { await refresh() } }
                )
            }
        }
        .navigationTitle(user?.displayName ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await refresh() }
        .task(id: "\(tid)-\(app.activeChannel?.id ?? "")") { await refresh() }
        .sheet(item: $followListMode) { mode in
            NavigationStack {
                FollowListView(tid: tid, mode: mode)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { followListMode = nil }
                        }
                    }
            }
            .environmentObject(app)
        }
    }

    private func header(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Theme.avatarGradient(seed: user.username ?? tid)
                .frame(height: 120)

            HStack(alignment: .bottom) {
                UserAvatarView(
                    tid: tid,
                    initial: user.initial,
                    size: 80,
                    seed: user.username ?? tid
                )
                .overlay(Circle().strokeBorder(Color(.systemBackground), lineWidth: 4))
                .offset(y: -40)
                .padding(.leading, 16)
                .padding(.bottom, -40)

                Spacer()

                FollowButton(targetTID: tid)
                    .padding(.trailing, 16)
                    .padding(.top, 12)
            }

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.title2.weight(.bold))
                        .lineLimit(1)
                    Text(handle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let bio = user.profile?.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 20) {
                    Button { followListMode = .following } label: {
                        stat(value: user.followingCount, label: "Following")
                    }
                    .buttonStyle(.plain)

                    Button { followListMode = .followers } label: {
                        stat(value: user.followersCount, label: "Followers")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
    }

    private func stat(value: Int, label: String) -> some View {
        HStack(spacing: 4) {
            Text(FormatCount.compact(value))
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @MainActor
    private func refresh() async {
        loading = user == nil
        defer { loading = false }

        user = try? await app.api.fetchUser(tid)
        let allTweets = (try? await app.api.fetchFeed(tid: tid)) ?? []
        if let scopeId = app.activeChannel?.id {
            tweets = allTweets.filter {
                ChannelScope.matchesExact(scopeId: scopeId, channelId: $0.channelId)
            }
        } else {
            tweets = []
        }

        if let user, let raw = user.profile?.pfpUrl, let url = app.api.resolveMediaURL(raw) {
            app.userAvatars.record(tid: tid, pfpUrl: url)
        }
    }
}
