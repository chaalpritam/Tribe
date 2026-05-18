//
//  TribeApp.swift
//  Tribe
//

import SwiftUI

@main
struct TribeApp: App {
    @StateObject private var appState = AppState()

    init() {
        TribeDiagnostics.install()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .overlay { ToastOverlay() }
                .environmentObject(appState)
                .environmentObject(appState.interactions)
                .environmentObject(appState.tipStats)
                .environmentObject(appState.userAvatars)
                .environmentObject(appState.toasts)
        }
    }
}
