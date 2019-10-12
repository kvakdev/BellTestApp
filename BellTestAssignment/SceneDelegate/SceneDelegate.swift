//
//  SceneDelegate.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var mainCoordinator: PCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let nav = UINavigationController()
        let coordinator = BLMainCoordinator(nav)
        coordinator.start()
        
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
        
        mainCoordinator = coordinator
    }

}

