import SwiftUI

/// Semantic design tokens aligned with Apple Human Interface Guidelines.
enum Theme {
    static let primary = Color("Primary")
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")

    static let surface = Color(.secondarySystemGroupedBackground)
    static let pageBackground = Color(.systemGroupedBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)

    /// Standard grouped list / card corner (continuous).
    static let cardCornerRadius: CGFloat = 12
    /// Sheets use the system presentation radius when possible.
    static let sheetCornerRadius: CGFloat = 20

    /// Subtle brand wash for onboarding — uses system grouped background.
    static let onboardingBackground = Color(.systemGroupedBackground)
}
