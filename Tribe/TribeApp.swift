//
//  TribeApp.swift
//  Tribe
//
//  Created by chaalpritam on 17/05/26.
//

import SwiftUI
import TribeCore

@main
struct TribeApp: App {
    init() {
        Blake3.selfTest()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
