//
//  Repository.swift
//  PerfectAPIClientTests
//
//  Created by Sven Tiigi on 12.12.17.
//

import ObjectMapper

struct Repository {
    /// The name
    var name: String?
    /// The full name
    var fullName: String?
}

// MARK: Mappable

extension Repository: Mappable {
    
    /// ObjectMapper initializer
    init?(map: Map) {
    }
    
    /// Mapping
    mutating func mapping(map: Map) {
        self.name       <- map["name"]
        self.fullName   <- map["full_name"]
    }
}

// MARK: Equatable

extension Repository: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// Equatable
    public static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.name == rhs.name
            && lhs.fullName == rhs.fullName
    }
    
}
