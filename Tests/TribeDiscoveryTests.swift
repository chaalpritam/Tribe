import XCTest
@testable import Tribe

@MainActor
final class TribeDiscoveryTests: XCTestCase {
    func testDiscoverTribesOnlyAtCityScope() {
        let app = AppState()
        let city = Channel(id: "brooklyn", name: "Brooklyn", kind: 2)
        let joined = Channel(id: "runners", name: "Runners", kind: 1, memberCount: 5)
        let open = Channel(id: "food", name: "Foodies", kind: 1, memberCount: 12)
        app.joinedChannels = [joined]

        let all = [city, joined, open]
        XCTAssertEqual(
            TribeDiscovery.discoverTribes(allChannels: all, app: app, activeChannel: city).map(\.id),
            ["food"]
        )
        XCTAssertTrue(
            TribeDiscovery.discoverTribes(allChannels: all, app: app, activeChannel: joined).isEmpty
        )
    }

    func testJoinedTribesWhenBrowsingSubChannel() {
        let app = AppState()
        let tribe = Channel(id: "runners", name: "Runners", kind: 1)
        app.joinedChannels = [tribe]

        XCTAssertEqual(
            TribeDiscovery.joinedTribes(app: app, activeChannel: tribe).map(\.id),
            ["runners"]
        )
    }
}
