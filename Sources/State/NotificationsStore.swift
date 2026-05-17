import Foundation

@MainActor
final class NotificationsStore: ObservableObject {
    @Published private(set) var unreadCount = 0
    @Published private(set) var items: [TribeNotification] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private weak var app: AppState?

    func attach(to app: AppState) {
        self.app = app
    }

    func refreshUnread() async {
        guard let app, let tid = app.myTID else {
            unreadCount = 0
            return
        }
        let since = app.lastNotificationsReadAt(tid: tid)
        do {
            unreadCount = try await app.api.fetchUnreadCount(tid, since: since)
        } catch {
            unreadCount = 0
        }
    }

    func refreshList() async {
        guard let app, let tid = app.myTID else {
            items = []
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            items = try await app.api.fetchNotifications(tid)
            await refreshUnread()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllRead() {
        guard let app, let tid = app.myTID else { return }
        app.markNotificationsRead(tid: tid)
        unreadCount = 0
    }

    func clear() {
        unreadCount = 0
        items = []
        errorMessage = nil
    }
}
