//
//  Tweet.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public class Tweet: NSObject, Decodable {
    let id: String
    let text: String
    let author: Author
    let profileImageUrlHttps: String?
    let place: Place?
    var sortIndex: Int { return Int(id) ?? 0 }
    
    enum CodingKeys: String, CodingKey {
        case id = "id_str"
        case text
        case author = "user"
        case profileImageUrlHttps = "profile_image_url_https"
        case place
    }
    
    init(id: String, text: String, author: Author) {
        self.id = id
        self.text = text
        self.author = author
        self.profileImageUrlHttps = nil
        self.place = nil
        
        super.init()
    }
}

public class Author: NSObject, Decodable {
    let screenName: String
    
    enum CodingKeys: String, CodingKey {
        case screenName = "screen_name"
    }
    
    init(name: String) {
        self.screenName = name
    }
}
