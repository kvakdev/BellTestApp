//
//  BLTweet.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

class BLTweet: NSObject, Decodable {
    var id: Int = 0
    var text: String?
//    var name: String = ""
    var screenName: String?
    var profileImageUrlHttps: String?
    var place: BLPlace?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case screenName = "screen_name"
//        case name
        case profileImageUrlHttps = "profile_image_url_https"
        case place
    }
}
