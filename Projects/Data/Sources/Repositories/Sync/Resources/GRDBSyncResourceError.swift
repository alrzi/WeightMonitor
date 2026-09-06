enum GRDBSyncResourceError: Error {
    case invalidRecordIdentifier
    case missingRecord
    case logicalCounterOverflow
}
