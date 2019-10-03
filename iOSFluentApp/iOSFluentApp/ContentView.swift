//
//  ContentView.swift
//  iOSFluentApp
//
//  Created by Alex Reilly on 10/3/19.
//  Copyright © 2019 Alex Reilly. All rights reserved.
//

import SwiftUI
import FluentSQLite

struct DatabaseManager {
  let db: SQLiteDatabase
  let group: MultiThreadedEventLoopGroup
  let test: DatabaseIdentifier<SQLiteDatabase>
  var config: DatabasesConfig
  let container: BasicContainer
  let databases: Databases
  public let pool: DatabaseConnectionPool<ConfiguredDatabase<SQLiteDatabase>>

  init() {
    self.db = try! SQLiteDatabase(storage: .memory)
    self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    self.test = "test"
    self.config = DatabasesConfig()
    config.add(database: db, as: test)
    self.container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: group)
    self.databases = try! config.resolve(on: container)
    self.pool = try! databases.requireDatabase(for: test).newConnectionPool(config: .init(maxConnections: 20), on: self.group)
  }
}

struct ContentView: View {
  @State var count = 0
  let databaseManager = DatabaseManager()

  var body: some View {
    Group {
      Button(action: {
        print("Prepare")
        self.databaseManager.pool.requestConnection().whenSuccess { (conn) in
          Todo.prepare(on: conn).whenComplete {
            print("Prepared")
          }
        }
      }) {
        Text("Prepare")
      }
      Button(action: {
        print("Create")
        self.databaseManager.pool.requestConnection().whenSuccess { (conn) in
          Todo(title: "hello \(self.count)").save(on: conn).whenComplete {
            print("Saved")
          }
          self.count += 1
        }
      }) {
        Text("Create")
      }

      Button(action: {
        print("Fetch")
        self.databaseManager.pool.requestConnection().whenSuccess { (conn) in
          Todo.query(on: conn).all().whenSuccess { (todos) in
            print(todos.map { $0.title })
          }
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
