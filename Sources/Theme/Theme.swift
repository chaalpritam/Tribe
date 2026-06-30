import SwiftUI

/// Semantic design tokens aligned with tribe-twitter's TribeColor system.
enum Theme {
    static let brand = Color(red: 0.42, green: 0.36, blue: 0.95)
    static let brandSecondary = Color(red: 0.95, green: 0.36, blue: 0.65)

    static let primary = brand
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")

    static let surface = Color(.secondarySystemGroupedBackground)
    static let pageBackground = Color(.systemGroupedBackground)
    static let cardStroke = Color(.separator)
    static let chipBackground = Color(.tertiarySystemFill)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    static let accentIndigo = Color(red: 0.34, green: 0.40, blue: 0.96)
    static let accentAmber = Color(red: 0.98, green: 0.62, blue: 0.18)
    static let accentEmerald = Color(red: 0.18, green: 0.76, blue: 0.49)
    static let accentRose = Color(red: 0.96, green: 0.34, blue: 0.55)
    static let accentTeal = Color(red: 0.20, green: 0.74, blue: 0.78)

    static let brandGradient = LinearGradient(
        colors: [brand, brandSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let softBrandBackground = LinearGradient(
        colors: [
            Color(.systemBackground),
            brand.opacity(0.06),
            brandSecondary.opacity(0.05)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardCornerRadius: CGFloat = 16
    static let sheetCornerRadius: CGFloat = 20

    static let onboardingBackground = softBrandBackground

    static func avatarGradient(seed: String) -> LinearGradient {
        let hue = stableHue(for: seed)
        let secondary = (hue + 0.12).truncatingRemainder(dividingBy: 1.0)
        return LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0.75, brightness: 0.92),
                Color(hue: secondary, saturation: 0.85, brightness: 0.78)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private static func stableHue(for seed: String) -> Double {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        return Double(hash % 360) / 360.0
    }
}

struct TribeCardStyle: ViewModifier {
    var cornerRadius: CGFloat = Theme.cardCornerRadius
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.cardStroke.opacity(0.4), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func tribeCard(cornerRadius: CGFloat = Theme.cardCornerRadius, padding: CGFloat = 16) -> some View {
        modifier(TribeCardStyle(cornerRadius: cornerRadius, padding: padding))
    }
}
