import SwiftUI

/// Read-only follow state from the ER sequencer. Tapping opens guidance
/// to follow/unfollow on tribe-app (custody-key signature required).
struct FollowButton: View {
    @EnvironmentObject private var app: AppState

    let targetTID: String

    @State private var status: ERLinkStatus?
    @State private var loading = false
    @State private var explaining = false

    private var isMe: Bool { targetTID == app.myTID }
    private var following: Bool { status?.isFollowing == true }
    private var pending: Bool { status?.isPending == true || status?.isPendingUnfollow == true }

    var body: some View {
        if isMe {
            EmptyView()
        } else {
            Button {
                explaining = true
            } label: {
                HStack(spacing: 6) {
                    if loading {
                        ProgressView().controlSize(.mini)
                    } else if pending {
                        Image(systemName: "clock")
                    } else if following {
                        Image(systemName: "checkmark")
                    } else {
                        Image(systemName: "plus")
                    }
                    Text(label)
                        .font(.caption.weight(.semibold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .foregroundStyle(following ? Theme.primary : .white)
                .background(
                    Capsule().fill(following ? Theme.primary.opacity(0.12) : Color.clear)
                )
                .background(
                    following ? nil : Capsule().fill(Theme.brandGradient)
                )
                .overlay(
                    Capsule().stroke(following ? Theme.primary.opacity(0.25) : Color.clear, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
            .task(id: targetTID) { await refresh() }
            .task(id: pollKey) { await pollWhileSettling() }
            .sheet(isPresented: $explaining) {
                FollowExplainerSheet(following: following, pending: pending)
                    .presentationDetents([.medium])
            }
        }
    }

    private var pollKey: String {
        "\(targetTID)-\(status?.status ?? "unknown")"
    }

    private var label: String {
        if status?.isPendingUnfollow == true { return "Pending" }
        if status?.isPending == true { return "Settling" }
        if following { return "Following" }
        return "Follow"
    }

    @MainActor
    private func refresh() async {
        guard let me = app.myTID, !isMe else { return }
        loading = status == nil
        defer { loading = false }
        status = (try? await app.er.link(followerTID: me, followingTID: targetTID))
    }

    /// Poll ER while a follow/unfollow is settling to L1 (~10s batches).
    @MainActor
    private func pollWhileSettling() async {
        guard pending else { return }
        for _ in 0..<20 {
            try? await Task.sleep(for: .seconds(2))
            if Task.isCancelled { return }
            await refresh()
            if !pending { return }
        }
    }
}

private struct FollowExplainerSheet: View {
    let following: Bool
    let pending: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Theme.primary)
                    .padding(.top, 24)

                Text(title)
                    .font(.title3.bold())

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                Button("Got it") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.primary)
                    .controlSize(.large)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
    }

    private var title: String {
        if pending { return "Settling on Solana" }
        if following { return "Unfollow on tribe-app" }
        return "Follow on tribe-app"
    }

    private var message: String {
        if pending {
            return "The ER sequencer accepted your follow change and is batching it to L1. This button updates automatically when settlement completes — usually within a few seconds."
        }
        if following {
            return "Unfollows must be signed by your Solana custody key. Open tribe-app on web, find this profile, and tap Unfollow. Status here updates as soon as the ER confirms."
        }
        return "Follows are written to the ER with a custody-key signature. This app uses your AppKey for posts and reactions; open tribe-app on web to follow. ER reflects the change in ~50 ms once submitted."
    }
}
