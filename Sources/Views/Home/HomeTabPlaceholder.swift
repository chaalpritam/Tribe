import SwiftUI

struct HomeTabPlaceholder: View {
    @EnvironmentObject private var app: AppState

    @State private var feedStatus = "Loading your city feed…"
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(feedStatus)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Button {
                    Task { await refresh() }
                } label: {
                    HStack {
                        if isLoading { ProgressView().controlSize(.small) }
                        Text(isLoading ? "Refreshing…" : "Refresh feed")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.primary)
                .disabled(isLoading)

                Text("Phase 5 will render the mixed tweet / event / poll feed here.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(20)
        }
        .task { await refresh() }
    }

    private func refresh() async {
        isLoading = true
        defer { isLoading = false }
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
