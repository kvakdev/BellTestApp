//
//  TWTRAPIClient+PTwitterClient.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import TwitterKit

public protocol TwitterClientProtocol {
    func urlRequest(with method: HTTPMethod, endpoint: Endpoints, params: [String: Any]) -> URLRequest
    
    func urlRequest(with method: HTTPMethod, urlString: String, params: [String: Any]) -> URLRequest
    
    func sendRequest(_ request: URLRequest, completion: @escaping (URLResponse?, Data?, Error?) -> Void)
    
    func loadOneTweet(withID id: String, completion: @escaping (TWTRTweet?, Error?) -> Void)
}

extension TWTRAPIClient: TwitterClientProtocol {
    public func sendRequest(_ request: URLRequest, completion: @escaping (URLResponse?, Data?, Error?) -> Void) {
        sendTwitterRequest(request, completion: completion)
    }
    
    public func urlRequest(with method: HTTPMethod, endpoint: Endpoints, params: [String: Any]) -> URLRequest {
        return urlRequest(withMethod: method.rawValue, urlString: endpoint.string, parameters: params, error: nil)
    }
    
    public func urlRequest(with method: HTTPMethod, urlString: String, params: [String: Any]) -> URLRequest {
        
        return urlRequest(withMethod: method.rawValue, urlString: urlString, parameters: params, error: nil)
    }
    
    public func loadOneTweet(withID id: String, completion: @escaping (TWTRTweet?, Error?) -> Void) {
        loadTweet(withID: id, completion: completion)
    }
}
