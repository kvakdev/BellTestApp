//
//  AppDelegate.swift
//  BellTestAssignment
//
//  Created by Andre Kvashuk on 10/12/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import UIKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainCoordinator: BaseCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TWTRTwitter.sharedInstance().start(withConsumerKey: Constants.apiKey, consumerSecret: Constants.apiSecret)

            window = UIWindow(frame: UIScreen.main.bounds)

        let nav = UINavigationController()
        let coordinator = AppCoordinator(nav)
        mainCoordinator = coordinator

        if !TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            let loginCoordinator = LoginCoordinator(parent: coordinator, navigationController: nav)
            coordinator.addChild(loginCoordinator)
            loginCoordinator.start()
        } else {
            coordinator.start()
        }

        window?.rootViewController = nav
        window?.makeKeyAndVisible()

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
         return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
     }
     
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return TWTRTwitter.sharedInstance().application(application, open: url)
    }
}

