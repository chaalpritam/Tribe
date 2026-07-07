import Foundation

enum EventTimeBucket: String, CaseIterable, Identifiable {
    case tonight
    case thisWeekend
    case later

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tonight: return "Tonight"
        case .thisWeekend: return "This weekend"
        case .later: return "Later"
        }
    }

    var symbol: String {
        switch self {
        case .tonight: return "moon.stars.fill"
        case .thisWeekend: return "sun.max.fill"
        case .later: return "calendar"
        }
    }

    static let displayOrder: [EventTimeBucket] = [.tonight, .thisWeekend, .later]
}

enum EventTimeBuckets {
    struct Section: Identifiable {
        let bucket: EventTimeBucket
        let events: [Event]
        var id: EventTimeBucket { bucket }
    }

    static func bucket(
        for event: Event,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> EventTimeBucket {
        if calendar.isDate(event.startsAt, inSameDayAs: now) {
            return .tonight
        }
        if isThisWeekend(event.startsAt, now: now, calendar: calendar) {
            return .thisWeekend
        }
        return .later
    }

    static func sections(
        from events: [Event],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [Section] {
        let sorted = events.sorted { $0.startsAt < $1.startsAt }
        let grouped = Dictionary(grouping: sorted) {
            bucket(for: $0, now: now, calendar: calendar)
        }
        return EventTimeBucket.displayOrder.compactMap { bucket in
            guard let items = grouped[bucket], !items.isEmpty else { return nil }
            return Section(bucket: bucket, events: items)
        }
    }

    private static func isThisWeekend(_ date: Date, now: Date, calendar: Calendar) -> Bool {
        guard date > now else { return false }

        let weekday = calendar.component(.weekday, from: date)
        guard weekday == 1 || weekday == 7 else { return false }

        let startOfToday = calendar.startOfDay(for: now)
        let startOfEventDay = calendar.startOfDay(for: date)
        let dayDelta = calendar.dateComponents([.day], from: startOfToday, to: startOfEventDay).day ?? 999
        return (1...7).contains(dayDelta)
    }
}
