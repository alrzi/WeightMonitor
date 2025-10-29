//
//  GRDBPoolProvider.swift
//  WeigthMonitorData
//
//  Created by Александр Зиновьев on 25.10.2025.
//

import Foundation
internal import GRDB

struct GRDBPoolProvider: Sendable {
    func createDBPool() throws -> DatabasePool {
        let url = URL.documentsDirectory.appending(component: "db.sqlite")
        let path = url.path()

        var config = Configuration()
        config.foreignKeysEnabled = true

        let dbPool = try DatabasePool(path: path, configuration: config)

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

        try migrator.migrate(dbPool)
        return dbPool
    }
}

actor Box<V: Sendable> {
    private(set) var value: V

    init(value: V) {
        self.value = value
    }

    func set(value: V) {
        self.value = value
    }
}
