import SwiftUI

/// Rounded card shell matching tribeapp.wtf home cards.
struct FeedCardChrome<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.modalCornerRadius, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.modalCornerRadius, style: .continuous)
                    .strokeBorder(Color(.separator).opacity(0.35), lineWidth: 1)
            )
            .shadow(color: Theme.cardShadow, radius: Theme.cardShadowRadius, y: Theme.cardShadowY)
    }
}

struct FeedTypeBadge: View {
    let icon: String
    let label: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1.2)
        }
        .foregroundStyle(tint)
    }
}

struct AvatarInitial: View {
    let seed: String
    var size: CGFloat = 44

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.primary, Theme.primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    private var initial: String {
        String(seed.trimmingCharacters(in: .whitespaces).prefix(1)).uppercased()
    }
}
