//
//  Post.swift
//  PerfectAPIClientTests
//
//  Created by Sven Tiigi on 28.10.17.
//

import ObjectMapper

/// Post represents JSON object fetched from JSONPlaceholder API
struct Post {
    /// The title
    var title: String?
    /// The body
    var body: String?
}

// MARK: Mappable

extension Post: Mappable {
    
    /// Object Mapping initializer
    init?(map: Map) {}
    
    /// Mapping
    mutating func mapping(map: Map) {
        self.title      <- map["title"]
        self.body       <- map["body"]
    }
    
}

// MARK: Equatable

extension Post: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// Equatable
    public static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.title == rhs.title
            && lhs.body == rhs.body
    }
    
}
