//
//  TabCoordinator.swift
//  CoordinatorType
//
//  Created by Reid Chatham on 2/26/17.
//
//

import UIKit

public protocol TabCoordinatorType: CoordinatorType {
    weak var tabController: UITabBarController? { get set }
    func rootViewControllers() -> [UIViewController]
}

extension TabCoordinatorType {
    
    public func tabController() -> UITabBarController {
        return viewController() as! UITabBarController
    }
    
    public func viewController() -> UIViewController {
        let tab = UITabBarController()
        start(onTabController: tab, animated: false)
        return tab
    }
    
    public func start(onViewController viewController: UIViewController, animated: Bool) {
        if let tab = viewController as? UITabBarController {
            start(onTabController: tab, animated: animated)
        } else {
            let tab = UITabBarController()
            start(onTabController: tab, animated: false)
            viewController.present(tab, animated: true, completion: nil)
        }
    }
    
    private func start(onTabController tabController: UITabBarController, animated: Bool) {
        let roots = rootViewControllers()
        tabController.setViewControllers(roots, animated: animated)
        self.tabController = tabController
    }
}
