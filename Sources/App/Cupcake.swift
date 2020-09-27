//
//  Juice.swift
//  App
//
//  Created by metalbee on 8/24/20.
//

import FluentPostgreSQL
import Foundation
import Vapor

struct Juice: Content, PostgreSQLModel, Migration {
    var id: Int?
    var name: String
    var description: String
    var price: Int
}
