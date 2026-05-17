//
//  ContentView.swift
//  Tribe
//
//  Created by chaalpritam on 17/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(Theme.primary)
            Text("Tribe")
                .font(.title2.weight(.semibold))
            Text("Hyperlocal · Phase 1")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
