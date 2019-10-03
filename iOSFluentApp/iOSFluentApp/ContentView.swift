//
//  ContentView.swift
//  iOSFluentApp
//
//  Created by Alex Reilly on 10/3/19.
//  Copyright © 2019 Alex Reilly. All rights reserved.
//

import SwiftUI
import FluentSQLiteDriver

struct DatabaseManager {
  let group: MultiThreadedEventLoopGroup
  public let pool: NIOThreadPool
  public var connectionPool: ConnectionPool<SQLiteConnectionSource>!

  init() {
    self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    self.pool = .init(numberOfThreads: 2)
    let db = SQLiteConnectionSource(configuration: .init(storage: .memory), threadPool: self.pool, on: self.group.next())
    self.connectionPool = ConnectionPool(config: .init(maxConnections: 8), source: db)
  }
}

struct ContentView: View {
  @State var count = 0
  let databaseManager = DatabaseManager()

  var body: some View {
    Group {
      Button(action: {
        print("Prepare")
        var databases = Databases(on: self.databaseManager.connectionPool.eventLoop)
        databases.add(self.databaseManager.connectionPool, as: .init(string: "main"))

        var migrations = Migrations()
        migrations.add(CreateTodo())

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
        Todo(title: "hello \(self.count)")
          .save(on: self.databaseManager.connectionPool)
          .whenSuccess {
            print("Saved")
          }
        self.count += 1
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
