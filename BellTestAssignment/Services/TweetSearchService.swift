//
//  TweetSearchService.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import TwitterKit
import CoreLocation

enum AsyncResult<T> {
    case success(T)
    case failure(Error?)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol PTweetAPIService {
    func searchTweets(radius: Int, location: CLLocation, count: Int, completion: @escaping (AsyncResult<[Tweet]>) -> Void, filter: ((Tweet) -> Bool)?)
    func querySearchTweets(query: String, count: Int, completion: @escaping (AsyncResult<[TWTRTweet]>) -> Void)
    func fetchTweet(id: String, completion: @escaping (AsyncResult<TWTRTweet>) -> Void)
    func retweet(tweetNumId: String, completion: ((AsyncResult<Bool>) -> Void)?)
    func like(tweetId: String, completion: ((AsyncResult<Bool>) -> Void)?)
    func isLoggedIn() -> Bool
}


enum Endpoints: String {
    case search = "search/tweets.json"
    case retweet = "statuses/retweet/%@.json"
    case like = "favorites/create.json"
    
    var string: String {
        return Constants.Url.base.appending(rawValue)
    }
}

class TweetSearchService: NSObject, PTweetAPIService {
    let _client: PTwitterClient
    
    init(client: PTwitterClient) {
        _client = client
    }
    
    func isLoggedIn() -> Bool {
        return TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()
    }
    
    func searchTweets(radius: Int, location: CLLocation, count: Int = 1000, completion: @escaping (AsyncResult<[Tweet]>) -> Void, filter: ((Tweet) -> Bool)?) {
        
        let geocode = "\(location.coordinate.latitude),\(location.coordinate.longitude),\(radius)km"
        
        let params: [String: String] = [
            "q" : "",
            "count" : "\(count)",
            "geocode" : geocode,
            "result_type" : "recent"
        ]
        
        let req = _client.urlRequest(with: HTTPMethod.get, endpoint: Endpoints.search, params: params)
        
        _client.sendRequest(req) { (resp, data, error) in
            guard Response.isValid(error: error, data: data, completion: completion) else { return }
//            debugPrint(data.responseString)
            do {
                let result = try JSONDecoder().decode(RadiusSearchResponse.self, from: data!)
                
                if let filter = filter {
                    completion(.success(result.tweets.filter(filter)))
                } else {
                    completion(.success(result.tweets))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func querySearchTweets(query: String, count: Int, completion: @escaping (AsyncResult<[TWTRTweet]>) -> Void) {
        
        let params: [String: String] = [
            "q" : query.urlEncoded,
            "count" : "\(count)"
        ]
        
        let req = _client.urlRequest(with: .get, endpoint: .search, params: params)
        
        _client.sendRequest(req) { (resp, data, error) in
            guard Response.isValid(error: error, data: data, completion: completion) else { return }
            
            if let tweets = TWTRTweet.tweetArrayWith(data: data!) {
                completion(.success(tweets))
            } else {
                completion(.failure(error))
            }
        }
    }
    
    func fetchTweet(id: String, completion: @escaping (AsyncResult<TWTRTweet>) -> Void) {
        _client.loadOneTweet(withID: id) { (tweet, error) in
            guard let tweet = tweet else {
                completion(.failure(NSError.noData()))
                return
            }
            completion(.success(tweet))
        }
    }
    
    func like(tweetId: String, completion: ((AsyncResult<Bool>) -> Void)?) {
        let params = ["id" : tweetId]
                
        let req = _client.urlRequest(with: .post, endpoint: .like, params: params)
        
        _client.sendRequest(req) { (resp, data, error) in
            guard Response.isValid(error: error, data: data, completion: completion) else { return }
//            debugPrint(data!.responseString)
            completion?(.success(true))
        }
    }
    
    func retweet(tweetNumId: String, completion: ((AsyncResult<Bool>) -> Void)?) {
        let params = ["id" : tweetNumId]
        let urlString = String(format: Endpoints.retweet.string, tweetNumId)
        
        let req = _client.urlRequest(with: .post, urlString: urlString, params: params)
        
        _client.sendRequest(req) { (resp, data, error) in
            guard Response.isValid(error: error, data: data, completion: completion) else { return }
//            debugPrint(data!.responseString)
            completion?(.success(true))
        }
    }
}
