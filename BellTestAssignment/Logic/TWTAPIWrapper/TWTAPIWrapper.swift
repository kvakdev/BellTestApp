//
//  TWTAPIWrapper.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 2019-10-14.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import TwitterKit

public class APIClientWrapper: TwitterClientProtocol {
    private var client: TwitterClientProtocol

    init(client: TwitterClientProtocol) {
        self.client = client
    }

    func refresh() {
        self.client = TWTRAPIClient.withCurrentUser()
    }

    public func urlRequest(with method: HTTPMethod, endpoint: Endpoints, params: [String : Any]) -> URLRequest {
        return client.urlRequest(with: method, endpoint: endpoint, params: params)
    }

    public func urlRequest(with method: HTTPMethod, urlString: String, params: [String : Any]) -> URLRequest {
        return client.urlRequest(with: method, urlString: urlString, params: params)
    }

    public func sendRequest(_ request: URLRequest, completion: @escaping (URLResponse?, Data?, Error?) -> Void) {
        client.sendRequest(request, completion: completion)
    }

    public func loadOneTweet(withID id: String, completion: @escaping (TWTRTweet?, Error?) -> Void) {
        client.loadOneTweet(withID: id, completion: completion)
    }
}
