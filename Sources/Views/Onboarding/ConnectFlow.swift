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
            ZStack {
                Circle()
                    .fill(Theme.brandGradient)
                    .frame(width: 120, height: 120)
                    .shadow(color: Theme.primary.opacity(0.35), radius: 20, y: 10)
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(.white)
            }
            VStack(spacing: 10) {
                Text("Tribe")
                    .font(.largeTitle.bold())
                Text("Hyperlocal social on the Tribe protocol. Connect your identity, pick your city, explore your neighborhood.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
            Spacer()
            Button(action: onContinue) {
                Text("Get started")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.primary)
            .controlSize(.large)
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.softBrandBackground.ignoresSafeArea())
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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sign in to Tribe")
                    .font(.title2.bold())
                Text("Your TID lives on Solana. This device holds an app key that signs protocol envelopes.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                identityCard(
                    icon: "list.bullet.rectangle",
                    title: "Seed phrase",
                    subtitle: "Recover wallet via BIP39, then paste your app key"
                ) { path.append(ConnectFlow.Step.seedPhrase) }

                identityCard(
                    icon: "key.horizontal",
                    title: "Create app key",
                    subtitle: "Generate a fresh ed25519 key on this device"
                ) { path.append(ConnectFlow.Step.createKey) }

                identityCard(
                    icon: "square.and.arrow.down",
                    title: "Import TID + app key",
                    subtitle: "Paste credentials from tribe-app"
                ) { path.append(ConnectFlow.Step.importKey) }
            }
            .padding(20)
        }
        .background(Theme.softBrandBackground.ignoresSafeArea())
        .navigationTitle("Identity")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func identityCard(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Theme.primary)
                    .frame(width: 40, height: 40)
                    .background(Theme.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.caption).foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(Theme.surface)
            )
        }
        .buttonStyle(.plain)
    }
}
