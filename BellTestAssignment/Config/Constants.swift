//
//  Config.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

enum Constants {
    //keys
    static let apiKey       = "QBhGCo1R9YnWSImo69vbDgCyR"
    static let apiSecret    = "QvoyYu6h4dfSBhgTdLEUh8Gf5lmiA3lvLHC36fBBun8tpqnlm0"
    //tokens
    static let accessToken = "1044483415821750273-mFx1jgsGTi4gxtziFszQwlzKj4pPuK"
    static let accessTokenSecret = "DDYGMTga490jbI9qxl1ckE4GefA1vpwLcJqyrXabCDqOj"
    
    static let bearerTokenType = "bearer"
    static let bearerToken = "AAAAAAAAAAAAAAAAAAAAANxKAQEAAAAAI6tFZ2jTQ%2Fh5B%2F0ooSy3Jpy5ciA%3DkrfefmpbFIsFIleSxs4hT4oUrsCSC9vBtXe3gkAC7ZdQ54cwv7"
    
    static let auth = "api.twitter.com/oauth2/token"
    static let authRequestToken = "https://api.twitter.com/oauth/request_token"
    static let authAuthorizeUrl = "https://api.twitter.com/oauth/authorize"
    static let authAccessTokenUrl = "https://api.twitter.com/oauth/access_token"
    
    enum Url {
        static let base = "https://api.twitter.com/1.1/"
    }
}
