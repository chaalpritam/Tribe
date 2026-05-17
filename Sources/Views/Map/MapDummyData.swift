import Foundation

/// Placeholder map list rows matching tribeapp.wtf until on-chain places ship.
enum MapDummyData {
    struct Place: Identifiable, Hashable {
        let id: String
        let name: String
        let category: String
        let emoji: String
        let rating: Double
    }

    struct Person: Identifiable, Hashable {
        let id: String
        let displayName: String
        let username: String
        let colorHex: String
    }

    struct Review: Identifiable, Hashable {
        let id: String
        let placeName: String
        let author: String
        let rating: Double
        let text: String
    }

    static func places(cityName: String) -> [Place] {
        [
            Place(id: "p1", name: "\(cityName) Coffee Collective", category: "Café", emoji: "☕️", rating: 4.7),
            Place(id: "p2", name: "Neighborhood Market", category: "Market", emoji: "🛒", rating: 4.4),
            Place(id: "p3", name: "Sunset Park", category: "Park", emoji: "🌳", rating: 4.9),
        ]
    }

    static func people(cityName: String) -> [Person] {
        [
            Person(id: "u1", displayName: "\(cityName) Host", username: "host", colorHex: "6366F1"),
            Person(id: "u2", displayName: "Local Guide", username: "guide", colorHex: "10B981"),
            Person(id: "u3", displayName: "Street Photographer", username: "lens", colorHex: "F59E0B"),
        ]
    }

    static func reviews(cityName: String) -> [Review] {
        [
            Review(id: "r1", placeName: "\(cityName) Coffee Collective", author: "maya", rating: 5, text: "Best flat white on the block."),
            Review(id: "r2", placeName: "Neighborhood Market", author: "dev", rating: 4, text: "Fresh produce every morning."),
        ]
    }
}
