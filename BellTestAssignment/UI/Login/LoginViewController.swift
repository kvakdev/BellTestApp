//
//  LoginViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {
    private var coordinator: PLoginCoordinator?
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var skipButton: UIButton!
    
    func set(coordinator: PLoginCoordinator) {
        self.coordinator = coordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loginButton.layer.cornerRadius = 8
        loginButton.layer.masksToBounds = true
    }
}
//0 171 227
private extension LoginViewController {
    func setup() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        [loginButton, skipButton].forEach {
            $0.addTarget(self, action: #selector(handleBtn), for: .touchUpInside)
        }
    }
    
    @objc func handleBtn( sender: UIButton) {
         switch sender {
         case loginButton:
             login()
         case skipButton:
             skip()
         default:
             assertionFailure()
         }
     }
     
     func skip() {
         coordinator?.didTapSkip()
     }
     
     func login() {
         TWTRTwitter.sharedInstance().logIn { (session, error) in
             if session != nil {
                 self.coordinator?.didLogin()
             } else {
                 self.coordinator?.failed(with: error)
             }
         }
     }
}
