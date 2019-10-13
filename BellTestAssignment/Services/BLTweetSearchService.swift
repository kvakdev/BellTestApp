//
//  BLTweetSearchService.swift
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

class BLTweetSearchResponse: Decodable {
    let metadata: BLSearchMetaData
    let tweets: [BLTweet]
    
    enum CodingKeys: String, CodingKey {
        case tweets = "statuses"
        case metadata = "search_metadata"
    }
}

class BLQueryTweetResponse {
    var tweets: [TWTRTweet] = []
    
    enum CodingKeys: String, CodingKey {
        case tweets = "statuses"
    }
}

class BLSearchMetaData: Codable {
    let maxID: Double
    let sinceID: Int
    let sinceIDStr, maxIDStr, refreshURL: String
    let count: Int
    let query, nextResults: String
    let completedIn: Double
    
    enum CodingKeys: String, CodingKey {
        case maxID = "max_id"
        case sinceID = "since_id"
        case sinceIDStr = "since_id_str"
        case maxIDStr = "max_id_str"
        case refreshURL = "refresh_url"
        case count, query
        case nextResults = "next_results"
        case completedIn = "completed_in"
    }
}

protocol PTweetAPIService {
    func searchTweets(radius: Int, location: CLLocation, count: Int, completion: @escaping (AsyncResult<[BLTweet]>) -> Void, filter: ((BLTweet) -> Bool)?)
    func querySearchTweets(query: String, count: Int, completion: @escaping (AsyncResult<[TWTRTweet]>) -> Void)
    func fetchTweet(id: String, completion: @escaping (AsyncResult<TWTRTweet>) -> Void)
    func retweet(tweetId: String, completion: ((AsyncResult<Bool>) -> Void)?)
    func like(tweetId: String, completion: ((AsyncResult<Bool>) -> Void)?)
    func isLoggedIn() -> Bool
}

class BLTweetSearchService: NSObject, PTweetAPIService {
    let _client: TWTRAPIClient
    
    init(client: TWTRAPIClient) {
        _client = client
    }
    
    func isLoggedIn() -> Bool {
        return TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()
    }
    
    func searchTweets(radius: Int, location: CLLocation, count: Int = 1000, completion: @escaping (AsyncResult<[BLTweet]>) -> Void, filter: ((BLTweet) -> Bool)?) {
        
        let geocode = "\(location.coordinate.latitude),\(location.coordinate.longitude),\(radius)km"
        
        let params: [String: String] = [
            "q" : "",
            "count" : "\(count)",
            "geocode" : geocode,
            "result_type" : "recent"
        ]
        
        let req = _client.urlRequest(withMethod: HTTPMethod.get.rawValue, urlString: Endpoints.search.string, parameters: params, error: nil)
        
        _client.sendTwitterRequest(req) { (resp, data, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError.noData()))
                return
            }
            debugPrint(data.responseString)
            
            do {
                let result = try JSONDecoder().decode(BLTweetSearchResponse.self, from: data)
                
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
        
        let req = _client.urlRequest(withMethod: HTTPMethod.get.rawValue, urlString: Endpoints.search.string, parameters: params, error: nil)
        
        _client.sendTwitterRequest(req) { [weak self] (resp, data, error) in
            guard self?.isValid(error: error, data: data, completion: completion) ?? false else { return }
            
            if let tweets = TWTRTweet.tweetArrayWith(data: data!) {
                completion(.success(tweets))
            } else {
                completion(.failure(error))
            }

        }
    }
    
    func fetchTweet(id: String, completion: @escaping (AsyncResult<TWTRTweet>) -> Void) {
        _client.loadTweet(withID: id) { (tweet, error) in
            guard let tweet = tweet else {
                completion(.failure(NSError.noData()))
                return
            }
            completion(.success(tweet))
        }
    }
    func like(tweetId: String, completion: ((AsyncResult<Bool>) -> Void)?) {
        let params = [
            "id" : tweetId
        ]
        
        let req = _client.urlRequest(withMethod: HTTPMethod.post.rawValue, urlString: Endpoints.like.string, parameters: params, error: nil)
        _client.sendTwitterRequest(req) { [weak self] (resp, data, error) in
            guard self?.isValid(error: error, data: data, completion: completion) ?? false else { return }
            debugPrint(data!.responseString)
            completion?(.success(true))
        }
    }
    
    func retweet(tweetId: String, completion: ((AsyncResult<Bool>) -> Void)?) {
        let params = [
            "tweet_id" : tweetId
        ]
        
        let req = _client.urlRequest(withMethod: HTTPMethod.post.rawValue, urlString: Endpoints.postedTweet.string, parameters: params, error: nil)
        _client.sendTwitterRequest(req) { [weak self] (resp, data, error) in
            guard self?.isValid(error: error, data: data, completion: completion) ?? false else { return }
            debugPrint(data!.responseString)
        }
    }
    
    func isValid<T>(error: Error?, data: Data?, completion: ((AsyncResult<T>) -> Void)?) -> Bool {
        if let error = error {
            completion?(.failure(error))
            return false
        }
        guard let _ = data else {
            completion?(.failure(NSError.noData()))
            return false
        }
        return true
    }
}

extension NSError {
    static func noData() -> NSError {
        return NSError(domain: "local", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing data"])
    }
}

private extension BLTweetSearchService {
    enum Endpoints: String {
        case search = "search/tweets.json"
        case postedTweet
        case like = "favorites/create.json"
        
        var string: String {
            return Constants.Url.base.appending(rawValue)
        }
    }
}

extension Data {
    var responseString: NSString? {
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
            
            return string
    }
}

extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}

extension Data {
    var dictionary: Dictionary<String, Any>? {
        let result = try? JSONSerialization.jsonObject(with: self, options:[])
        
        return result as? Dictionary<String, Any>
    }
}

extension TWTRTweet {
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
