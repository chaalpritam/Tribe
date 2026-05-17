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
        .background(Color(red: 0.99, green: 0.99, blue: 0.99))
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
            .presentationCornerRadius(Theme.sheetCornerRadius)
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
                .presentationCornerRadius(Theme.sheetCornerRadius)
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
            .presentationCornerRadius(Theme.sheetCornerRadius)
        }
        .navigationDestination(isPresented: $showWallet) {
            WalletView()
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
                        .font(.title2.weight(.black))
                    Text(handleText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.primary)
                        .textCase(.uppercase)
                    statsRow
                }
                Spacer(minLength: 0)
            }

            if let bio = user?.profile?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color(white: 0.27))
            }

            HStack(spacing: 8) {
                if let location = user?.profile?.location, !location.isEmpty {
                    Label(location, systemImage: "mappin")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(white: 0.97))
                        .clipShape(Capsule())
                }
                if let wallet = app.walletAddress, !wallet.isEmpty {
                    Button {
                        UIPasteboard.general.string = wallet
                        copiedWallet = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copiedWallet = false }
                    } label: {
                        Label(copiedWallet ? "Copied" : shortAddress(wallet), systemImage: copiedWallet ? "checkmark" : "wallet.pass")
                            .font(.caption.weight(.bold))
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 10) {
                Button("Edit profile") { showEditor = true }
                    .buttonStyle(ProfilePillButtonStyle(fill: Color.black, foreground: .white))
                Button("Wallet") { showWallet = true }
                    .buttonStyle(ProfilePillButtonStyle(fill: Color(white: 0.96), foreground: Theme.textPrimary))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
        )
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
                .font(.headline.weight(.black))
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.textSecondary)
                .textCase(.uppercase)
        }
    }

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Button(tab.rawValue) { activeTab = tab }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(activeTab == tab ? Theme.textPrimary : Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(activeTab == tab ? Color.white : Color.clear)
                    .clipShape(Capsule())
            }
        }
        .padding(4)
        .background(Color(white: 0.94))
        .clipShape(Capsule())
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
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                default:
                                    Color(white: 0.92)
                                }
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
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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

private struct ProfilePillButtonStyle: ButtonStyle {
    let fill: Color
    let foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(fill)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
