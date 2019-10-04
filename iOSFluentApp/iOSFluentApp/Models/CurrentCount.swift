//
//  CurrentCount.swift
//  iOSFluentApp
//
//  Created by Alex Reilly on 10/3/19.
//  Copyright © 2019 Alex Reilly. All rights reserved.
//

import FluentKit

final class CurrentCount: Model {
    static let schema = "current_count"

    @ID(key: "id")
    var id: Int?

    @Field(key: "count")
    var count: Int

    init() { }

    init(id: Int? = nil, count: Int) {
        self.id = id
        self.count = count
    }
}

struct CreateCurrentCount: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("current_count")
            .field("id", .int, .identifier(auto: true))
            .field("count", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("current_count").delete()
    }
}

