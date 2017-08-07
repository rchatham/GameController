//
//  AppDelegate.swift
//  GameController
//
//  Created by Reid Chatham on 10/30/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit
import PluggableApplicationDelegate
import CoordinatorType

@UIApplicationMain
class AppDelegate: PluggableApplicationDelegate {
    
    override var services: [ApplicationService] {
        return [
            PeerConnectionService.shared
        ]
    }

    struct Static {
        static let Motion = MotionKit()
    }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController()
        window?.makeKeyAndVisible()
        
        return result
    }
}

extension AppDelegate: AppCoordinatorType {
    func viewController() -> UIViewController {
        let joinMatchCoordinator = JoinMatchCoordinator()
        childCoordinators.append(joinMatchCoordinator)
        return joinMatchCoordinator.viewController()
    }
}
