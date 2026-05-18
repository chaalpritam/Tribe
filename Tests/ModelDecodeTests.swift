import XCTest
@testable import Tribe

final class ModelDecodeTests: XCTestCase {
    func testTweetFixture() throws {
        let tweet = try FixtureLoader.decode(Tweet.self, named: "tweet")
        XCTAssertEqual(tweet.hash, "abc123hash")
        XCTAssertEqual(tweet.tid, "42001")
        XCTAssertEqual(tweet.channelId, "sf")
        XCTAssertEqual(tweet.retweetedByTid, "9007199254740993")
        XCTAssertEqual(tweet.id, "abc123hash-rt-9007199254740993")
    }

    func testUserFixture() throws {
        let user = try FixtureLoader.decode(User.self, named: "user")
        XCTAssertEqual(user.tid, "42001")
        XCTAssertEqual(user.followingCount, 12)
        XCTAssertEqual(user.followersCount, 34)
        XCTAssertEqual(user.displayName, "Alice")
    }

    func testChannelFixture() throws {
        let channel = try FixtureLoader.decode(Channel.self, named: "channel")
        XCTAssertEqual(channel.id, "sf")
        XCTAssertTrue(channel.isCity)
        XCTAssertEqual(channel.tweetCount, 128)
    }

    func testEventFixture() throws {
        let event = try FixtureLoader.decode(Event.self, named: "event")
        XCTAssertEqual(event.creatorTid, "42001")
        XCTAssertEqual(event.yesCount, 7)
    }

    func testPollFixture() throws {
        let poll = try FixtureLoader.decode(Poll.self, named: "poll")
        XCTAssertEqual(poll.options.count, 2)
        XCTAssertEqual(poll.totalVotes, 15)
    }

    func testTaskFixture() throws {
        let task = try FixtureLoader.decode(TaskItem.self, named: "task")
        XCTAssertEqual(task.status, "open")
        XCTAssertNil(task.claimedByTid)
    }

    func testCrowdfundFixture() throws {
        let fund = try FixtureLoader.decode(Crowdfund.self, named: "crowdfund")
        XCTAssertEqual(fund.goalAmount, Decimal(string: "5000"))
        XCTAssertGreaterThan(fund.progress, 0)
    }

    func testDMConversationFixture() throws {
        let convo = try FixtureLoader.decode(DMConversation.self, named: "dm_conversation")
        XCTAssertEqual(convo.peerTid, "42002")
        XCTAssertEqual(convo.unreadCount, 1)
    }

    func testDMMessageFixture() throws {
        let msg = try FixtureLoader.decode(DMMessage.self, named: "dm_message")
        XCTAssertEqual(msg.senderTid, "42002")
    }

    func testNotificationListSkipsUnknownRows() throws {
        let list = try FixtureLoader.decode(NotificationListResponse.self, named: "notification")
        XCTAssertEqual(list.notifications.count, 1)
        XCTAssertEqual(list.notifications[0].type, .follow)
    }

    func testTipFixture() throws {
        let tip = try FixtureLoader.decode(Tip.self, named: "tip")
        XCTAssertEqual(tip.amount, Decimal(string: "0.25"))
    }

    func testActivityFixture() throws {
        let row = try FixtureLoader.decode(ActivityRow.self, named: "activity")
        XCTAssertEqual(row.type, .followSettled)
        XCTAssertTrue(row.type.isOnChain)
    }

    func testKarmaFixture() throws {
        let karma = try FixtureLoader.decode(KarmaSummary.self, named: "karma")
        XCTAssertEqual(karma.total, 420)
        XCTAssertEqual(karma.breakdown.followers, 100)
    }

    func testFeedPageFixture() throws {
        let page = try FixtureLoader.decode(FeedPage.self, named: "feed_page")
        XCTAssertEqual(page.tweets.count, 2)
        XCTAssertEqual(page.cursor, "cur-abc")
    }
}
