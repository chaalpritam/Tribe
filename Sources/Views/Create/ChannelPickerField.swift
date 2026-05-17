import SwiftUI

/// Picks a publish target channel: general, current city, or joined tribes.
struct ChannelPickerField: View {
    @EnvironmentObject private var app: AppState
    @Binding var channelId: String

    private var options: [(id: String, label: String)] {
        var list: [(String, String)] = [("general", "General")]
        if let city = app.currentCity {
            list.append((city.id, city.displayName))
        }
        for ch in app.joinedChannels where !list.contains(where: { $0.0 == ch.id }) {
            list.append((ch.id, ch.displayName))
        }
        return list
    }

    var body: some View {
        Picker("Channel", selection: $channelId) {
            ForEach(options, id: \.id) { option in
                Text(option.label).tag(option.id)
            }
        }
    }
}
