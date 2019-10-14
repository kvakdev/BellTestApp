//
//  PLoginCoordinator.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol PLoginCoordinator: BaseCoordinator {
    func didLogin()
    func failed(with error: Error?)
    func didTapSkip()
}
