import SwiftUI

struct RootShellView: View {
    @EnvironmentObject private var app: AppState

    @State private var selectedTab: ShellTab = .home
    @State private var chatPath: [DMTarget] = []
    @State private var showCreate = false
    @State private var showCitySwitcher = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                AppHeader(
                    title: headerTitle,
                    showBackButton: showShellBack,
                    onBack: {
                        if selectedTab == .chat { chatPath.removeLast() }
                    },
                    onChangeCity: selectedTab == .home ? { showCitySwitcher = true } : nil
                )
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .blur(radius: app.isSwitchingCity ? 6 : 0)
            .scaleEffect(app.isSwitchingCity ? 0.96 : 1)
            .opacity(app.isSwitchingCity ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.35), value: app.isSwitchingCity)

            CitySwitchOverlay()
        }
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomPillNav(selectedTab: $selectedTab, onCreate: { showCreate = true })
                .padding(.bottom, 8)
        }
        .sheet(isPresented: $showCreate) {
            CreateHubView()
                .environmentObject(app)
                .presentationCornerRadius(Theme.sheetCornerRadius)
        }
        .sheet(isPresented: $showCitySwitcher) {
            CitySwitcherSheet()
        }
    }

    private var headerTitle: String {
        switch selectedTab {
        case .home:
            return app.currentCity?.displayName ?? "Home"
        case .chat:
            if let last = chatPath.last {
                return last.displayTitle
            }
            return "Chat"
        default:
            return selectedTab.title
        }
    }

    private var showShellBack: Bool {
        selectedTab == .chat && !chatPath.isEmpty
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeFeedView()
                .environmentObject(app.interactions)
        case .explore:
            MapView()
        case .chat:
            NavigationStack(path: $chatPath) {
                ChatListView(path: $chatPath)
                    .navigationDestination(for: DMTarget.self) { target in
                        DMThreadView(target: target)
                            .environmentObject(app)
                    }
            }
            .navigationBarHidden(true)
        case .profile:
            NavigationStack {
                ProfileView()
                    .environmentObject(app.interactions)
            }
            .navigationBarHidden(true)
        }
    }
}
