import XCTest
@testable import Tribe

final class ExploreMapPinTests: XCTestCase {
    func testFromBuildsEventAndCityPins() throws {
        let event = try FixtureLoader.decode(Event.self, named: "event")
        let city = Channel(id: "brooklyn", name: "Brooklyn", kind: 2, latitude: 40.68, longitude: -73.94)

        let pins = ExploreMapPin.from(events: [event], channels: [city])

        XCTAssertFalse(pins.isEmpty)
        XCTAssertTrue(pins.contains { $0.kind == .event && $0.eventId == event.id })
        XCTAssertTrue(pins.contains { $0.kind == .city && $0.channelId == "brooklyn" })
    }
}
