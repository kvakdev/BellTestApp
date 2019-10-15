//
//  TWTRTweet+Parsing.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import TwitterKit

public extension TWTRTweet {
    static func tweetArrayWith(data: Data) -> [TWTRTweet]? {
        guard
            let dict = data.dictionary,
            let tweetsArray = dict["statuses"] as? [[AnyHashable : Any]],
            let tweets = TWTRTweet.tweets(withJSONArray: tweetsArray) as? [TWTRTweet] else {
                return nil
        }
        return tweets
    }
}
