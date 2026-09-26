import Foundation

/// Состояние payload в исходящей очереди синхронизации.
public enum OutboxStatus: String, Codable, CaseIterable, Sendable {
    /// Payload создан и ожидает первой отправки.
    case pending

    /// Выполняется попытка передачи payload транспорту.
    case sending

    /// Транспорт принял payload, но другое устройство ещё не прислало acknowledgement.
    case awaitingAcknowledgement

    /// Другое устройство подтвердило успешную обработку payload.
    case synced

    /// Последняя попытка передачи завершилась ошибкой.
    case failed
}
