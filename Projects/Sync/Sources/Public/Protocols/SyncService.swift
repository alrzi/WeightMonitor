import Foundation

public protocol SyncService: Sendable {
    /// Запускает приём входящих событий и первичную синхронизацию.
    ///
    /// Повторные вызовы не должны создавать дополнительные циклы обработки.
    nonisolated func start()

    /// Отменяет обработку событий синхронизации, если она запущена.
    nonisolated func stop()
}
