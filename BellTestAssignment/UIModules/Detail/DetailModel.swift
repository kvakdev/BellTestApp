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

public protocol DetailModelProtocol {
    var tweet: PublishSubject<TWTRTweet> { get }
    
    func loadDetails()
    func retweet(completion: ((AsyncResult<Bool>) -> Void)?)
    func like(completion: ((AsyncResult<Bool>) -> Void)?)
}

public class DetailModel: DetailModelProtocol {
    public var tweet: PublishSubject<TWTRTweet> = .init()
    
    private let tweetId: String
    private let service: TweetAPIProtocol
    
    init(tweetId: String, searchService: TweetAPIProtocol) {
        self.tweetId = tweetId
        self.service = searchService
    }
    
    public func loadDetails() {
        service.fetchTweet(id: tweetId) { [weak self] result in
            switch result {
            case .success(let tweet):
                self?.tweet.onNext(tweet)
            case .failure(let error):
                self?.tweet.onError(error ?? NSError.noData())
            }
        }
    }

    public func retweet(completion: ((AsyncResult<Bool>) -> Void)?) {
        service.retweet(tweetNumId: tweetId) { result in
            completion?(result)
        }
    }
    
    public func like(completion: ((AsyncResult<Bool>) -> Void)?) {
        service.like(tweetId: tweetId) { result in
            completion?(result)
        }
    }
}
