import SwiftUI

/// Main shell tabs flanking the center Create button (tribeapp.wtf bottom nav).
enum ShellTab: String, CaseIterable, Identifiable {
    case home
    case explore
    case map
    case tribes
    case chat
    case profile

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "safari.fill"
        case .map: return "map.fill"
        case .tribes: return "person.3.fill"
        case .chat: return "message.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .map: return "Map"
        case .tribes: return "Tribes"
        case .chat: return "Chat"
        case .profile: return "Profile"
        }
    }

    static let leftTabs: [ShellTab] = [.home, .explore, .map]
    static let rightTabs: [ShellTab] = [.tribes, .chat, .profile]
}
