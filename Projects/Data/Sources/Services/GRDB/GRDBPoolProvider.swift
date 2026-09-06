//
//  GRDBPoolProvider.swift
//  WeightMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import GRDB

public struct GRDBPoolProvider: Sendable {
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
            migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("v1") { db in
            try db.create(table: WeightDB.databaseTableName) { table in
                table.column("id", .text).notNull().primaryKey()
                table.column("createdAt", .date).notNull()
                table.column("mass", .double).notNull()
                table.column("massDifference", .double)
            }

            try db.create(table: SyncMetadataDB.databaseTableName) { table in
                table.column("dataType", .text).notNull()
                table.column("recordID", .text).notNull()
                table.primaryKey(["dataType", "recordID"])
                table.column("physicalTime", .date).notNull()
                table.column("logicalCounter", .integer).notNull()
                table.column("originDeviceID", .text).notNull()
                table.column("isDeleted", .boolean).notNull()
            }

            try db.create(table: OutboxDB.databaseTableName) { table in
                table.column("id", .text).notNull().primaryKey()
                table.column("payload", .blob).notNull()
                table.column("status", .text).notNull()
                table.column("createdAt", .date).notNull()
            }

            try db.create(table: SyncStateDB.databaseTableName) { table in
                table.column("key", .text).notNull().primaryKey()
                table.column("value", .blob).notNull()
            }
        }

        return migrator
    }

    let db: any DatabaseWriter

    public init?() {
        let url = URL.documentsDirectory.appending(component: "db.sqlite")
        let path = url.path()

        var config = Configuration()
        config.foreignKeysEnabled = true

        do {
            let dbPool = try DatabasePool(path: path, configuration: config)
            try Self.migrator.migrate(dbPool)

            db = dbPool
        }
        catch {
            debugPrint(error)
            return nil
        }
    }
}
