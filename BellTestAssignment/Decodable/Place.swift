//
//  Place.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

import Foundation

// MARK: - Place
struct Place: Decodable {
    let boundingBox: BoundingBox
    let country, countryCode, fullName, id: String
    let name, placeType: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case boundingBox = "bounding_box"
        case country
        case countryCode = "country_code"
        case fullName = "full_name"
        case id, name
        case placeType = "place_type"
        case url
    }
}

// MARK: - BoundingBox
struct BoundingBox: Codable {
    let coordinates: [[[Double]]]
    let type: String
}
