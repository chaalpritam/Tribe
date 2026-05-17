import SwiftUI

/// Temporary ready state until Phase 4 shell ships.
struct ReadyPlaceholderView: View {
    @EnvironmentObject private var app: AppState

    @State private var feedStatus = "Tap refresh to load your city feed."
    @State private var isLoadingFeed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.currentCity?.displayName ?? "Tribe")
                        .font(.title2.weight(.semibold))
                    if let username = app.myUsername {
                        Text("@\(username).tribe")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
                Button("Sign out") { app.signOut() }
                    .font(.footnote.weight(.semibold))
            }

            Text(feedStatus)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            Button {
                Task { await probeFeed() }
            } label: {
                HStack {
                    if isLoadingFeed { ProgressView().controlSize(.small) }
                    Text(isLoadingFeed ? "Loading…" : "Refresh feed")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.primary)
            .disabled(isLoadingFeed)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pageBackground)
        .task { await probeFeed() }
    }

    private func probeFeed() async {
        isLoadingFeed = true
        defer { isLoadingFeed = false }
        guard let city = app.currentCity else {
            feedStatus = "No city selected."
            return
        }
        do {
            let tweets = try await app.api.fetchChannelFeed(city.id)
            feedStatus = "\(tweets.count) tweet\(tweets.count == 1 ? "" : "s") in \(city.displayName)."
        } catch {
            feedStatus = error.localizedDescription
        }
    }
}
