import Foundation
import SwiftUI
import TribeCore

/// Top-level app state for the hyperlocal Tribe client.
@MainActor
final class AppState: ObservableObject {
    enum Phase: Equatable {
        case onboarding
        case ready
    }

    @Published var phase: Phase

    @Published var hubBaseURL: URL {
        didSet {
            UserDefaults.standard.set(hubBaseURL.absoluteString, forKey: Keys.hubURL)
            api = HubClient(baseURL: hubBaseURL)
        }
    }

    @Published var erBaseURL: URL {
        didSet {
            UserDefaults.standard.set(erBaseURL.absoluteString, forKey: Keys.erURL)
            er = ERClient(baseURL: erBaseURL)
        }
    }

    @Published var myTID: String? {
        didSet { persistTID(); recomputePhase() }
    }

    @Published private(set) var appKey: AppKey? {
        didSet { recomputePhase() }
    }

    @Published private(set) var dmKey: DMKey?

    @Published var myUsername: String?
    @Published var walletAddress: String?

    /// Selected city channel (kind == 2). Drives feed scoping in later phases.
    @Published var currentCity: Channel? {
        didSet { persistCurrentCity() }
    }

    /// Channels this TID has joined (interest + city).
    @Published var joinedChannels: [Channel] = [] {
        didSet { persistJoinedChannelIds() }
    }

    private(set) var api: HubClient
    private(set) var er: ERClient
    let interactions: InteractionCache
    let tipStats: OnchainTipStatsCache
    let userAvatars: UserAvatarCache

    init() {
        Blake3.selfTest()
        NaClBox.selfTest()

        let storedURL = UserDefaults.standard.string(forKey: Keys.hubURL)
            .flatMap(URL.init(string:)) ?? Config.defaultHubURL
        let storedERURL = UserDefaults.standard.string(forKey: Keys.erURL)
            .flatMap(URL.init(string:)) ?? Config.defaultERURL
        let storedTID = UserDefaults.standard.string(forKey: Keys.tid)

        let restoredKey: AppKey?
        if let seed = try? KeychainStore.load(.appKeySeed),
           seed.count == 32,
           let restored = try? AppKey.restore(seedBase64: seed.base64EncodedString()) {
            restoredKey = restored
        } else {
            restoredKey = nil
        }

        self.hubBaseURL = storedURL
        self.erBaseURL = storedERURL
        self.myTID = storedTID
        self.api = HubClient(baseURL: storedURL)
        self.er = ERClient(baseURL: storedERURL)
        self.appKey = restoredKey
        self.phase = (storedTID != nil && restoredKey != nil) ? .ready : .onboarding

        self.interactions = InteractionCache()
        self.tipStats = OnchainTipStatsCache()
        self.userAvatars = UserAvatarCache()
        self.interactions.attach(to: self)
        self.tipStats.attach(to: self)
        self.userAvatars.attach(to: self)

        if let tid = storedTID {
            Task { [weak self] in await self?.refreshIdentityMetadata(tid: tid) }
        }
        Task { [weak self] in await self?.hydrateChannelState() }
    }

    func adopt(tid: String, appKey: AppKey) throws {
        try KeychainStore.save(appKey.privateKey.rawRepresentation, for: .appKeySeed)
        self.appKey = appKey
        self.myTID = tid
        Task { [weak self] in
            await self?.refreshIdentityMetadata(tid: tid)
            await self?.interactions.refresh()
            await self?.hydrateChannelState()
        }
    }

    func signOut() {
        try? KeychainStore.delete(.appKeySeed)
        DMKey.clearKeychain()
        appKey = nil
        dmKey = nil
        myTID = nil
        myUsername = nil
        walletAddress = nil
        currentCity = nil
        joinedChannels = []
        UserDefaults.standard.removeObject(forKey: Keys.currentCityId)
        UserDefaults.standard.removeObject(forKey: Keys.joinedChannelIds)
        interactions.clear()
        tipStats.clear()
        userAvatars.clear()
    }

    @discardableResult
    func ensureDMKey() async throws -> DMKey {
        if let dm = dmKey { return dm }
        let key = try DMKey.loadOrCreate()
        await MainActor.run { self.dmKey = key }
        if let appKey, let myTID {
            _ = try? await api.registerDMKey(
                publicKey: key.publicKey,
                as: appKey,
                tid: myTID
            )
        }
        return key
    }

    func refreshIdentityMetadata() async {
        guard let tid = myTID else { return }
        await refreshIdentityMetadata(tid: tid)
    }

    /// Restore `currentCity` and `joinedChannels` from UserDefaults, then
    /// reconcile against the hub channel list when reachable.
    func hydrateChannelState() async {
        let storedCityId = UserDefaults.standard.string(forKey: Keys.currentCityId)
        let storedJoinedIds = UserDefaults.standard.stringArray(forKey: Keys.joinedChannelIds) ?? []

        do {
            let allChannels = try await api.fetchChannels()
            if let cityId = storedCityId {
                currentCity = allChannels.first { $0.id == cityId && $0.isCity }
            }
            if !storedJoinedIds.isEmpty {
                let joined = allChannels.filter { storedJoinedIds.contains($0.id) }
                if !joined.isEmpty {
                    joinedChannels = joined
                }
            }
            if let tid = myTID {
                let hubJoined = try await api.fetchJoinedChannels(tid)
                if !hubJoined.isEmpty {
                    joinedChannels = hubJoined
                    persistJoinedChannelIds()
                }
            }
        } catch {
            // Hub offline — keep persisted ids only; city object may stay nil.
        }
    }

    private func refreshIdentityMetadata(tid: String) async {
        do {
            let user = try await api.fetchUser(tid)
            self.myUsername = user.username
            self.walletAddress = user.custodyAddress
        } catch {}
    }

    private func persistTID() {
        if let tid = myTID {
            UserDefaults.standard.set(tid, forKey: Keys.tid)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.tid)
        }
    }

    private func persistCurrentCity() {
        if let id = currentCity?.id {
            UserDefaults.standard.set(id, forKey: Keys.currentCityId)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.currentCityId)
        }
    }

    private func persistJoinedChannelIds() {
        let ids = joinedChannels.map(\.id)
        UserDefaults.standard.set(ids, forKey: Keys.joinedChannelIds)
    }

    private func recomputePhase() {
        phase = (myTID != nil && appKey != nil) ? .ready : .onboarding
    }

    func lastNotificationsReadAt(tid: String) -> Date? {
        let raw = UserDefaults.standard.double(forKey: Keys.notificationsReadAt(tid))
        return raw > 0 ? Date(timeIntervalSince1970: raw) : nil
    }

    func markNotificationsRead(tid: String) {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Keys.notificationsReadAt(tid))
    }

    private enum Keys {
        static let hubURL = "tribe.hubBaseURL"
        static let erURL = "tribe.erBaseURL"
        static let tid = "tribe.tid"
        static let currentCityId = "tribe.currentCityId"
        static let joinedChannelIds = "tribe.joinedChannelIds"
        static func notificationsReadAt(_ tid: String) -> String {
            "tribe.notificationsReadAt.\(tid)"
        }
    }
}
