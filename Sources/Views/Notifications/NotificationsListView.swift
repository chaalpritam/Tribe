import SwiftUI

struct NotificationsListView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        Group {
            if app.notifications.isLoading, app.notifications.items.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = app.notifications.errorMessage, app.notifications.items.isEmpty {
                VStack(spacing: 8) {
                    Text("Couldn't load notifications")
                        .font(.headline)
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding()
            } else if app.notifications.items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bell")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    Text("All caught up")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(app.notifications.items) { notification in
                            notificationRow(notification)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
        .safeAreaInset(edge: .top) {
            if app.notifications.unreadCount > 0 {
                HStack {
                    Text("Recent")
                        .font(.headline.weight(.bold))
                    Spacer()
                    Button("Mark all read") {
                        app.notifications.markAllRead()
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
        }
        .task { await app.notifications.refreshList() }
        .refreshable { await app.notifications.refreshList() }
    }

    private func notificationRow(_ notification: TribeNotification) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                UserAvatarView(
                    tid: notification.actorTid,
                    initial: String((notification.actorUsername ?? notification.actorTid).prefix(1)),
                    size: 48,
                    seed: notification.actorUsername ?? notification.actorTid
                )
                Image(systemName: notification.type.symbol)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(notificationTint(notification.type))
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }
            VStack(alignment: .leading, spacing: 4) {
                (Text(actorLabel(notification)).font(.subheadline.weight(.bold))
                    + Text(" \(notification.type.label)").font(.subheadline).foregroundStyle(Theme.textSecondary))
                if let preview = notification.preview, !preview.isEmpty {
                    Text("\"\(preview.prefix(80))\"")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }
                Text(RelativeTime.short(notification.createdAt))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Theme.textSecondary)
                    .textCase(.uppercase)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func actorLabel(_ notification: TribeNotification) -> String {
        if let u = notification.actorUsername { return "@\(u).tribe" }
        return "#\(notification.actorTid)"
    }

    private func notificationTint(_ type: NotificationType) -> Color {
        switch type {
        case .follow: return .indigo
        case .reaction, .reply: return Theme.error
        case .tip: return .orange
        case .mention: return Theme.primary
        case .pollVote: return .blue
        case .eventRsvp: return Theme.success
        case .taskClaim, .taskComplete: return .teal
        case .crowdfundPledge: return .purple
        }
    }
}
