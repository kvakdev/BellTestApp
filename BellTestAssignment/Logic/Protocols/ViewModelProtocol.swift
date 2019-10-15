//
//  ViewModelProtocol.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol ViewModelProtocol {
    func viewDidLoad()
    func viewWillAppear()
}

public extension ViewModelProtocol {
    func viewDidLoad() {}
    func viewWillAppear() {}
}
