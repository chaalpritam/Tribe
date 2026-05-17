import SwiftUI

/// Design tokens mapped from tribeapp.wtf (see PLAN.md).
enum Theme {
    static let primary = Color("Primary")
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")

    static let surface = Color(.secondarySystemGroupedBackground)
    static let pageBackground = Color(.systemGroupedBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)

    static let cardCornerRadius: CGFloat = 20
    static let modalCornerRadius: CGFloat = 36
    static let sheetCornerRadius: CGFloat = 36

    static let cardShadow = Color.black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 4

    static let brandGradient = LinearGradient(
        colors: [primary, Color(red: 0.95, green: 0.36, blue: 0.65)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let softBrandBackground = LinearGradient(
        colors: [
            Color(.systemBackground),
            primary.opacity(0.06),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let navPillBackground = Color.black
    static let navPillInactive = Color.white.opacity(0.6)
    static let navPillActiveBackground = Color.white
    static let navPillCornerRadius: CGFloat = 32
    static let shellBottomInset: CGFloat = 100
}
