import Foundation

@MainActor
final class ToastCenter: ObservableObject {
    @Published private(set) var message: String?

    private var hideTask: Task<Void, Never>?

    func show(_ text: String, duration: Duration = .seconds(2)) {
        hideTask?.cancel()
        message = text
        hideTask = Task {
            try? await Task.sleep(for: duration)
            if !Task.isCancelled {
                message = nil
            }
        }
    }

    func dismiss() {
        hideTask?.cancel()
        message = nil
    }
}
