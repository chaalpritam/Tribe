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
                ContentUnavailableView {
                    Label("Couldn't Load Messages", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                }
            } else if isEmpty {
                ContentUnavailableView {
                    Label("No Conversations", systemImage: "message")
                } description: {
                    Text("DMs are encrypted with NaCl box. Start a new message to chat.")
                } actions: {
                    Button("New Message") { showNewMessage = true }
                        .buttonStyle(.borderedProminent)
                }
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
                            }
                        }
                    }
                    if !conversations.isEmpty {
                        Section(groups.isEmpty ? "" : "Direct Messages") {
                            ForEach(conversations) { conversation in
                                Button {
                                    path.append(.oneOnOne(conversation))
                                } label: {
                                    conversationRow(conversation)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Theme.pageBackground)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewMessage = true
                } label: {
                    Label("New Message", systemImage: "square.and.pencil")
                }
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
                    .font(.body.weight(.semibold))
                Text("\(conversation.messageCount) messages")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Theme.primary, in: Capsule())
            }
            if let last = conversation.lastMessageAt {
                Text(RelativeTime.short(last))
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private func groupRow(_ group: DMGroup) -> some View {
        HStack(spacing: 12) {
            AvatarInitial(seed: group.id, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.body.weight(.semibold))
                Text("\(group.memberCount) members")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if group.unreadCount > 0 {
                Text("\(group.unreadCount)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Theme.primary, in: Capsule())
            }
        }
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
