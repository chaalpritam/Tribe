import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showAppKey = false
    @State private var confirmSignOut = false

    var body: some View {
        Form {
            Section {
                LabeledContent("Hub", value: app.hubBaseURL.absoluteString)
                    .lineLimit(1)
                    .truncationMode(.middle)
                if let tid = app.myTID {
                    LabeledContent("TID", value: tid)
                }
                if let handle = app.myUsername {
                    LabeledContent("Handle", value: "@\(handle).tribe")
                }
                if let wallet = app.walletAddress, !wallet.isEmpty {
                    LabeledContent("Wallet", value: shortAddress(wallet))
                }
            } header: {
                Text("Account")
            }

            Section {
                Button {
                    showAppKey = true
                } label: {
                    Label("View app key", systemImage: "key.horizontal")
                }
            } header: {
                Text("Identity")
            } footer: {
                Text("Use this to pair another device — paste into tribe-app or import on a second phone.")
            }

            Section {
                Button(role: .destructive) {
                    confirmSignOut = true
                } label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } footer: {
                Text("Wipes the local app key, TID, and channel state. Your on-chain identity stays on Solana — you can re-import it.")
            }

            Section {
                LabeledContent("Version", value: appVersion)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAppKey) {
            AppKeySheet()
                .environmentObject(app)
                .presentationDetents([.medium])
        }
        .confirmationDialog(
            "Sign out of Tribe?",
            isPresented: $confirmSignOut,
            titleVisibility: .visible
        ) {
            Button("Sign out", role: .destructive) {
                app.signOut()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears the app key from this device. Make sure you've backed up your seed phrase or saved the app key elsewhere.")
        }
    }

    private var appVersion: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return "\(short) (\(build))"
    }

    private func shortAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        return "\(address.prefix(4))…\(address.suffix(4))"
    }
}

private struct AppKeySheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Treat this like a password. Anyone with it can sign envelopes as your TID.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)

                ScrollView {
                    Text(app.appKey?.seedBase64 ?? "—")
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(white: 0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .frame(maxHeight: 160)

                Button {
                    if let seed = app.appKey?.seedBase64 {
                        UIPasteboard.general.string = seed
                        copied = true
                    }
                } label: {
                    Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)

                Spacer()
            }
            .padding(20)
            .navigationTitle("App key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
