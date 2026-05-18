import SwiftUI

/// Grouped-style card shell for feed items.
struct FeedCardChrome<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
    }
}

struct FeedTypeBadge: View {
    let icon: String
    let label: String
    let tint: Color

    var body: some View {
        Label(label, systemImage: icon)
            .font(.caption.weight(.medium))
            .foregroundStyle(tint)
    }
}

struct AvatarInitial: View {
    let seed: String
    var size: CGFloat = 44

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Circle().fill(Theme.primary.gradient))
    }

    private var initial: String {
        String(seed.trimmingCharacters(in: .whitespaces).prefix(1)).uppercased()
    }
}
