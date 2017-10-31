//
//  User.swift
//  PerfectAPIClientTests
//
//  Created by Sven Tiigi on 28.10.17.
//

import ObjectMapper

struct User {
    /// The users full name
    var name: String?
    /// The user type
    var type: String?
}

// MARK: Mappable

extension User: Mappable {
    
    /// ObjectMapper initializer
    init?(map: Map) {}
    
    /// Mapping
    mutating func mapping(map: Map) {
        self.name   <- map["name"]
        self.type   <- map["type"]
    }
}
