import SwiftUI

enum CreateMode: String, Identifiable, Hashable, CaseIterable {
    case tweet
    case event
    case poll
    case task
    case crowdfund
    case tribe

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tweet: return "Tweet"
        case .event: return "Event"
        case .poll: return "Poll"
        case .task: return "Task"
        case .crowdfund: return "Fund"
        case .tribe: return "Tribe"
        }
    }

    var subtitle: String {
        switch self {
        case .tweet: return "Update the neighborhood pulse"
        case .event: return "Gather everyone together"
        case .poll: return "Ask for community feedback"
        case .task: return "Call for a helping hand"
        case .crowdfund: return "Raise impact capital"
        case .tribe: return "Build a mini-community"
        }
    }

    var symbol: String {
        switch self {
        case .tweet: return "text.bubble"
        case .event: return "calendar"
        case .poll: return "chart.bar"
        case .task: return "checkmark.circle"
        case .crowdfund: return "banknote"
        case .tribe: return "number"
        }
    }

    var accent: Color {
        switch self {
        case .tweet: return Theme.primary
        case .event: return .teal
        case .poll: return Theme.error
        case .task: return .orange
        case .crowdfund: return .purple
        case .tribe: return .cyan
        }
    }
}
