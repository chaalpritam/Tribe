import SwiftUI

/// Main tab bar destinations.
enum ShellTab: String, CaseIterable, Identifiable {
    case home
    case explore
    case chat
    case profile

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "map.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .chat: return "Messages"
        case .profile: return "Profile"
        }
    }
}
