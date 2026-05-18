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

    enum ProfileTab: String, CaseIterable {
        case posts = "Posts"
        case media = "Media"
        case stats = "Stats"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if loading, user == nil {
                    ProgressView()
                        .padding(.vertical, 48)
                } else {
                    heroCard
                    tabPicker
                    tabContent
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Theme.pageBackground)
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
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(app)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                if let tid = app.myTID {
                    UserAvatarView(tid: tid, initial: user?.initial ?? "T", size: 88, seed: user?.username ?? tid)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(user?.displayName ?? "Profile")
                        .font(.title2.bold())
                    Text(handleText)
                        .font(.subheadline)
                        .foregroundStyle(Theme.primary)
                    statsRow
                }
                Spacer(minLength: 0)
            }

            if let bio = user?.profile?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)
            }

            HStack(spacing: 8) {
                if let location = user?.profile?.location, !location.isEmpty {
                    Label(location, systemImage: "mappin")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.tertiarySystemFill), in: Capsule())
                }
                if let wallet = app.walletAddress, !wallet.isEmpty {
                    Button {
                        UIPasteboard.general.string = wallet
                        copiedWallet = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiedWallet = false }
                    } label: {
                        Label(copiedWallet ? "Copied" : shortAddress(wallet), systemImage: copiedWallet ? "checkmark" : "wallet.pass")
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.15), in: Capsule())
                }
            }

            HStack(spacing: 8) {
                Button("Edit Profile") { showEditor = true }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                Button("Wallet") { showWallet = true }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Button("Activity") { showActivity = true }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Button("Settings") { showSettings = true }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            statButton(value: user?.followersCount ?? 0, label: "Followers") {
                followListMode = .followers
            }
            statButton(value: user?.followingCount ?? 0, label: "Following") {
                followListMode = .following
            }
            statButton(value: tweets.count, label: "Posts") {}
            Button {
                showKarma = true
            } label: {
                statColumn(value: karma?.total ?? 0, label: "Karma")
            }
            .buttonStyle(.plain)
        }
    }

    private func statButton(value: Int, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            statColumn(value: value, label: label)
        }
        .buttonStyle(.plain)
    }

    private func statColumn(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(FormatCount.compact(value))
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var tabPicker: some View {
        Picker("Content", selection: $activeTab) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case .posts:
            postsTab
        case .media:
            mediaTab
        case .stats:
            statsTab
        }
    }

    private var postsTab: some View {
        Group {
            if tweets.isEmpty {
                emptyTab(icon: "bubble.left", title: "No posts yet")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(tweets) { tweet in
                        TweetCardView(tweet: tweet)
                            .environmentObject(app)
                            .environmentObject(app.interactions)
                    }
                }
            }
        }
    }

    private var mediaTab: some View {
        let mediaTweets = tweets.filter { $0.firstMediaURL(resolver: app.api.resolveMediaURL) != nil }
        return Group {
            if mediaTweets.isEmpty {
                emptyTab(icon: "photo", title: "No media yet")
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                    ForEach(mediaTweets) { tweet in
                        if let url = tweet.firstMediaURL(resolver: app.api.resolveMediaURL) {
                            CachedAsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color(white: 0.92)
                            }
                            .aspectRatio(1, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            }
        }
    }

    private var statsTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let karma {
                statLine("Karma level", value: "L\(karma.level)")
                statLine("Total karma", value: "\(karma.total)")
                statLine("Tweets", value: "\(karma.breakdown.tweets)")
                statLine("Reactions received", value: "\(karma.breakdown.reactionsReceived)")
                statLine("Followers (karma)", value: "\(karma.breakdown.followers)")
            } else {
                Text("Karma loads from the hub karma-registry.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            statLine("Joined tribes", value: "\(app.joinedChannels.count)")
            statLine("Current city", value: app.currentCity?.displayName ?? "—")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
    }

    private func statLine(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.bold))
        }
    }

    private func emptyTab(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(Theme.textSecondary.opacity(0.4))
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private var handleText: String {
        if let u = user?.username ?? app.myUsername { return "@\(u).tribe" }
        if let tid = app.myTID { return "#\(tid)" }
        return ""
    }

    private func shortAddress(_ address: String) -> String {
        guard address.count > 10 else { return address }
        return "\(address.prefix(4))…\(address.suffix(4))"
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

