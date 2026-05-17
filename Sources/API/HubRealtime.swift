import Foundation

/// Hub client WebSocket (`GET /v1/ws`) — shared connection for feed refresh hooks.
@MainActor
final class HubRealtime {
    static let shared = HubRealtime()

    struct Event {
        let name: String
        let data: [String: Any]
    }

    private var handlers: [UUID: (Event) -> Void] = [:]
    private var connectionTask: Task<Void, Never>?
    private var hubURL: URL?

    private init() {}

    func setHubURL(_ url: URL) {
        guard hubURL != url else { return }
        hubURL = url
        restart()
    }

    @discardableResult
    func subscribe(_ handler: @escaping (Event) -> Void) -> UUID {
        let id = UUID()
        handlers[id] = handler
        if connectionTask == nil, let hubURL {
            startConnection(hubURL: hubURL)
        }
        return id
    }

    func unsubscribe(_ id: UUID) {
        handlers.removeValue(forKey: id)
        if handlers.isEmpty {
            connectionTask?.cancel()
            connectionTask = nil
        }
    }

    private func restart() {
        connectionTask?.cancel()
        connectionTask = nil
        if !handlers.isEmpty, let hubURL {
            startConnection(hubURL: hubURL)
        }
    }

    private func startConnection(hubURL: URL) {
        connectionTask = Task {
            await runLoop(hubURL: hubURL)
        }
    }

    private func runLoop(hubURL: URL) async {
        var backoff: UInt64 = 1_000_000_000
        while !Task.isCancelled, !handlers.isEmpty {
            guard let wsURL = websocketURL(hubURL) else { return }
            do {
                let session = URLSession(configuration: .default)
                let socket = session.webSocketTask(with: wsURL)
                socket.resume()
                defer { socket.cancel(with: .goingAway, reason: nil) }
                backoff = 1_000_000_000
                try await receiveLoop(socket: socket)
            } catch {
                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: backoff)
                backoff = min(backoff * 2, 30_000_000_000)
            }
        }
    }

    private func receiveLoop(socket: URLSessionWebSocketTask) async throws {
        while !Task.isCancelled {
            let message = try await socket.receive()
            let text: String
            switch message {
            case .string(let s):
                text = s
            case .data(let data):
                text = String(data: data, encoding: .utf8) ?? ""
            @unknown default:
                continue
            }
            guard let event = parseEvent(text) else { continue }
            for handler in handlers.values {
                handler(event)
            }
        }
    }

    private func parseEvent(_ text: String) -> Event? {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let name = json["event"] as? String else { return nil }
        let payload = json["data"] as? [String: Any] ?? [:]
        return Event(name: name, data: payload)
    }

    private func websocketURL(_ httpURL: URL) -> URL? {
        var components = URLComponents(url: httpURL, resolvingAgainstBaseURL: false)
        if components?.scheme == "https" {
            components?.scheme = "wss"
        } else {
            components?.scheme = "ws"
        }
        components?.path = "/v1/ws"
        components?.query = nil
        return components?.url
    }
}
