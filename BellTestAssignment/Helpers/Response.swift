//
//  Response.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

enum Response {
    static func isValid<T>(error: Error?, data: Data?, completion: ((AsyncResult<T>) -> Void)?) -> Bool {
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
