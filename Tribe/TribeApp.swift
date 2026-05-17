//
//  TribeApp.swift
//  Tribe
//

import SwiftUI

@main
struct TribeApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(appState.interactions)
                .environmentObject(appState.tipStats)
                .environmentObject(appState.userAvatars)
                .environmentObject(appState.toasts)
                .overlay { ToastOverlay() }
        }
    }
}
