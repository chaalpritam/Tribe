import MapKit
import SwiftUI

/// Full-screen Explore map with the same pins and controls as the inline preview.
struct ExploreMapFullscreenView: View {
    @Environment(\.dismiss) private var dismiss

    let channelName: String
    let emptyMessage: String
    let pins: [ExploreMapPin]
    let events: [Event]
    let channels: [Channel]

    @Binding var cameraPosition: MapCameraPosition
    @Binding var selection: ExploreMapPin?

    @ObservedObject var location: LocationProvider

    var onOpenEvent: (Event) -> Void
    var onOpenCity: (Channel) -> Void

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ExploreMapView(
                    pins: pins,
                    events: events,
                    channels: channels,
                    mapHeight: geometry.size.height,
                    showsExpandControl: false,
                    emptyMessage: emptyMessage,
                    onExpand: nil,
                    cameraPosition: $cameraPosition,
                    selection: $selection,
                    location: location,
                    onOpenEvent: { event in
                        dismiss()
                        onOpenEvent(event)
                    },
                    onOpenCity: { channel in
                        dismiss()
                        onOpenCity(channel)
                    }
                )
            }
            .navigationTitle(channelName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
