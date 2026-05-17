import SwiftUI
import TribeCore

struct NewDMSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var onSent: () -> Void

    @State private var peerTID = ""
    @State private var draft = ""
    @State private var sending = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipient TID") {
                    TextField("e.g. 42", text: $peerTID)
                        .keyboardType(.numberPad)
                }
                Section("Message") {
                    TextField("Say hello…", text: $draft, axis: .vertical)
                        .lineLimit(3 ... 6)
                }
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(Theme.error)
                            .font(.footnote)
                    }
                }
                Section {
                    Button(sending ? "Sending…" : "Send encrypted message") {
                        Task { await send() }
                    }
                    .disabled(!canSend)
                }
            }
            .navigationTitle("New message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var canSend: Bool {
        !peerTID.trimmingCharacters(in: .whitespaces).isEmpty
            && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !sending
            && app.appKey != nil
            && app.myTID != nil
    }

    private func send() async {
        guard let key = app.appKey, let tid = app.myTID else { return }
        let peer = peerTID.trimmingCharacters(in: .whitespaces)
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !peer.isEmpty, !text.isEmpty else { return }
        sending = true
        errorMessage = nil
        defer { sending = false }
        do {
            let dm = try await app.ensureDMKey()
            guard let peerPub = try await app.api.fetchDMPublicKey(peer) else {
                errorMessage = "Peer hasn't registered a DM key yet."
                return
            }
            let plaintext = Data(text.utf8)
            let nonce = NaClBox.randomNonce()
            let cipher = try NaClBox.box(
                plaintext,
                nonce: nonce,
                recipientPublicKey: peerPub,
                senderPrivateKey: dm.privateKey
            )
            _ = try await app.api.sendDM(
                recipientTID: peer,
                ciphertext: cipher,
                nonce: nonce,
                senderX25519: dm.publicKey,
                as: key,
                tid: tid
            )
            dismiss()
            onSent()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
