//
//  PCoordinator.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/14/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import TwitterKit

public protocol BaseCoordinator {
    func start()
    func finish()
    func coordinatorIsDone(_ child: BaseCoordinatorClass)
    func addChild(_ child: BaseCoordinatorClass)
}

public protocol PCoordinator: BaseCoordinator {
    var isLoggedIn: Bool { get }
    
    func didSelect(_ tweetId: String)
    func didTapSearch()
    func didTapLogout(completion: @escaping (Bool) -> Void)
    func didTapLogin(completion: @escaping (Bool) -> Void)
    func didMoveSlider()
    
    func handleSuccess(message: String)
    func handle(error: Error?)
}
