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

public enum AsyncResult<T> {
    case success(T)
    case failure(Error?)
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public struct RadiusQuery {
    let radius: Int
    let location: CLLocation
    let count: Int
    let sinceId: String?
    let filter: ((Tweet) -> Bool)?
    
    func toParams() -> [String: String] {
        let lat = "\(location.coordinate.latitude)"
        let lon = "\(location.coordinate.longitude)"
        let geocode = "\(lat),\(lon),\(radius)km"
        
        return [
            "q" : "",
            "count" : "\(count)",
            "geocode" : geocode,
            "since_id" : sinceId ?? "0",
            "result_type" : "recent"
        ]
    }
}

public protocol TweetAPIProtocol {
    func searchTweets(query: RadiusQuery, completion: @escaping (AsyncResult<[Tweet]>) -> Void) 
    func querySearchTweets(query: String, count: Int, completion: @escaping (AsyncResult<[TWTRTweet]>) -> Void)
    func fetchTweet(id: String, completion: @escaping (AsyncResult<TWTRTweet>) -> Void)
    func retweet(tweetNumId: String, completion: ((AsyncResult<Bool>) -> Void)?)
    func like(tweetId: String, completion: ((AsyncResult<Bool>) -> Void)?)
    func isLoggedIn() -> Bool
}


public enum Endpoints: String {
    case search = "search/tweets.json"
    case retweet = "statuses/retweet/%@.json"
    case like = "favorites/create.json"
    
    var string: String {
        return Constants.Url.base.appending(rawValue)
    }
}

public class TweetSearchService: NSObject, TweetAPIProtocol {
    let client: TwitterClientProtocol
    
    init(client: TwitterClientProtocol) {
        self.client = client
    }
    
    public func isLoggedIn() -> Bool {
        return TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()
    }
    
    public func searchTweets(query: RadiusQuery, completion: @escaping (AsyncResult<[Tweet]>) -> Void) {
        
        let req = client.urlRequest(with: HTTPMethod.get, endpoint: Endpoints.search, params: query.toParams())
        
       client.sendRequest(req) { (resp, data, error) in
            guard Response.isValid(error: error, data: data, completion: completion) else { return }
//            debugPrint(data.responseString)
            do {
                let result = try JSONDecoder().decode(RadiusSearchResponse.self, from: data!)
                
                if let filter = query.filter {
                    completion(.success(result.tweets.filter(filter)))
                } else {
                    completion(.success(result.tweets))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func querySearchTweets(query: String, count: Int, completion: @escaping (AsyncResult<[TWTRTweet]>) -> Void) {
        
        let params: [String: String] = [
            "q" : query.urlEncoded,
            "count" : "\(count)"
        ]
        
        let req = client.urlRequest(with: .get, endpoint: .search, params: params)
        
       client.sendRequest(req) { (resp, data, error) in
            guard Response.isValid(error: error, data: data, completion: completion) else { return }
            
            if let tweets = TWTRTweet.tweetArrayWith(data: data!) {
                completion(.success(tweets))
            } else {
                completion(.failure(error))
            }
        }
    }
    
    public func fetchTweet(id: String, completion: @escaping (AsyncResult<TWTRTweet>) -> Void) {
       client.loadOneTweet(withID: id) { (tweet, error) in
            guard let tweet = tweet else {
                completion(.failure(NSError.noData()))
                return
            }
            completion(.success(tweet))
        }
    }
    
    public func like(tweetId: String, completion: ((AsyncResult<Bool>) -> Void)?) {
        let params = ["id" : tweetId]
                
        let req = client.urlRequest(with: .post, endpoint: .like, params: params)
        
       client.sendRequest(req) { (resp, data, error) in
            guard Response.isValid(error: error, data: data, completion: completion) else { return }
            completion?(.success(true))
        }
    }
    
    public func retweet(tweetNumId: String, completion: ((AsyncResult<Bool>) -> Void)?) {
        let params = ["id" : tweetNumId]
        let urlString = String(format: Endpoints.retweet.string, tweetNumId)
        
        let req = client.urlRequest(with: .post, urlString: urlString, params: params)
        
       client.sendRequest(req) { (resp, data, error) in
            guard Response.isValid(error: error, data: data, completion: completion) else { return }
            completion?(.success(true))
        }
    }
}
