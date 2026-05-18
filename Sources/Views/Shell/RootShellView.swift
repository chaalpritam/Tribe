import SwiftUI

struct RootShellView: View {
    @EnvironmentObject private var app: AppState

    @State private var selectedTab: ShellTab = .home
    @State private var chatPath: [DMTarget] = []
    @State private var showCreate = false
    @State private var showCitySwitcher = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeFeedView()
                        .environmentObject(app.interactions)
                        .navigationTitle(app.currentCity?.displayName ?? "Home")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbar { homeToolbar }
                }
                .tabItem { Label(ShellTab.home.title, systemImage: ShellTab.home.systemImage) }
                .tag(ShellTab.home)

                NavigationStack {
                    MapView()
                        .navigationTitle(ShellTab.explore.title)
                        .navigationBarTitleDisplayMode(.large)
                }
                .tabItem { Label(ShellTab.explore.title, systemImage: ShellTab.explore.systemImage) }
                .tag(ShellTab.explore)

                NavigationStack(path: $chatPath) {
                    ChatListView(path: $chatPath)
                        .navigationTitle(ShellTab.chat.title)
                        .navigationBarTitleDisplayMode(.large)
                        .navigationDestination(for: DMTarget.self) { target in
                            DMThreadView(target: target)
                                .environmentObject(app)
                        }
                }
                .tabItem { Label(ShellTab.chat.title, systemImage: ShellTab.chat.systemImage) }
                .tag(ShellTab.chat)

                NavigationStack {
                    ProfileView()
                        .environmentObject(app.interactions)
                        .navigationTitle(ShellTab.profile.title)
                        .navigationBarTitleDisplayMode(.large)
                }
                .tabItem { Label(ShellTab.profile.title, systemImage: ShellTab.profile.systemImage) }
                .tag(ShellTab.profile)
            }
            .blur(radius: app.isSwitchingCity ? 6 : 0)
            .opacity(app.isSwitchingCity ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.35), value: app.isSwitchingCity)

            CitySwitchOverlay()
        }
        .sheet(isPresented: $showCreate) {
            CreateHubView()
                .environmentObject(app)
        }
        .sheet(isPresented: $showCitySwitcher) {
            CitySwitcherSheet()
        }
    }

    @ToolbarContentBuilder
    private var homeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showCitySwitcher = true
            } label: {
                Label("Change city", systemImage: "location.fill")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                showCreate = true
            } label: {
                Label("Create", systemImage: "square.and.pencil")
            }
        }
    }
}
