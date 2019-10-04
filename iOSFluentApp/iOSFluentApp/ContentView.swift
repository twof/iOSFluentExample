//
//  ContentView.swift
//  iOSFluentApp
//
//  Created by Alex Reilly on 10/3/19.
//  Copyright © 2019 Alex Reilly. All rights reserved.
//

import SwiftUI
import FluentSQLiteDriver

struct PersistentDatabaseManager {
  let group: MultiThreadedEventLoopGroup
  public let pool: NIOThreadPool
  public var connectionPool: ConnectionPool<SQLiteConnectionSource>!

  init() {
    self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    self.pool = .init(numberOfThreads: 2)
    let db = SQLiteConnectionSource(
      configuration: .init(
        storage: .connection(
          .file(
            path: "\(PersistentDatabaseManager.getDocumentsDirectory().path)/default.sqlite"
          )
        )
      ), threadPool: self.pool, on: self.group.next()
    )
    self.connectionPool = ConnectionPool(config: .init(maxConnections: 8), source: db)
  }

  static func getDocumentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
  }
}

struct InMemoryDatabaseManager {
  let group: MultiThreadedEventLoopGroup
  public let pool: NIOThreadPool
  public var connectionPool: ConnectionPool<SQLiteConnectionSource>!

  init() {
    self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    self.pool = .init(numberOfThreads: 2)
    let db = SQLiteConnectionSource(
      configuration: .init(
        storage: .connection(.memory)
      ), threadPool: self.pool, on: self.group.next()
    )
    self.connectionPool = ConnectionPool(config: .init(maxConnections: 8), source: db)
  }
}

struct ContentView: View {
  let databaseManager = PersistentDatabaseManager()

  var body: some View {
    Group {
      Button(action: {
        print("Revert")
        var databases = Databases(on: self.databaseManager.connectionPool.eventLoop)
        databases.add(self.databaseManager.connectionPool, as: .init(string: "main"))

        var migrations = Migrations()
        migrations.add(CreateTodo())
        migrations.add(CreateCurrentCount())

        let migrator = Migrator(
          databases: databases,
          migrations: migrations,
          on: self.databaseManager.connectionPool.eventLoop
        )

        migrator.revertAllBatches().whenSuccess {
          print("Reverted")
        }
      }) {
        Text("Revert")
      }
      Button(action: {
        print("Prepare")
        var databases = Databases(on: self.databaseManager.connectionPool.eventLoop)
        databases.add(self.databaseManager.connectionPool, as: .init(string: "main"))

        var migrations = Migrations()
        migrations.add(CreateTodo())
        migrations.add(CreateCurrentCount())

        let migrator = Migrator(
          databases: databases,
          migrations: migrations,
          on: self.databaseManager.connectionPool.eventLoop
        )

        migrator
          .setupIfNeeded()
          .flatMap {
            migrator.prepareBatch()
          }.whenSuccess {
            print("Prepared")
          }
      }) {
        Text("Prepare")
      }
      Button(action: {
        print("Create")
        CurrentCount.query(on: self.databaseManager.connectionPool).all().map { (counts: [CurrentCount]) -> Int in
          return counts.max { $0.count < $1.count }?.count ?? 0
        }.flatMap { count in
          return Todo(title: "hello \(count)")
            .save(on: self.databaseManager.connectionPool)
            .map {
              print("Saved")
              return count
            }
        }.whenSuccess {
          CurrentCount(count: $0 + 1)
            .save(on: self.databaseManager.connectionPool)
            .whenSuccess { print("Current count updated") }
        }
      }) {
        Text("Create")
      }

      Button(action: {
        print("Fetch")
        Todo
          .query(on: self.databaseManager.connectionPool)
          .all()
          .whenSuccess { (todos) in
            print(todos.map { $0.title })
          }
      }) {
        Text("Fetch")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
