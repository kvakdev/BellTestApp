//
//  String+Ext.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
