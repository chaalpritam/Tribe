import SwiftUI

struct ChatListView: View {
    @EnvironmentObject private var app: AppState
    @Binding var path: [DMTarget]

    @State private var conversations: [DMConversation] = []
    @State private var groups: [DMGroup] = []
    @State private var loading = true
    @State private var errorMessage: String?
    @State private var showNewMessage = false

    private var isEmpty: Bool { conversations.isEmpty && groups.isEmpty }

    var body: some View {
        Group {
            if loading, isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage, isEmpty {
                VStack(spacing: 8) {
                    Text("Couldn't load messages")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding()
            } else if isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "message")
                        .font(.largeTitle)
                        .foregroundStyle(Theme.textSecondary.opacity(0.35))
                    Text("No conversations yet")
                        .font(.headline)
                    Text("DMs are encrypted with NaCl box. Tap + to start one.")
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                    Button("New message") { showNewMessage = true }
                        .font(.subheadline.weight(.bold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(24)
            } else {
                List {
                    if !groups.isEmpty {
                        Section("Groups") {
                            ForEach(groups) { group in
                                Button {
                                    path.append(.group(group))
                                } label: {
                                    groupRow(group)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    if !conversations.isEmpty {
                        Section(groups.isEmpty ? "" : "Direct messages") {
                            ForEach(conversations) { conversation in
                                Button {
                                    path.append(.oneOnOne(conversation))
                                } label: {
                                    conversationRow(conversation)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
        .overlay(alignment: .bottomTrailing) {
            if !isEmpty {
                Button { showNewMessage = true } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }
                .padding(20)
            }
        }
        .task {
            try? await app.ensureDMKey()
            await refresh()
        }
        .refreshable { await refresh() }
        .sheet(isPresented: $showNewMessage) {
            NewDMSheet {
                showNewMessage = false
                Task { await refresh() }
            }
            .environmentObject(app)
            .presentationCornerRadius(Theme.sheetCornerRadius)
        }
    }

    private func conversationRow(_ conversation: DMConversation) -> some View {
        HStack(spacing: 12) {
            UserAvatarView(
                tid: conversation.peerTid,
                initial: String((conversation.peerUsername ?? conversation.peerTid).prefix(1)),
                size: 48,
                seed: conversation.peerUsername ?? conversation.peerTid
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.peerUsername.map { "@\($0).tribe" } ?? "TID #\(conversation.peerTid)")
                    .font(.subheadline.weight(.bold))
                Text("\(conversation.messageCount) messages")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.primary)
                    .clipShape(Capsule())
            }
            if let last = conversation.lastMessageAt {
                Text(RelativeTime.short(last))
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func groupRow(_ group: DMGroup) -> some View {
        HStack(spacing: 12) {
            AvatarInitial(seed: group.id, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.subheadline.weight(.bold))
                Text("\(group.memberCount) members")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if group.unreadCount > 0 {
                Text("\(group.unreadCount)")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.primary)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }

    private func refresh() async {
        guard let tid = app.myTID else { return }
        loading = isEmpty
        defer { loading = false }
        errorMessage = nil
        do {
            conversations = try await app.api.fetchConversations(tid)
        } catch {
            errorMessage = error.localizedDescription
        }
        groups = (try? await app.api.fetchGroups(tid)) ?? []
    }
}
