//
//  ContentView.swift
//  Tribe
//

import SwiftUI

/// Phase 2 shell: proves AppState + hub decode against `/v1/feed`.
struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    @State private var feedStatus: String = "Tap refresh to probe the hub."
    @State private var isLoadingFeed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tribe")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Phase 2 · Foundation")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            Group {
                LabeledContent("Hub", value: appState.hubBaseURL.absoluteString)
                LabeledContent("Phase", value: phaseLabel)
                if let city = appState.currentCity {
                    LabeledContent("City", value: city.displayName)
                }
            }
            .font(.footnote.monospaced())

            Text(feedStatus)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                Task { await probeFeed() }
            } label: {
                HStack {
                    if isLoadingFeed {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Text(isLoadingFeed ? "Fetching…" : "Refresh /v1/feed")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.primary)
            .disabled(isLoadingFeed)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.pageBackground)
        .task {
            await probeFeed()
        }
    }

    private var phaseLabel: String {
        switch appState.phase {
        case .onboarding: return "onboarding"
        case .ready: return "ready"
        }
    }

    private func probeFeed() async {
        isLoadingFeed = true
        defer { isLoadingFeed = false }
        do {
            let tweets: [Tweet]
            if let city = appState.currentCity {
                tweets = try await appState.api.fetchChannelFeed(city.id)
            } else {
                tweets = try await appState.api.fetchFeed()
            }
            feedStatus = "Decoded \(tweets.count) tweet\(tweets.count == 1 ? "" : "s") from \(appState.hubBaseURL.host ?? "hub")."
        } catch {
            feedStatus = "Hub error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
