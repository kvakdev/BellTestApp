//
//  SearchMetadata.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

class SearchMetaData: Codable {
    let maxID: Double
    let sinceID: Int
    let sinceIDStr, maxIDStr, refreshURL: String
    let count: Int
    let query, nextResults: String
    let completedIn: Double
    
    enum CodingKeys: String, CodingKey {
        case maxID = "max_id"
        case sinceID = "since_id"
        case sinceIDStr = "since_id_str"
        case maxIDStr = "max_id_str"
        case refreshURL = "refresh_url"
        case count, query
        case nextResults = "next_results"
        case completedIn = "completed_in"
    }
}
