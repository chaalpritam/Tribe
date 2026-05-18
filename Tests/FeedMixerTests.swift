import XCTest
@testable import Tribe

final class FeedMixerTests: XCTestCase {
    private func tweet(_ hash: String) -> FeedItem {
        .tweet(Tweet(
            hash: hash,
            tid: "1",
            text: hash,
            parentHash: nil,
            channelId: "sf",
            embeds: nil,
            timestamp: Date(),
            username: nil,
            replyCount: nil
        ))
    }

    func testInterleavePattern() {
        let tweets = (0..<5).map { tweet("t\($0)") }
        let other: [FeedItem] = [.poll(try! FixtureLoader.decode(Poll.self, named: "poll"))]
        let mixed = FeedMixer.interleave(tweets: tweets, other: other)
        XCTAssertEqual(mixed.count, 6)
        XCTAssertEqual(mixed[0].id, "tweet-t0")
        XCTAssertEqual(mixed[1].id, "tweet-t1")
        XCTAssertEqual(mixed[2].id, "poll-poll-1")
        XCTAssertEqual(mixed[3].id, "tweet-t2")
    }

    func testChannelScopeMatchesCityAndGeneral() {
        XCTAssertTrue(ChannelScope.matches(cityId: "sf", channelId: "sf"))
        XCTAssertTrue(ChannelScope.matches(cityId: "sf", channelId: "general"))
        XCTAssertTrue(ChannelScope.matches(cityId: "sf", channelId: nil))
        XCTAssertFalse(ChannelScope.matches(cityId: "sf", channelId: "nyc"))
    }

}
