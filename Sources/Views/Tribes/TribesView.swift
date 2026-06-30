import SwiftUI

/// Tribes tab — joined neighborhoods and discoverable channels for the
/// current city. Tap a tribe to open its feed; create or join from here.
struct TribesView: View {
    @EnvironmentObject private var app: AppState

    @State private var channels: [Channel] = []
    @State private var loading = true
    @State private var error: String?
    @State private var selectedTribe: Channel?
    @State private var showCreate = false
    @State private var workingId: String?

    private var cityName: String { app.currentCity?.displayName ?? "your city" }

    private var joinedTribes: [Channel] {
        app.joinedChannels.filter { !$0.isCity }
    }

    private var discoverTribes: [Channel] {
        channels
            .filter { !$0.isCity && !app.isJoined(channelId: $0.id) }
    }

    var body: some View {
        Group {
            if loading, channels.isEmpty, joinedTribes.isEmpty {
                loadingList
            } else if let error, channels.isEmpty, joinedTribes.isEmpty {
                EmptyStateView(
                    symbol: "wifi.exclamationmark",
                    title: "Couldn't load tribes",
                    message: error,
                    retryTitle: "Retry",
                    onRetry: { Task { await refresh() } }
                )
            } else if joinedTribes.isEmpty, discoverTribes.isEmpty {
                EmptyStateView(
                    symbol: "circle.hexagongrid.fill",
                    title: "No tribes yet",
                    message: "Create a tribe for your block, hobby, or neighborhood — or browse what others have started in \(cityName)."
                )
            } else {
                List {
                    if !joinedTribes.isEmpty {
                        Section {
                            ForEach(joinedTribes) { tribe in
                                tribeRow(tribe, joined: true)
                            }
                        } header: {
                            sectionHeader("Your tribes", symbol: "checkmark.seal.fill", tint: Theme.brand)
                        }
                    }

                    if !discoverTribes.isEmpty {
                        Section {
                            ForEach(discoverTribes) { tribe in
                                tribeRow(tribe, joined: false)
                            }
                        } header: {
                            sectionHeader("Discover in \(cityName)", symbol: "sparkles", tint: Theme.accentTeal)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Tribes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreate = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create tribe")
            }
        }
        .refreshable { await refresh() }
        .task(id: app.currentCity?.id) { await refresh() }
        .navigationDestination(item: $selectedTribe) { tribe in
            HomeFeedView(channelId: tribe.id)
                .environmentObject(app.interactions)
                .navigationTitle(tribe.displayName)
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCreate) {
            NavigationStack {
                CreateTribeComposer(onCreated: {
                    showCreate = false
                    Task { await refresh() }
                })
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showCreate = false }
                    }
                }
            }
            .environmentObject(app)
        }
    }

    private var loadingList: some View {
        List {
            ForEach(0..<4, id: \.self) { _ in
                TribeRowSkeleton()
            }
        }
        .listStyle(.insetGrouped)
        .redacted(reason: .placeholder)
    }

    private func sectionHeader(_ title: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            Text(title)
        }
        .textCase(nil)
        .font(.subheadline.weight(.semibold))
    }

    @ViewBuilder
    private func tribeRow(_ tribe: Channel, joined: Bool) -> some View {
        Button {
            selectedTribe = tribe
        } label: {
            TribeChannelRow(channel: tribe, joined: joined)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if joined {
                Button(role: .destructive) {
                    Task { await leave(tribe) }
                } label: {
                    Label("Leave", systemImage: "minus.circle")
                }
                .disabled(workingId == tribe.id)
            } else {
                Button {
                    Task { await join(tribe) }
                } label: {
                    Label("Join", systemImage: "plus.circle")
                }
                .tint(Theme.brand)
                .disabled(workingId == tribe.id)
            }
        }
    }

    @MainActor
    private func refresh() async {
        loading = channels.isEmpty && joinedTribes.isEmpty
        error = nil
        defer { loading = false }
        do {
            channels = try await app.api.fetchChannels()
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    private func join(_ tribe: Channel) async {
        workingId = tribe.id
        defer { workingId = nil }
        try? await app.joinChannel(tribe)
    }

    @MainActor
    private func leave(_ tribe: Channel) async {
        workingId = tribe.id
        defer { workingId = nil }
        try? await app.leaveChannel(tribe)
    }
}

// MARK: - Row

struct TribeChannelRow: View {
    let channel: Channel
    let joined: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Theme.avatarGradient(seed: "channel-\(channel.id)"))
                Text("#")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(channel.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if joined {
                        Text("JOINED")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.brand)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Theme.brand.opacity(0.12)))
                    }
                }
                Text(channel.description ?? "#\(channel.id)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("\(channel.memberCount) members · \(channel.tweetCount) posts")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

private struct TribeRowSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemFill))
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4).fill(Color(.tertiarySystemFill)).frame(width: 120, height: 11)
                RoundedRectangle(cornerRadius: 4).fill(Color(.tertiarySystemFill)).frame(width: 200, height: 9)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
