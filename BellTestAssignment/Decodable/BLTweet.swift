//
//  BLTweet.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

class BLTweet: NSObject, Decodable {
    let id: Int = 0
    let text: String?
    let author: BLAuthor
    let profileImageUrlHttps: String?
    let place: BLPlace?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case author = "user"
        case profileImageUrlHttps = "profile_image_url_https"
        case place
    }
}

class BLAuthor: NSObject, Decodable {
    let screenName: String
    
    enum CodingKeys: String, CodingKey {
        case screenName = "screen_name"
    }
}
