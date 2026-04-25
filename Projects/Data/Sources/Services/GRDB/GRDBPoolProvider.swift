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
                table.autoIncrementedPrimaryKey("id").unique()
                table.column("createdAt", .date).notNull()
                table.column("mass", .double).notNull()
                table.column("massDifference", .double)
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
