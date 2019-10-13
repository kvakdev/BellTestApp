//
//  BLSearchModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import TwitterKit

protocol PSearchModel {
    func search(query: String, completion: ((AsyncResult<[TWTRTweet]>) -> Void)?)
}

class BLSearchModel: PSearchModel {
    private let _searchService: PTweetAPIService
    private var _currentQuery: String = ""
    
    init(_ searchService: PTweetAPIService) {
        _searchService = searchService
    }
    
    func search(query: String, completion: ((AsyncResult<[TWTRTweet]>) -> Void)?) {
        _currentQuery = query
        if query.trimmed.isEmpty {
            completion?(.success([]))
            return
        }
        
        _searchService.querySearchTweets(query: query, count: 100, completion: { [weak self] result in
            guard self?._currentQuery == query else { return }
            
            completion?(result)
        })
    }
}


