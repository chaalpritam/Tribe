import SwiftUI

/// Card shell for non-tweet feed items (events, polls, tasks).
struct FeedCardChrome<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .tribeCard()
            .frame(maxWidth: .infinity, alignment: .leading)
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
        ZStack {
            Theme.avatarGradient(seed: seed)
            Text(initial)
                .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5))
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
    }

    private var initial: String {
        String(seed.trimmingCharacters(in: .whitespaces).prefix(1)).uppercased()
    }
}
