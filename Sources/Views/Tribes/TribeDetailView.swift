import SwiftUI

struct TribeDetailView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var interactions: InteractionCache

    let channel: Channel

    @StateObject private var store = HomeFeedStore()
    @State private var isTogglingMembership = false
    @State private var membershipError: String?

    private var isJoined: Bool {
        app.isJoined(channelId: channel.id)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                heroCard
                if let membershipError {
                    Text(membershipError)
                        .font(.footnote)
                        .foregroundStyle(Theme.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                HomeFeedItemsView(
                    store: store,
                    emptySubtitle: "Be the first to post in \(channel.displayName)."
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
        .task(id: channel.id) {
            store.feedChannelId = channel.id
            store.attach(app: app)
            await store.refresh()
        }
        .onDisappear {
            store.detach()
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(channel.displayName)
                .font(.system(size: 28, weight: .black))
                .tracking(-0.5)

            HStack(spacing: 8) {
                Text("\(FormatCount.compact(channel.memberCount)) Members")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.96))
                    .clipShape(Capsule())
                Text("#\(channel.id)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.textSecondary)
                    .textCase(.uppercase)
            }

            if let description = channel.description, !description.isEmpty {
                Text(description)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color(white: 0.27))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: toggleMembership) {
                Group {
                    if isTogglingMembership {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isJoined ? "Leave tribe" : "Join tribe")
                            .font(.subheadline.weight(.bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isJoined ? Color(white: 0.94) : Color.black)
                .foregroundStyle(isJoined ? Color.red : .white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isTogglingMembership)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func toggleMembership() {
        guard !isTogglingMembership else { return }
        isTogglingMembership = true
        membershipError = nil
        Task {
            defer { isTogglingMembership = false }
            do {
                if isJoined {
                    try await app.leaveChannel(channel)
                } else {
                    try await app.joinChannel(channel)
                }
            } catch {
                membershipError = error.localizedDescription
            }
        }
    }
}
