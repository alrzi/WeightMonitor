//
//  GRDBPoolProvider.swift
//  WeigthMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import GRDB

public struct GRDBPoolProvider: Sendable {
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

    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("v1") { db in
            try db.create(table: WeightDB.databaseTableName) { t in
                t.autoIncrementedPrimaryKey("id").unique()
                t.column("createdAt", .date).notNull()
                t.column("mass", .double).notNull()
                t.column("massDifference", .double)
            }
        }

        return migrator
    }
}
