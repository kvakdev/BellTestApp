//
//  RadiusSearchResponse.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public class RadiusSearchResponse: Decodable {
    let metadata: SearchMetaData
    let tweets: [Tweet]
    
    enum CodingKeys: String, CodingKey {
        case tweets = "statuses"
        case metadata = "search_metadata"
    }
}
