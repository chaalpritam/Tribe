import SwiftUI

/// Hub-first content ships as a signed envelope; L1 program settlement batches separately.
struct HubSettlementBadge: View {
    var body: some View {
        Label("On hub · L1 batches", systemImage: "link")
            .font(.caption2.weight(.bold))
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(white: 0.96))
            .clipShape(Capsule())
    }
}
