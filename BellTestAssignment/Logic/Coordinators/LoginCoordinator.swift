//
//  LoginCoordinator.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

public protocol LoginCoordinatorDelegate: AnyObject {
    func coordinatorDidLogin(_ coordinator: LoginCoordinator)
    func coordinator(_ coordinator: LoginCoordinator, didFailWith error: Error)
}

public class LoginCoordinator {
    private weak var delegate: LoginCoordinatorDelegate?
    private let navigationController: UINavigationController
        
    init(delegate: LoginCoordinatorDelegate, navigationController: UINavigationController) {
        self.delegate = delegate
        self.navigationController = navigationController

        setupInitialController()
    }

    private func setupInitialController() {
        let controller = LoginViewController()
        controller.set(delegate: self)

        navigationController.setViewControllers([controller], animated: false)
    }
}

extension LoginCoordinator: LoginViewControllerDelegate {
     public func controllerDidTapLogin(_ controller: LoginViewController) {
        TWTRTwitter.sharedInstance().logIn { [weak self] (session, error) in
            guard let self = self else { return }
            guard let error = error else {
                self.delegate?.coordinatorDidLogin(self)
                return
            }

            self.delegate?.coordinator(self, didFailWith: error)
        }
    }
}

