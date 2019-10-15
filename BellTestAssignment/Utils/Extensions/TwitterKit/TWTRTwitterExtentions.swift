//
//  TWTRTwitterExtentions.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 2019-10-14.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import TwitterKit

extension TWTRTwitter {
    static var isLoggedIn: Bool {
        return TWTRTwitter.sharedInstance().sessionStore.session() != nil
    }
}
