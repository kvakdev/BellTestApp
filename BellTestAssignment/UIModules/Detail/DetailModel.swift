//
//  DetailModel.swift
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
    func retweet(completion: ((AsyncResult<Bool>) -> Void)?)
    func like(completion: ((AsyncResult<Bool>) -> Void)?)
}

class DetailModel: PDetailModel {
    var tweet: PublishSubject<TWTRTweet> = .init()
    
    private let tweetId: String
    private let service: PTweetAPIService
    
    init(tweetId: String, searchService: PTweetAPIService) {
        self.tweetId = tweetId
        self.service = searchService
    }
    
    func loadDetails() {
        service.fetchTweet(id: tweetId) { [weak self] result in
            switch result {
            case .success(let tweet):
                self?.tweet.onNext(tweet)
            case .failure(let error):
                self?.tweet.onError(error ?? NSError.noData())
            }
        }
    }
    
    func isLoggedIn() -> Bool {
        return service.isLoggedIn()
    }
    
    func retweet(completion: ((AsyncResult<Bool>) -> Void)?) {
        service.retweet(tweetNumId: tweetId) { result in
            completion?(result)
        }
    }
    
    func like(completion: ((AsyncResult<Bool>) -> Void)?) {
        service.like(tweetId: tweetId) { result in
            completion?(result)
        }
    }
}
