//
//  SceneDelegate.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var mainCoordinator: BaseCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: Constants.apiKey, consumerSecret: Constants.apiSecret)
        
        let nav = UINavigationController()
        let coordinator = BLMainCoordinator(nav)
        mainCoordinator = coordinator
        
        if !TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            let loginCoordinator = BLLoginCoordinator(parent: coordinator, navigationController: nav)
            coordinator.addChild(loginCoordinator)
            loginCoordinator.start()
        } else {
            coordinator.start()
        }
        
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
    }

}

