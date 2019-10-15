//
//  LoginViewController.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/13/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func controllerDidTapLogin(_ controller: LoginViewController)
}

public class LoginViewController: UIViewController {
    private weak var delegate: LoginViewControllerDelegate?

    @IBOutlet private weak var loginButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loginButton.layer.cornerRadius = 8
        loginButton.layer.masksToBounds = true
    }

    func set(delegate: LoginViewControllerDelegate) {
        self.delegate = delegate
    }
}

private extension LoginViewController {
    func setup() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
     
    @IBAction func login() {
        delegate?.controllerDidTapLogin(self)
    }
}
