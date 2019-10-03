//
//  Todo.swift
//  iOSFluentApp
//
//  Created by Alex Reilly on 10/3/19.
//  Copyright © 2019 Alex Reilly. All rights reserved.
//
import FluentSQLite

/// A single entry of a Todo list.
final class Todo: SQLiteModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    var title: String

    /// Creates a new `Todo`.
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration { }
