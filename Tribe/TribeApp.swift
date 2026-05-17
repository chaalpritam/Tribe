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
            ContentView()
                .environmentObject(appState)
                .environmentObject(appState.interactions)
                .environmentObject(appState.tipStats)
                .environmentObject(appState.userAvatars)
        }
    }
}
