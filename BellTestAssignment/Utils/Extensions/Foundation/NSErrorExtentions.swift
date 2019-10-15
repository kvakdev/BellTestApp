//
//  NSError+CustomErrors.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public extension NSError {
    static func noData() -> NSError {
        return NSError(domain: "local", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing data"])
    }
}
