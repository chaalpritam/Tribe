import SwiftUI

struct ConnectFlow: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ConnectWelcomeView { path.append(Step.hub) }
                .navigationDestination(for: Step.self) { step in
                    switch step {
                    case .hub:
                        ConfigureHubView { path.append(Step.identity) }
                    case .identity:
                        IdentityChoiceView(path: $path)
                    case .qrLogin:
                        QRLoginView()
                    case .seedPhrase:
                        SeedPhraseConnectView()
                    case .createKey:
                        CreateAppKeyView()
                    case .importKey:
                        ImportIdentityView()
                    }
                }
        }
    }

    enum Step: Hashable {
        case hub
        case identity
        case qrLogin
        case seedPhrase
        case createKey
        case importKey
    }
}

// MARK: - Welcome

private struct ConnectWelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            VStack(spacing: 12) {
                Text("Welcome to Tribe")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text("Hyperlocal social on the Tribe protocol. Connect your identity, pick your city, explore your neighborhood.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Button(action: onContinue) {
                Text("Get started")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.brand)
            .controlSize(.large)
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.onboardingBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Hub

private struct ConfigureHubView: View {
    @EnvironmentObject private var app: AppState
    @State private var hubInput = ""
    @State private var validating = false
    @State private var error: String?
    var onContinue: () -> Void

    var body: some View {
        Form {
            Section {
                TextField("http://127.0.0.1:4000", text: $hubInput)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } header: {
                Text("Hub URL")
            } footer: {
                Text("Point at your Tribe hub. Use the default for `tribe start` on this machine.")
            }
            if let error {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(Theme.error)
                        .font(.footnote)
                }
            }
            Section {
                Button {
                    Task { await validate() }
                } label: {
                    HStack {
                        if validating { ProgressView() }
                        Text(validating ? "Checking…" : "Continue")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(validating || hubInput.isEmpty)
            }
        }
        .navigationTitle("Connect to hub")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if hubInput.isEmpty { hubInput = app.hubBaseURL.absoluteString }
        }
    }

    private func validate() async {
        guard let url = URL(string: hubInput.trimmingCharacters(in: .whitespaces)),
              url.scheme == "http" || url.scheme == "https" else {
            error = "URL must start with http:// or https://"
            return
        }
        validating = true
        error = nil
        defer { validating = false }
        let probe = HubClient(baseURL: url)
        do {
            struct Health: Decodable { let status: String? }
            let _: Health = try await probe.get("health")
            app.hubBaseURL = url
            onContinue()
        } catch {
            self.error = "Couldn't reach hub: \(error.localizedDescription)"
        }
    }
}

// MARK: - Identity choice

private struct IdentityChoiceView: View {
    @Binding var path: NavigationPath

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("How would you like to sign in?")
                    .font(.title2.bold())
                Text("Your TID lives on Solana. This device holds an app key that signs protocol envelopes.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 24)

            Spacer(minLength: 8)

            VStack(spacing: 12) {
                IdentityChoiceCard(
                    icon: "qrcode.viewfinder",
                    iconTint: Theme.brand,
                    title: "Scan QR to sign in",
                    subtitle: "Pair from tribe-app → Wallet → Pair phone"
                ) {
                    path.append(ConnectFlow.Step.qrLogin)
                }
                IdentityChoiceCard(
                    icon: "list.bullet.rectangle",
                    iconTint: Theme.accentTeal,
                    title: "Seed phrase",
                    subtitle: "Recover wallet via BIP39, then paste your app key"
                ) {
                    path.append(ConnectFlow.Step.seedPhrase)
                }
                IdentityChoiceCard(
                    icon: "key.horizontal",
                    iconTint: Theme.accentAmber,
                    title: "Create app key",
                    subtitle: "Generate a fresh ed25519 key on this device"
                ) {
                    path.append(ConnectFlow.Step.createKey)
                }
                IdentityChoiceCard(
                    icon: "square.and.arrow.down",
                    iconTint: Theme.accentTeal,
                    title: "Import TID + app key",
                    subtitle: "Paste credentials from tribe-app"
                ) {
                    path.append(ConnectFlow.Step.importKey)
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .navigationTitle("Sign in")
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.onboardingBackground.ignoresSafeArea())
    }
}

private struct IdentityChoiceCard: View {
    let icon: String
    let iconTint: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconTint.opacity(0.18))
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(iconTint)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Theme.cardStroke.opacity(0.4), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
