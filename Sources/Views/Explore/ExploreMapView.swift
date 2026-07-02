import CoreLocation
import MapKit
import SwiftUI

/// Reusable MapKit surface for Explore with pin selection and map controls.
struct ExploreMapView: View {
    let pins: [ExploreMapPin]
    let events: [Event]
    let channels: [Channel]
    var mapHeight: CGFloat = 200
    var showsExpandControl: Bool = true
    var emptyMessage: String = "No map pins yet"
    var onExpand: (() -> Void)?

    @Binding var cameraPosition: MapCameraPosition
    @Binding var selection: ExploreMapPin?

    @ObservedObject var location: LocationProvider

    var onOpenEvent: (Event) -> Void
    var onOpenCity: (Channel) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            mapContent
            mapControls
        }
        .frame(height: mapHeight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .bottom) {
            if let pin = selection {
                ExploreMapPinCard(
                    pin: pin,
                    event: event(for: pin),
                    channel: channel(for: pin),
                    onDismiss: { selection = nil },
                    onOpenEvent: onOpenEvent,
                    onOpenCity: onOpenCity
                )
                .padding(12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.18), value: selection?.id)
    }

    @ViewBuilder
    private var mapContent: some View {
        if pins.isEmpty {
            ZStack {
                Theme.avatarGradient(seed: "explore-map")
                    .opacity(0.35)
                VStack(spacing: 6) {
                    Image(systemName: "mappin.slash")
                        .font(.title2)
                    Text(emptyMessage)
                        .font(.footnote.weight(.medium))
                }
                .foregroundStyle(.secondary)
            }
        } else {
            Map(position: $cameraPosition, selection: Binding(
                get: { selection?.id },
                set: { id in selection = pins.first { $0.id == id } }
            )) {
                if location.coordinate != nil {
                    UserAnnotation()
                }
                ForEach(pins) { pin in
                    Marker(pin.title, systemImage: pin.kind.symbol, coordinate: pin.coordinate)
                        .tint(pin.kind.tint)
                        .tag(pin.id)
                }
            }
            .mapStyle(.standard(elevation: .flat))
        }
    }

    private var mapControls: some View {
        VStack(spacing: 8) {
            Button(action: centerOnUser) {
                Image(systemName: "location.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.brand)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Center on my location")

            if showsExpandControl, let onExpand {
                Button(action: onExpand) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.brand)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Expand map")
            }
        }
        .padding(10)
    }

    private func event(for pin: ExploreMapPin) -> Event? {
        guard let eventId = pin.eventId else { return nil }
        return events.first { $0.id == eventId }
    }

    private func channel(for pin: ExploreMapPin) -> Channel? {
        guard let channelId = pin.channelId else { return nil }
        return channels.first { $0.id == channelId }
    }

    private func centerOnUser() {
        location.request()
        if let coordinate = location.coordinate {
            withAnimation {
                cameraPosition = ExploreMapPin.region(center: coordinate)
            }
        }
    }
}

private struct ExploreMapPinCard: View {
    let pin: ExploreMapPin
    let event: Event?
    let channel: Channel?
    var onDismiss: () -> Void
    var onOpenEvent: (Event) -> Void
    var onOpenCity: (Channel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: pin.kind.symbol)
                    .foregroundStyle(pin.kind.tint)
                Text(pin.kind.label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }

            Text(pin.title)
                .font(.headline.weight(.bold))
            Text(pin.subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            if let event {
                Button {
                    onOpenEvent(event)
                } label: {
                    HStack {
                        Text("View event")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Theme.brand.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
            } else if let channel, pin.kind == .city {
                Button {
                    onOpenCity(channel)
                } label: {
                    HStack {
                        Text("Open \(channel.displayName)")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Theme.brand.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
