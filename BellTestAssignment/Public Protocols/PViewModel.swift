//
//  PViewModel.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol PViewModel {
    func viewDidLoad()
    func viewWillAppear()
}

public extension PViewModel {
    func viewDidLoad() {}
    func viewWillAppear() {}
}
