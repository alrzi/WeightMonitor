import Foundation

enum OutboxDBMappingError: Error {
    case invalidEnvelope
    case logicalCounterOverflow
}
