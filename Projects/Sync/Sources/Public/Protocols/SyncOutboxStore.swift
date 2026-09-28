import Foundation

public struct SyncRetryPolicy: Sendable {
    public let maximumAttemptCount: Int
    public let acknowledgementTimeout: TimeInterval

    public init(
        maximumAttemptCount: Int,
        acknowledgementTimeout: TimeInterval
    ) {
        precondition(maximumAttemptCount > 0)
        precondition(acknowledgementTimeout > 0)

        self.maximumAttemptCount = maximumAttemptCount
        self.acknowledgementTimeout = acknowledgementTimeout
    }
}

public protocol SyncOutboxStore: Sendable {
    /// Emits when the number of persisted outbox records changes.
    ///
    /// Implementations should emit the current count first, then distinct counts.
    /// Status updates to existing records must not produce an event.
    func observePayloadCount() async -> AsyncThrowingStream<Int, any Error>

    /// Возвращает payload, которые разрешено отправить согласно retry policy.
    ///
    /// Результат не должен включать подтверждённые записи, записи с исчерпанным
    /// лимитом попыток и записи, для которых ещё не истекло ожидание acknowledgement.
    ///
    /// - Throws: Ошибка чтения исходящей очереди.
    func retryablePayloads() async throws -> [SyncPayload]

    /// Фиксирует начало очередной попытки отправки payload.
    ///
    /// Реализация должна обновить статус, счётчик попыток и время попытки атомарно.
    ///
    /// - Throws: Ошибка изменения исходящей очереди.
    func markSending(payloadID: UUID) async throws

    /// Переводит отправленный payload в ожидание подтверждения другого устройства.
    ///
    /// - Throws: Ошибка изменения исходящей очереди.
    func markAwaitingAcknowledgement(payloadID: UUID) async throws

    /// Помечает завершившуюся ошибкой попытку отправки payload.
    ///
    /// Возможность следующей попытки определяется retry policy и сохранённым
    /// количеством предыдущих попыток.
    ///
    /// - Throws: Ошибка изменения исходящей очереди.
    func markFailed(payloadID: UUID) async throws

    /// Помечает payload подтверждённым и исключает его из повторных отправок.
    ///
    /// - Throws: Ошибка изменения исходящей очереди.
    func markSynced(payloadID: UUID) async throws
}
