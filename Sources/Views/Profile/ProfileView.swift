import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var app: AppState

    @State private var user: User?
    @State private var tweets: [Tweet] = []
    @State private var karma: KarmaSummary?
    @State private var loading = true
    @State private var activeTab: ProfileTab = .posts
    @State private var showEditor = false
    @State private var showKarma = false
    @State private var followListMode: FollowListView.Mode?
    @State private var showWallet = false
    @State private var showActivity = false
    @State private var showSettings = false
    @State private var copiedWallet = false

    enum ProfileTab: String, CaseIterable, Identifiable {
        case posts = "Posts"
        case media = "Media"
        case stats = "Stats"
        var id: String { rawValue }
    }

    var body: some View {
        Group {
            if app.myTID != nil {
                List {
                    profileHeader
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                    quickActions
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemBackground))

                    tabBar
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemBackground))

                    switch activeTab {
                    case .posts:
                        postsSection
                    case .media:
                        mediaSection
                    case .stats:
                        statsSection
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Theme.pageBackground)
            } else {
                EmptyStateView(
                    symbol: "person.crop.circle",
                    title: "No identity",
                    message: "Connect your TID to see your profile."
                )
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .refreshable { await refresh() }
        .task { await refresh() }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                ProfileEditorView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showEditor = false }
                        }
                    }
            }
            .environmentObject(app)
        }
        .sheet(isPresented: $showKarma) {
            if let karma {
                NavigationStack {
                    KarmaSheet(karma: karma)
                        .navigationTitle("Karma")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { showKarma = false }
                            }
                        }
                }
                .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showSettings = false }
                        }
                    }
            }
            .environmentObject(app)
        }
        .sheet(item: $followListMode) { mode in
            NavigationStack {
                if let tid = app.myTID {
                    FollowListView(tid: tid, mode: mode)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { followListMode = nil }
                            }
                        }
                }
            }
            .environmentObject(app)
        }
        .navigationDestination(isPresented: $showWallet) {
            WalletView()
                .environmentObject(app)
        }
        .navigationDestination(isPresented: $showActivity) {
            ActivityView()
                .environmentObject(app)
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var profileHeader: some View {
        if let tid = app.myTID {
            let seed = user?.username ?? tid
            VStack(alignment: .leading, spacing: 0) {
                banner(seed: seed)

                HStack(alignment: .bottom) {
                    UserAvatarView(
                        tid: tid,
                        initial: user?.initial ?? "T",
                        size: 84,
                        seed: seed
                    )
                    .overlay(Circle().strokeBorder(Color(.systemBackground), lineWidth: 4))
                    .offset(y: -42)
                    .padding(.leading, 16)
                    .padding(.bottom, -42)

                    Spacer()

                    Button {
                        showEditor = true
                    } label: {
                        Text("Edit profile")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().strokeBorder(Theme.cardStroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 16)
                    .padding(.top, 12)
                }

                VStack(alignment: .leading, spacing: 14) {
                    identityBlock(tid: tid)

                    if let bio = user?.profile?.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(2)
                    }

                    metaRow

                    if let registeredAt = user?.registeredAt {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text("Joined \(joinedDateLabel(registeredAt))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    statsRow
                        .padding(.top, 2)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)
            }
        }
    }

    private func banner(seed: String) -> some View {
        ZStack(alignment: .bottomTrailing) {
            if let raw = user?.profile?.coverUrl,
               !raw.isEmpty,
               let coverURL = app.api.resolveMediaURL(raw) {
                CachedAsyncImage(url: coverURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Theme.avatarGradient(seed: "banner-\(seed)")
                }
                .frame(height: 140)
                .clipped()
            } else {
                Theme.avatarGradient(seed: "banner-\(seed)")
                    .frame(height: 140)
            }

            Button {
                showEditor = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .buttonStyle(.plain)
            .padding(10)
            .accessibilityLabel("Edit cover photo")
        }
        .frame(maxWidth: .infinity)
    }

    private func identityBlock(tid: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(user?.displayName ?? "Profile")
                    .font(.title2.weight(.bold))
                    .lineLimit(1)
                    .layoutPriority(1)
                if let wallet = app.walletAddress, !wallet.isEmpty {
                    walletChip(wallet)
                }
                Spacer(minLength: 0)
            }
            Text(handleText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func walletChip(_ address: String) -> some View {
        Button {
            UIPasteboard.general.string = address
            copiedWallet = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copiedWallet = false }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "wallet.pass")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Image(systemName: copiedWallet ? "checkmark" : "doc.on.doc")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(copiedWallet ? Theme.accentEmerald : Theme.brand)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(Theme.chipBackground))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(copiedWallet ? "Copied wallet address" : "Copy wallet address")
    }

    @ViewBuilder
    private var metaRow: some View {
        if let location = user?.profile?.location, !location.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.accentTeal)
                Text(location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 0)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 22) {
            Button {
                followListMode = .following
            } label: {
                inlineStat(
                    value: FormatCount.compact(user?.followingCount ?? 0),
                    label: "Following"
                )
            }
            .buttonStyle(.plain)

            Button {
                followListMode = .followers
            } label: {
                inlineStat(
                    value: FormatCount.compact(user?.followersCount ?? 0),
                    label: "Followers"
                )
            }
            .buttonStyle(.plain)

            if let karma {
                Button {
                    showKarma = true
                } label: {
                    inlineStat(
                        value: FormatCount.compact(karma.total),
                        label: "Karma · L\(karma.level)",
                        valueTint: Theme.accentAmber
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func inlineStat(value: String, label: String, valueTint: Color = .primary) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(valueTint)
                .monospacedDigit()
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    // MARK: - Quick actions

    private var quickActions: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
        return LazyVGrid(columns: columns, spacing: 10) {
            Button { showWallet = true } label: {
                quickActionTile(title: "Wallet", symbol: "wallet.pass.fill", tint: Theme.accentAmber)
            }
            .buttonStyle(.plain)

            Button { showActivity = true } label: {
                quickActionTile(title: "Activity", symbol: "clock.arrow.circlepath", tint: Theme.accentEmerald)
            }
            .buttonStyle(.plain)

            Button { showKarma = true } label: {
                quickActionTile(title: "Karma", symbol: "star.fill", tint: Theme.brand)
            }
            .buttonStyle(.plain)
            .disabled(karma == nil)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }

    private func quickActionTile(title: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 22, height: 22)

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Theme.cardStroke.opacity(0.3), lineWidth: 0.5)
        )
        .contentShape(Rectangle())
    }

    // MARK: - Tab bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { activeTab = tab }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.subheadline.weight(activeTab == tab ? .bold : .medium))
                            .foregroundStyle(activeTab == tab ? .primary : .secondary)
                        Rectangle()
                            .fill(activeTab == tab ? Theme.brand : Color.clear)
                            .frame(height: 3)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.cardStroke.opacity(0.4))
                .frame(height: 0.5)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var postsSection: some View {
        if loading, tweets.isEmpty {
            ForEach(0..<3, id: \.self) { _ in
                profileSkeletonRow
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
        } else if tweets.isEmpty {
            emptyTabLabel("No posts yet.")
                .listRowSeparator(.hidden)
        } else {
            ForEach(tweets) { tweet in
                TweetCardView(tweet: tweet)
                    .environmentObject(app)
                    .environmentObject(app.interactions)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Theme.pageBackground)
            }
        }
    }

    @ViewBuilder
    private var mediaSection: some View {
        let mediaTweets = tweets.filter { $0.firstMediaURL(resolver: app.api.resolveMediaURL) != nil }
        if loading, tweets.isEmpty {
            mediaGridSkeleton
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        } else if mediaTweets.isEmpty {
            emptyTabLabel("No media yet.")
                .listRowSeparator(.hidden)
        } else {
            mediaGrid(mediaTweets)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
        }
    }

    private func mediaGrid(_ mediaTweets: [Tweet]) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(mediaTweets) { tweet in
                if let url = tweet.firstMediaURL(resolver: app.api.resolveMediaURL) {
                    CachedAsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color(.tertiarySystemFill)
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 124)
                    .clipped()
                }
            }
        }
        .padding(.top, 2)
    }

    private var mediaGridSkeleton: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<6, id: \.self) { _ in
                Color(.tertiarySystemFill)
                    .frame(height: 124)
            }
        }
        .padding(.top, 2)
        .redacted(reason: .placeholder)
    }

    @ViewBuilder
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let karma {
                statLine("Karma level", value: "L\(karma.level)")
                profileDivider
                statLine("Total karma", value: "\(karma.total)")
                profileDivider
                statLine("Tweets", value: "\(karma.breakdown.tweets)")
                profileDivider
                statLine("Reactions received", value: "\(karma.breakdown.reactionsReceived)")
                profileDivider
                statLine("Followers (karma)", value: "\(karma.breakdown.followers)")
                profileDivider
            } else {
                Text("Karma loads from the hub karma-registry.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.vertical, 12)
                profileDivider
            }
            statLine("Joined tribes", value: "\(app.joinedChannels.count)")
            profileDivider
            statLine("Current city", value: app.currentCity?.displayName ?? "—")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.systemBackground))
    }

    private var profileDivider: some View {
        Rectangle()
            .fill(Theme.cardStroke.opacity(0.4))
            .frame(height: 0.5)
    }

    private func statLine(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
        }
        .padding(.vertical, 12)
    }

    private func emptyTabLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 32)
    }

    private var profileSkeletonRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(Color(.tertiarySystemFill)).frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6).fill(Color(.tertiarySystemFill)).frame(width: 140, height: 11)
                RoundedRectangle(cornerRadius: 6).fill(Color(.tertiarySystemFill)).frame(maxWidth: .infinity).frame(height: 11)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.cardStroke.opacity(0.4))
                .frame(height: 0.5)
        }
        .redacted(reason: .placeholder)
    }

    // MARK: - Helpers

    private var handleText: String {
        if let u = user?.username ?? app.myUsername { return "@\(u).tribe" }
        if let tid = app.myTID { return "@tid\(tid)" }
        return ""
    }

    private func joinedDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func refresh() async {
        guard let tid = app.myTID else { return }
        loading = user == nil
        defer { loading = false }
        async let userTask = app.api.fetchUser(tid)
        async let tweetsTask = app.api.fetchFeed(tid: tid)
        async let karmaTask = app.api.fetchKarma(tid)
        user = try? await userTask
        tweets = (try? await tweetsTask) ?? []
        karma = try? await karmaTask
        if let user, let raw = user.profile?.pfpUrl, let url = app.api.resolveMediaURL(raw) {
            app.userAvatars.record(tid: tid, pfpUrl: url)
        }
        await app.refreshIdentityMetadata()
    }
}
