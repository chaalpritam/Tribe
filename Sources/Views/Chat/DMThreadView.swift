import SwiftUI
import TribeCore

struct DMThreadView: View {
    @EnvironmentObject private var app: AppState

    let target: DMTarget

    @State private var messages: [DMMessage] = []
    @State private var rendered: [String: String] = [:]
    @State private var draft = ""
    @State private var loading = true
    @State private var sending = false
    @State private var errorMessage: String?
    @State private var recipientPub: Data?

    private var isGroup: Bool {
        if case .group = target { return true }
        return false
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if loading, messages.isEmpty {
                            ProgressView()
                                .padding(.vertical, 48)
                        }
                        ForEach(messages) { message in
                            messageBubble(message)
                                .id(message.hash)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.hash, anchor: .bottom) }
                    }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Theme.error)
                    .padding(.horizontal, 16)
            }

            if !isGroup {
                composer
            } else {
                Text("Group replies ship in a follow-up — read-only for now.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.96))
            }
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
        .navigationTitle(target.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            _ = try? await app.ensureDMKey()
            if case .oneOnOne(let conv) = target {
                recipientPub = try? await app.api.fetchDMPublicKey(conv.peerTid)
            }
            await refresh()
        }
        .refreshable { await refresh() }
    }

    private func messageBubble(_ message: DMMessage) -> some View {
        let isOwn = message.senderTid == app.myTID
        let text = rendered[message.hash] ?? "…"
        return HStack {
            if isOwn { Spacer(minLength: 48) }
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.body)
                    .foregroundStyle(isOwn ? .white : Theme.textPrimary)
                Text(RelativeTime.short(message.timestamp))
                    .font(.caption2)
                    .foregroundStyle(isOwn ? .white.opacity(0.75) : Theme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isOwn ? Color.black : Color(white: 0.94))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            if !isOwn { Spacer(minLength: 48) }
        }
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message", text: $draft, axis: .vertical)
                .lineLimit(1 ... 4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(white: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Button {
                Task { await send() }
            } label: {
                Image(systemName: sending ? "ellipsis" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(canSend ? Theme.primary : Theme.textSecondary)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !sending
            && app.appKey != nil
            && app.myTID != nil
            && app.dmKey != nil
            && recipientPub != nil
    }

    private func refresh() async {
        guard let tid = app.myTID else { return }
        loading = messages.isEmpty
        defer { loading = false }
        errorMessage = nil
        do {
            switch target {
            case .oneOnOne(let conv):
                messages = try await app.api.fetchDMMessages(conversationId: conv.id, tid: tid)
                await decryptMissing()
                await markRead(tid: tid, conversationId: conv.id)
            case .group(let group):
                messages = try await app.api.fetchGroupMessages(groupId: group.id, tid: tid)
                await decryptMissing()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func decryptMissing() async {
        let dm: DMKey
        if let existing = app.dmKey {
            dm = existing
        } else if let fetched = try? await app.ensureDMKey() {
            dm = fetched
        } else {
            return
        }
        for msg in messages where rendered[msg.hash] == nil {
            guard let cipher = Data(base64Encoded: msg.ciphertext),
                  let nonce = Data(base64Encoded: msg.nonce) else {
                rendered[msg.hash] = "[malformed]"
                continue
            }
            let isOwn = msg.senderTid == app.myTID
            if isOwn, case .oneOnOne = target {
                guard let peerPub = recipientPub else {
                    rendered[msg.hash] = "[no peer key]"
                    continue
                }
                if let pt = try? NaClBox.boxOpen(cipher, nonce: nonce, senderPublicKey: peerPub, recipientPrivateKey: dm.privateKey) {
                    rendered[msg.hash] = String(data: pt, encoding: .utf8) ?? "[non-utf8]"
                } else {
                    rendered[msg.hash] = "[unable to decrypt]"
                }
                continue
            }
            guard let pubB64 = msg.senderX25519 ?? (isOwn ? dm.publicKey.base64EncodedString() : nil),
                  let senderPub = Data(base64Encoded: pubB64) else {
                rendered[msg.hash] = "[no sender key]"
                continue
            }
            if let pt = try? NaClBox.boxOpen(cipher, nonce: nonce, senderPublicKey: senderPub, recipientPrivateKey: dm.privateKey) {
                rendered[msg.hash] = String(data: pt, encoding: .utf8) ?? "[non-utf8]"
            } else {
                rendered[msg.hash] = "[unable to decrypt]"
            }
        }
    }

    private func send() async {
        guard case .oneOnOne(let conv) = target else { return }
        guard let key = app.appKey, let tid = app.myTID, let dm = app.dmKey, let peerPub = recipientPub else { return }
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        sending = true
        errorMessage = nil
        defer { sending = false }
        do {
            let plaintext = Data(trimmed.utf8)
            let nonce = NaClBox.randomNonce()
            let cipher = try NaClBox.box(
                plaintext,
                nonce: nonce,
                recipientPublicKey: peerPub,
                senderPrivateKey: dm.privateKey
            )
            _ = try await app.api.sendDM(
                recipientTID: conv.peerTid,
                ciphertext: cipher,
                nonce: nonce,
                senderX25519: dm.publicKey,
                as: key,
                tid: tid
            )
            draft = ""
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func markRead(tid: String, conversationId: String) async {
        guard let key = app.appKey, let last = messages.last else { return }
        _ = try? await app.api.markDMRead(
            conversationId: conversationId,
            lastReadHash: last.hash,
            as: key,
            tid: tid
        )
    }
}
