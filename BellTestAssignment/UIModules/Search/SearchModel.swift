//
//  SearchModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import TwitterKit

public protocol SearchModelProtocol {
    func search(query: String, completion: ((AsyncResult<[TWTRTweet]>) -> Void)?)
}

public class SearchModel: SearchModelProtocol {
    private let searchService: TweetAPIProtocol
    private var currentQuery: String = ""
    
    init(_ searchService: TweetAPIProtocol) {
        self.searchService = searchService
    }
    
    public func search(query: String, completion: ((AsyncResult<[TWTRTweet]>) -> Void)?) {
       currentQuery = query
        if query.trimmed.isEmpty {
            completion?(.success([]))
            return
        }
        
       searchService.querySearchTweets(query: query, count: 100, completion: { [weak self] result in
            guard self?.currentQuery == query else { return }
            completion?(result)
        })
    }
}


