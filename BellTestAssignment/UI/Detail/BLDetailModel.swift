//
//  BLDetailModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import RxSwift
import TwitterKit

protocol PDetailModel {
    var tweet: PublishSubject<TWTRTweet> { get }
    
    func loadDetails()
    func isLoggedIn() -> Bool
    func retweet()
}

class BLDetailModel: PDetailModel {
    var tweet: PublishSubject<TWTRTweet> = .init()
    
    private let _tweetId: String
    private let _service: PTweetAPIService
    private var _tweet: TWTRTweet?
    
    init(tweetId: String, searchService: PTweetAPIService) {
        self._tweetId = tweetId
        self._service = searchService
    }
    
    func loadDetails() {
        _service.fetchTweet(id: _tweetId) { [weak self] result in
            switch result {
            case .success(let tweet):
                self?._tweet = tweet
                self?.tweet.onNext(tweet)
            case .failure(let error):
                self?.tweet.onError(error ?? NSError.noData())
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        return _service.isLoggedIn()
    }
    
    func retweet() {
        _service.retweet(tweetId: _tweetId) { result in
            debugPrint(result)
        }
    }
    
    func retweet() {
        _service.like(tweetId: _tweetId) { result in
            debugPrint(result)
        }
    }
}
