import SwiftUI

/// Main shell tabs flanking the center Create button (tribeapp.wtf bottom nav).
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
        case .chat: return "message.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .chat: return "Chat"
        case .profile: return "Profile"
        }
    }

    static let leftTabs: [ShellTab] = [.home, .explore]
    static let rightTabs: [ShellTab] = [.chat, .profile]
}
