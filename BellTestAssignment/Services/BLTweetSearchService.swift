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
}

class BLTweetSearchResponse: Decodable {
    let metadata: BLSearchMetaData
    let tweets: [BLTweet]
    
    enum CodingKeys: String, CodingKey {
        case tweets = "statuses"
        case metadata = "search_metadata"
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

protocol PTweetSearchService {
    func searchTweets(radius: Int, location: CLLocation, count: Int, completion: @escaping (AsyncResult<[BLTweet]>) -> Void, filter: ((BLTweet) -> Bool)?)
    func fetchTweet(id: String, completion: @escaping (AsyncResult<TWTRTweet>) -> Void)
}

class BLTweetSearchService: NSObject, PTweetSearchService {
    let _client = TWTRAPIClient()
    
    
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
    
    func fetchTweet(id: String, completion: @escaping (AsyncResult<TWTRTweet>) -> Void) {
        _client.loadTweet(withID: id) { (tweet, error) in
            guard let tweet = tweet else {
                completion(.failure(NSError.noData()))
                return
            }
            completion(.success(tweet))
        }
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
