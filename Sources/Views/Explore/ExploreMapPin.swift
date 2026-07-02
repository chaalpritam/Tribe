import CoreLocation
import MapKit
import SwiftUI

struct ExploreMapPin: Identifiable, Hashable {
    enum Kind: Hashable {
        case event, city

        var symbol: String {
            switch self {
            case .event: return "calendar"
            case .city: return "building.2.fill"
            }
        }

        var tint: Color {
            switch self {
            case .event: return Theme.accentEmerald
            case .city: return Theme.brand
            }
        }

        var label: String {
            switch self {
            case .event: return "Event"
            case .city: return "City"
            }
        }
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let eventId: String?
    let channelId: String?

    static func == (lhs: ExploreMapPin, rhs: ExploreMapPin) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static func from(events: [Event], channels: [Channel]) -> [ExploreMapPin] {
        var pins: [ExploreMapPin] = []
        for event in events where event.latitude != nil && event.longitude != nil {
            pins.append(ExploreMapPin(
                id: "event:\(event.id)",
                kind: .event,
                title: event.title,
                subtitle: event.locationText ?? "Event",
                coordinate: CLLocationCoordinate2D(latitude: event.latitude!, longitude: event.longitude!),
                eventId: event.id,
                channelId: event.channelId
            ))
        }
        for channel in channels where channel.isCity {
            guard let lat = channel.latitude, let lng = channel.longitude else { continue }
            pins.append(ExploreMapPin(
                id: "city:\(channel.id)",
                kind: .city,
                title: channel.displayName,
                subtitle: "City channel",
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                eventId: nil,
                channelId: channel.id
            ))
        }
        return pins
    }

    static func regionFitting(_ pins: [ExploreMapPin], userCoordinate: CLLocationCoordinate2D?) -> MapCameraPosition {
        var coordinates = pins.map(\.coordinate)
        if let userCoordinate { coordinates.append(userCoordinate) }
        guard !coordinates.isEmpty else { return .automatic }

        let lats = coordinates.map(\.latitude)
        let lngs = coordinates.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lngs.min()! + lngs.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.08, (lats.max()! - lats.min()!) * 1.5),
            longitudeDelta: max(0.08, (lngs.max()! - lngs.min()!) * 1.5)
        )
        return .region(MKCoordinateRegion(center: center, span: span))
    }

    static func region(center: CLLocationCoordinate2D, spanDelta: Double = 0.05) -> MapCameraPosition {
        .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        ))
    }
}
