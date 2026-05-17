import SwiftUI

/// Design tokens for tribeapp.wtf parity (see PLAN.md).
enum Theme {
    static let primary = Color("Primary")
    static let success = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)
    static let warning = Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255)
    static let error = Color(red: 239 / 255, green: 68 / 255, blue: 68 / 255)

    static let cardCornerRadius: CGFloat = 20
    static let sheetCornerRadius: CGFloat = 36
}
