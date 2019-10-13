//
//  BLLoginViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

class BLLoginViewController: UIViewController {
    private var _coordinator: PLoginCoordinator?
    @IBOutlet private weak var _loginButton: UIButton!
    @IBOutlet private weak var _skipButton: UIButton!
    
    
    func set(coordinator: PLoginCoordinator) {
        _coordinator = coordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        [_loginButton, _skipButton].forEach {
            $0.addTarget(self, action: #selector(handleBtn), for: .touchUpInside)
        }
    }
    
    @objc private func handleBtn(_ sender: UIButton) {
        switch sender {
        case _loginButton:
            login()
        case _skipButton:
            skip()
        default:
            assertionFailure()
        }
    }
    
    private func skip() {
        _coordinator?.didTapSkip()
    }
    
    private func login() {
        TWTRTwitter.sharedInstance().logIn { [unowned self] (session, error) in
            if session != nil {
                self._coordinator?.didLogin()
            } else {
                self._coordinator?.failed(with: error)
            }
        }
    }
}
