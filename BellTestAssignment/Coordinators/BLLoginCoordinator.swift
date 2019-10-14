//
//  LoginCoordinator.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

protocol PLoginCoordinator: BaseCoordinator {
    func didLogin()
    func failed(with error: Error?)
    func didTapSkip()
}

class LoginCoordinator: BaseCoordinatorClass, PLoginCoordinator {
    private let _parent: PCoordinator
    private let _navigationVC: UINavigationController
    
    private var loginVC: UIViewController?
    
    init(parent: PCoordinator, navigationController: UINavigationController) {
        _parent = parent
        _navigationVC = navigationController
    }
    
    func start() {
        let vc = LoginViewController()
        vc.set(coordinator: self)
        _navigationVC.setViewControllers([vc], animated: false)
        loginVC = vc
    }
    
    func didLogin() {
        _parent.coordinatorIsDone(self)
    }
    
    func didTapSkip() {
        _parent.coordinatorIsDone(self)
    }
    
    func failed(with error: Error?) {
        
    }
    
    func finish() {
        _navigationVC.popViewController(animated: false)
    }
    
    func coordinatorIsDone(_ child: BaseCoordinatorClass) {}
    func addChild(_ child: BaseCoordinatorClass) {}
    
    deinit {
        print("Login coordinator is deallocated")
    }
}

