import Foundation
import SwiftUI
import TribeCore

/// Top-level app state for the hyperlocal Tribe client.
@MainActor
final class AppState: ObservableObject {
    enum Phase: Equatable {
        case unloaded
        case connect
        case city
        case ready
    }

    @Published var phase: Phase = .unloaded

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

    @Published var currentCity: Channel? {
        didSet { persistCurrentCity(); recomputePhase() }
    }

    @Published var joinedChannels: [Channel] = [] {
        didSet { persistJoinedChannelIds() }
    }

    /// Full-screen overlay while changing cities (matches tribeapp.wtf shell).
    @Published var isSwitchingCity = false

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

        self.interactions = InteractionCache()
        self.tipStats = OnchainTipStatsCache()
        self.userAvatars = UserAvatarCache()
        self.interactions.attach(to: self)
        self.tipStats.attach(to: self)
        self.userAvatars.attach(to: self)

        Task { [weak self] in await self?.finishBootstrap() }
    }

    private func finishBootstrap() async {
        if let tid = myTID {
            await refreshIdentityMetadata(tid: tid)
        }
        await hydrateChannelState()
        recomputePhase()
    }

    /// Persist identity, register DM key, publish a minimal profile, route to city picker.
    func completeConnect(tid: String, appKey: AppKey, walletAddress: String? = nil) async throws {
        try adopt(tid: tid, appKey: appKey)
        if let walletAddress {
            self.walletAddress = walletAddress
        }
        try await provisionIdentityOnHub()
        recomputePhase()
    }

    func adopt(tid: String, appKey: AppKey) throws {
        try KeychainStore.save(appKey.privateKey.rawRepresentation, for: .appKeySeed)
        self.appKey = appKey
        self.myTID = tid
        Task { [weak self] in
            await self?.refreshIdentityMetadata(tid: tid)
            await self?.interactions.refresh()
        }
    }

    /// User picked a city — persist and enter the main app shell.
    func selectCity(_ channel: Channel) {
        currentCity = channel
        recomputePhase()
    }

    /// Animate a city change from the in-app switcher (header overlay).
    func switchCity(to channel: Channel) async {
        guard channel.id != currentCity?.id else { return }
        isSwitchingCity = true
        defer { isSwitchingCity = false }
        try? await Task.sleep(nanoseconds: 650_000_000)
        currentCity = channel
        await interactions.refresh()
    }

    func isJoined(channelId: String) -> Bool {
        joinedChannels.contains { $0.id == channelId }
    }

    func joinChannel(_ channel: Channel) async throws {
        guard let appKey, let tid = myTID else { return }
        try await api.joinChannel(channel.id, as: appKey, tid: tid)
        if !joinedChannels.contains(where: { $0.id == channel.id }) {
            joinedChannels.append(channel)
        }
    }

    func leaveChannel(_ channel: Channel) async throws {
        guard let appKey, let tid = myTID else { return }
        try await api.leaveChannel(channel.id, as: appKey, tid: tid)
        joinedChannels.removeAll { $0.id == channel.id }
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
        phase = .connect
    }

    @discardableResult
    func ensureDMKey() async throws -> DMKey {
        if let dm = dmKey { return dm }
        let key = try DMKey.loadOrCreate()
        self.dmKey = key
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

    func hydrateChannelState() async {
        let storedCityId = UserDefaults.standard.string(forKey: Keys.currentCityId)
        let storedJoinedIds = UserDefaults.standard.stringArray(forKey: Keys.joinedChannelIds) ?? []

        do {
            let allChannels = try await api.fetchChannels()
            let cityChannels = allChannels.filter(\.isCity)
            if let cityId = storedCityId {
                currentCity = cityChannels.first { $0.id == cityId }
                    ?? allChannels.first { $0.id == cityId && $0.isCity }
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
            if let cityId = storedCityId,
               let entry = CityCatalog.fallback.first(where: { $0.id == cityId }) {
                currentCity = entry.channel
            }
        }
    }

    /// City channels from hub, or static catalog when hub is empty/unreachable.
    func loadCityOptions() async -> (cities: [Channel], usedFallback: Bool, error: String?) {
        do {
            let hubCities = try await api.fetchChannels().filter(\.isCity)
            if !hubCities.isEmpty {
                return (hubCities, false, nil)
            }
            return (CityCatalog.fallback.map(\.channel), true, nil)
        } catch {
            return (CityCatalog.fallback.map(\.channel), true, error.localizedDescription)
        }
    }

    private func provisionIdentityOnHub() async throws {
        guard let appKey, let tid = myTID else { return }
        _ = try await ensureDMKey()
        do {
            let user = try await api.fetchUser(tid)
            myUsername = user.username
            walletAddress = user.custodyAddress.isEmpty ? walletAddress : user.custodyAddress
            let display = user.profile?.displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if display.isEmpty {
                let fallback = user.username.map { "\($0).tribe" } ?? "TID #\(tid)"
                _ = try? await api.updateProfile(
                    field: "displayName",
                    value: fallback,
                    as: appKey,
                    tid: tid
                )
            }
        } catch {
            let fallback = "TID #\(tid)"
            _ = try? await api.updateProfile(
                field: "displayName",
                value: fallback,
                as: appKey,
                tid: tid
            )
        }
    }

    private func refreshIdentityMetadata(tid: String) async {
        do {
            let user = try await api.fetchUser(tid)
            self.myUsername = user.username
            if !user.custodyAddress.isEmpty {
                self.walletAddress = user.custodyAddress
            }
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
        guard myTID != nil, appKey != nil else {
            phase = .connect
            return
        }
        guard currentCity != nil else {
            phase = .city
            return
        }
        phase = .ready
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
