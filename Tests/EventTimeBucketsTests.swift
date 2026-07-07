import XCTest
@testable import Tribe

final class EventTimeBucketsTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }

    func testTonightBucket() throws {
        let now = try makeDate("2025-06-04T14:00:00Z")
        let event = try makeEvent(startsAt: "2025-06-04T20:00:00Z")

        XCTAssertEqual(
            EventTimeBuckets.bucket(for: event, now: now, calendar: calendar),
            .tonight
        )
    }

    func testThisWeekendBucket() throws {
        let now = try makeDate("2025-06-04T14:00:00Z") // Wednesday
        let event = try makeEvent(startsAt: "2025-06-07T18:00:00Z") // Saturday

        XCTAssertEqual(
            EventTimeBuckets.bucket(for: event, now: now, calendar: calendar),
            .thisWeekend
        )
    }

    func testLaterBucket() throws {
        let now = try makeDate("2025-06-04T14:00:00Z")
        let event = try makeEvent(startsAt: "2025-06-20T18:00:00Z")

        XCTAssertEqual(
            EventTimeBuckets.bucket(for: event, now: now, calendar: calendar),
            .later
        )
    }

    func testSectionsOmitEmptyBuckets() throws {
        let now = try makeDate("2025-06-04T14:00:00Z")
        let tonight = try makeEvent(id: "a", startsAt: "2025-06-04T20:00:00Z")
        let weekend = try makeEvent(id: "b", startsAt: "2025-06-07T18:00:00Z")

        let sections = EventTimeBuckets.sections(from: [weekend, tonight], now: now, calendar: calendar)

        XCTAssertEqual(sections.map(\.bucket), [.tonight, .thisWeekend])
        XCTAssertEqual(sections[0].events.map(\.id), ["a"])
        XCTAssertEqual(sections[1].events.map(\.id), ["b"])
    }

    private func makeDate(_ iso: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard let date = formatter.date(from: iso) else {
            throw XCTSkip("Could not parse date")
        }
        return date
    }

    private func makeEvent(id: String = "evt-1", startsAt: String) throws -> Event {
        let json = """
        {
          "id": "\(id)",
          "creator_tid": 1,
          "title": "Meetup",
          "starts_at": "\(startsAt)",
          "created_at": "2025-06-01T10:00:00.000Z",
          "yes_count": "0"
        }
        """
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Event.self, from: data)
    }
}
