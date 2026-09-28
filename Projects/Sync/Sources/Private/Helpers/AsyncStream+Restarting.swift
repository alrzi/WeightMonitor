import Foundation

extension AsyncStream where Element: Sendable {
    static func restartingAfterFailure(
        makeStream: @escaping @Sendable () async -> AsyncThrowingStream<Element, any Error>,
        retryDelay: UInt64 = 1_000_000_000,
        onError: @escaping @Sendable (Error) -> Void
    ) -> Self {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    do {
                        for try await value in await makeStream() {
                            continuation.yield(value)
                        }
                    }
                    catch is CancellationError {
                        return
                    }
                    catch {
                        onError(error)
                    }

                    guard !Task.isCancelled else {
                        return
                    }

                    do {
                        try await Task.sleep(nanoseconds: retryDelay)
                    }
                    catch {
                        return
                    }
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
