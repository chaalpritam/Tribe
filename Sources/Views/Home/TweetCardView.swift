import SwiftUI

struct TweetCardView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var interactions: InteractionCache
    @EnvironmentObject private var toasts: ToastCenter

    let tweet: Tweet

    @State private var pending = false
    @State private var actionError: String?

    private var liked: Bool { interactions.contains(liked: tweet.hash) }
    private var bookmarked: Bool { interactions.contains(bookmarked: tweet.hash) }
    private var retweeted: Bool { interactions.contains(retweeted: tweet.hash) }

    private var displayName: String {
        if let u = tweet.username { return u }
        return "TID #\(tweet.tid)"
    }

    private var handle: String {
        if let u = tweet.username { return "@\(u).tribe" }
        return "@tid\(tweet.tid)"
    }

    var body: some View {
        FeedCardChrome {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    UserAvatarView(
                        tid: tweet.tid,
                        initial: String((tweet.username ?? tweet.tid).prefix(1)),
                        size: 44,
                        seed: tweet.username ?? tweet.tid
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(displayName)
                                .font(.subheadline.weight(.bold))
                            Text(handle)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                            Text("·")
                                .foregroundStyle(Theme.textSecondary)
                            Text(RelativeTime.short(tweet.timestamp))
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        if let text = tweet.text, !text.isEmpty {
                            Text(text)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                TweetMediaPreview(tweet: tweet)
                if let actionError {
                    Text(actionError)
                        .font(.caption)
                        .foregroundStyle(Theme.error)
                }
                actionRow
            }
        }
        .task { await interactions.ensureLoaded() }
    }

    private var actionRow: some View {
        HStack {
            actionButton("bubble.left", count: tweet.replyCount) {}
            Spacer()
            actionButton(retweeted ? "arrow.2.squarepath" : "arrow.2.squarepath", active: retweeted, tint: Theme.success) {
                Task { await toggleRetweet() }
            }
            Spacer()
            actionButton(liked ? "heart.fill" : "heart", active: liked, tint: Theme.error) {
                Task { await toggleLike() }
            }
            Spacer()
            actionButton(bookmarked ? "bookmark.fill" : "bookmark", active: bookmarked, tint: Theme.primary) {
                Task { await toggleBookmark() }
            }
        }
        .foregroundStyle(Theme.textSecondary)
    }

    private func actionButton(
        _ symbol: String,
        count: Int? = nil,
        active: Bool = false,
        tint: Color = Theme.textSecondary,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.subheadline.weight(active ? .semibold : .regular))
                if let count, count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .monospacedDigit()
                }
            }
            .foregroundStyle(active ? tint : Theme.textSecondary)
        }
        .buttonStyle(.plain)
        .disabled(pending || app.appKey == nil)
    }

    private func toggleLike() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        let was = liked
        interactions.setLiked(!was, hash: tweet.hash)
        pending = true
        defer { pending = false }
        do {
            if was {
                try await app.api.unlikeTweet(hash: tweet.hash, as: key, tid: tid)
            } else {
                try await app.api.likeTweet(hash: tweet.hash, as: key, tid: tid)
            }
            actionError = nil
        } catch {
            interactions.setLiked(was, hash: tweet.hash)
            actionError = error.localizedDescription
            toasts.show(error.localizedDescription)
        }
    }

    private func toggleRetweet() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        let was = retweeted
        interactions.setRetweeted(!was, hash: tweet.hash)
        pending = true
        defer { pending = false }
        do {
            if was {
                try await app.api.unretweet(hash: tweet.hash, as: key, tid: tid)
            } else {
                try await app.api.retweet(hash: tweet.hash, as: key, tid: tid)
            }
            actionError = nil
        } catch {
            interactions.setRetweeted(was, hash: tweet.hash)
            actionError = error.localizedDescription
            toasts.show(error.localizedDescription)
        }
    }

    private func toggleBookmark() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        let was = bookmarked
        interactions.setBookmarked(!was, hash: tweet.hash)
        pending = true
        defer { pending = false }
        do {
            try await app.api.bookmark(hash: tweet.hash, as: key, tid: tid, add: !was)
            actionError = nil
        } catch {
            interactions.setBookmarked(was, hash: tweet.hash)
            actionError = error.localizedDescription
            toasts.show(error.localizedDescription)
        }
    }
}
