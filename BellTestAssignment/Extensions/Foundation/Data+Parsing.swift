//
//  Data+Parsing.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

extension Data {
    var responseString: NSString? {
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
            
            return string
    }

    var dictionary: Dictionary<String, Any>? {
        let result = try? JSONSerialization.jsonObject(with: self, options:[])
        
        return result as? Dictionary<String, Any>
    }
}
