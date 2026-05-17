import SwiftUI

struct FollowListView: View {
    enum Mode: String, Identifiable {
        case followers = "Followers"
        case following = "Following"
        var id: String { rawValue }
    }

    @EnvironmentObject private var app: AppState

    let tid: String
    let mode: Mode

    @State private var users: [User] = []
    @State private var loading = true
    @State private var error: String?

    var body: some View {
        Group {
            if loading, users.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error, users.isEmpty {
                EmptyStateView(
                    symbol: "wifi.exclamationmark",
                    title: "Couldn't load \(mode.rawValue.lowercased())",
                    message: error,
                    retryTitle: "Retry",
                    onRetry: { Task { await refresh() } }
                )
            } else if users.isEmpty {
                EmptyStateView(
                    symbol: "person.2",
                    title: mode == .followers ? "No followers yet" : "Not following anyone yet",
                    message: nil
                )
            } else {
                List(users) { user in
                    followRow(user)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(mode.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: mode) { await refresh() }
        .refreshable { await refresh() }
    }

    private func followRow(_ user: User) -> some View {
        HStack(spacing: 12) {
            UserAvatarView(tid: user.tid, initial: user.initial, size: 48, seed: user.username ?? user.tid)
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.subheadline.weight(.bold))
                Text(handle(for: user))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer(minLength: 0)
            FollowButton(targetTID: user.tid)
        }
        .padding(.vertical, 4)
    }

    private func handle(for user: User) -> String {
        if let u = user.username { return "@\(u).tribe" }
        return "@tid\(user.tid)"
    }

    private func refresh() async {
        loading = users.isEmpty
        error = nil
        defer { loading = false }
        do {
            switch mode {
            case .followers:
                users = try await app.api.fetchFollowers(tid)
            case .following:
                users = try await app.api.fetchFollowing(tid)
            }
            for user in users {
                if let raw = user.profile?.pfpUrl,
                   let url = app.api.resolveMediaURL(raw) {
                    app.userAvatars.record(tid: user.tid, pfpUrl: url)
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
