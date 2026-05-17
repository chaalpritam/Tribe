import SwiftUI

struct TribesDirectoryView: View {
    @EnvironmentObject private var app: AppState
    @Binding var path: [TribesDestination]
    var onJumpToCity: () -> Void

    @State private var searchText = ""
    @State private var allChannels: [Channel] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var togglingChannelId: String?

    private var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var cityChannels: [Channel] {
        let cities = allChannels.filter(\.isCity)
        guard !query.isEmpty else { return cities }
        return cities.filter { matchesSearch($0) }
    }

    private var interestChannels: [Channel] {
        let tribes = allChannels.filter { !$0.isCity }
        guard !query.isEmpty else { return tribes }
        return tribes.filter { matchesSearch($0) }
    }

    private var joinedTribes: [Channel] {
        let joinedIds = Set(app.joinedChannels.map(\.id))
        return interestChannels.filter { joinedIds.contains($0.id) }
    }

    private var discoverTribes: [Channel] {
        let joinedIds = Set(app.joinedChannels.map(\.id))
        return interestChannels.filter { !joinedIds.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                searchBar

                if isLoading, allChannels.isEmpty {
                    ProgressView("Loading tribes…")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                } else if let loadError, allChannels.isEmpty {
                    loadErrorBanner(loadError)
                }

                if !cityChannels.isEmpty {
                    citySection
                }

                if !joinedTribes.isEmpty {
                    tribeSection(title: "Your Tribes", subtitle: "Communities you've joined", tribes: joinedTribes)
                }

                if !discoverTribes.isEmpty {
                    tribeSection(title: "Discover", subtitle: "Local Communities", tribes: discoverTribes)
                }

                if !isLoading, cityChannels.isEmpty, joinedTribes.isEmpty, discoverTribes.isEmpty {
                    emptyDirectory
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
        .task {
            await loadChannels()
        }
        .refreshable {
            await loadChannels()
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)
            TextField("Search cities & tribes…", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var citySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Cities", subtitle: "Jump to a hyperlocal feed")
            LazyVGrid(columns: cityColumns, spacing: 12) {
                ForEach(cityChannels) { channel in
                    CityChannelCard(
                        channel: channel,
                        isCurrentCity: channel.id == app.currentCity?.id,
                        onJump: { jump(to: channel) }
                    )
                }
            }
        }
    }

    private func tribeSection(title: String, subtitle: String, tribes: [Channel]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: title, subtitle: subtitle)
            VStack(spacing: 12) {
                ForEach(tribes) { channel in
                    TribeRowCard(
                        channel: channel,
                        isJoined: app.isJoined(channelId: channel.id),
                        isToggling: togglingChannelId == channel.id,
                        onJoinToggle: { toggleMembership(for: channel) },
                        onOpen: { path.append(.tribe(channel)) }
                    )
                }
            }
        }
    }

    private var emptyDirectory: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 40))
                .foregroundStyle(Theme.textSecondary)
            Text("No tribes found")
                .font(.title3.weight(.bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 64)
    }

    private var cityColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.weight(.bold))
            Text(subtitle.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private func loadErrorBanner(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(Theme.error)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.error.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func matchesSearch(_ channel: Channel) -> Bool {
        guard !query.isEmpty else { return true }
        let name = channel.displayName.lowercased()
        return name.contains(query) || channel.id.lowercased().contains(query)
    }

    private func loadChannels() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let channels = try await app.api.fetchChannels()
            allChannels = channels
            loadError = nil
        } catch {
            loadError = error.localizedDescription
            if allChannels.isEmpty {
                allChannels = (await app.loadCityOptions()).cities
            }
        }
    }

    private func jump(to channel: Channel) {
        Task {
            await app.switchCity(to: channel)
            onJumpToCity()
        }
    }

    private func toggleMembership(for channel: Channel) {
        guard togglingChannelId == nil else { return }
        togglingChannelId = channel.id
        Task {
            defer { togglingChannelId = nil }
            do {
                if app.isJoined(channelId: channel.id) {
                    try await app.leaveChannel(channel)
                } else {
                    try await app.joinChannel(channel)
                }
            } catch {
                loadError = error.localizedDescription
            }
        }
    }
}

// MARK: - City card

private struct CityChannelCard: View {
    let channel: Channel
    let isCurrentCity: Bool
    let onJump: () -> Void

    private var curated: CityCatalogEntry? {
        CityCatalog.entry(for: channel.id)
    }

    private var accent: Color {
        let hash = abs(channel.id.hashValue)
        let hue = Double(hash % 360) / 360.0
        return Color(hue: hue, saturation: 0.55, brightness: 0.85)
    }

    var body: some View {
        Button(action: onJump) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accent, accent.opacity(0.45), .black.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottom
                        )
                    )
                    .aspectRatio(3 / 4, contentMode: .fit)

                if isCurrentCity {
                    Text("NOW")
                        .font(.system(size: 8, weight: .black))
                        .tracking(1)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(8)
                }

                if channel.memberCount > 0 {
                    Text(FormatCount.compact(channel.memberCount))
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.4))
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(channel.displayName)
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    HStack {
                        Label(curated?.country ?? "Protocol", systemImage: "mappin")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.65))
                        Spacer(minLength: 0)
                        if !isCurrentCity {
                            Text("Jump")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(12)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tribe row

private struct TribeRowCard: View {
    let channel: Channel
    let isJoined: Bool
    let isToggling: Bool
    let onJoinToggle: () -> Void
    let onOpen: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onOpen) {
                HStack(spacing: 16) {
                    tribeAvatar
                    VStack(alignment: .leading, spacing: 4) {
                        Text(channel.displayName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)
                        Text("\(FormatCount.compact(channel.memberCount)) Members")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.textSecondary)
                            .textCase(.uppercase)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.black.opacity(0.2))
                }
            }
            .buttonStyle(.plain)

            Button(action: onJoinToggle) {
                Group {
                    if isToggling {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text(isJoined ? "Member" : "Join")
                            .font(.system(size: 13, weight: .bold))
                    }
                }
                .frame(minWidth: 72)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isJoined ? Color(white: 0.96) : Color.black)
                .foregroundStyle(isJoined ? Color(white: 0.4) : .white)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(isToggling)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var tribeAvatar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.brandGradient)
                .frame(width: 64, height: 64)
            Image(systemName: "person.3.fill")
                .font(.title2)
                .foregroundStyle(.white)
        }
    }
}
