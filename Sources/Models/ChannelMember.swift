import Foundation

/// One row from `GET /v1/channels/:id/members`.
public struct ChannelMember: Decodable, Identifiable, Hashable {
    public let tid: String
    public let username: String?
    public let joinedAt: Date?

    public var id: String { tid }

    enum CodingKeys: String, CodingKey {
        case tid, username
        case joinedAt = "joined_at"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.tid = try HubDecode.bigInt(c, forKey: .tid)
        self.username = try c.decodeIfPresent(String.self, forKey: .username)
        self.joinedAt = try HubDecode.dateIfPresent(c, forKey: .joinedAt)
    }

    public var displayName: String {
        if let u = username { return "\(u).tribe" }
        return "TID #\(tid)"
    }

    public var initial: String {
        if let u = username, let first = u.first { return String(first).uppercased() }
        return String(tid.prefix(1))
    }
}

struct ChannelMemberListResponse: Decodable {
    let members: [ChannelMember]
}
