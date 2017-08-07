//
//  JoinMatchCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 8/16/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit
import CoordinatorType
import PeerConnectivity

internal final class JoinMatchCoordinator: NavigationCoordinatorType {
    
    weak var delegate: CoordinatorTypeDelegate?
    internal weak var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorType] = []
    
    func rootViewController() -> UIViewController {
        let viewModel = JoinMatchViewModel()
        let joinMatchVC = JoinMatchViewController(viewModel: viewModel)
        joinMatchVC.delegate = self
        return joinMatchVC
    }
}

extension JoinMatchCoordinator: JoinMatchViewControllerDelegate {
    func joinMatchViewController(_ joinMatchViewController: JoinMatchViewController, shouldStartWithConnection connectionManager: PeerConnectionManager) {
        
        guard let navigationController = navigationController else { return }
        let gameCoordinator = GameCoordinator(connectionManager: connectionManager, delegate: self)
        
        switch connectionManager.connectionType {
        case .automatic:
            gameCoordinator.start(onViewController: navigationController, animated: true)
        case .inviteOnly:
            let browser = connectionManager.browserViewController { (event) in
                switch event {
                case .didFinish:
                    gameCoordinator.start(onViewController: navigationController, animated: true)
                default: break
                }
            }!
            navigationController.viewControllers[0].present(browser, animated: true, completion: nil)
        case .custom: fatalError("Unsupported connection type!")
        }
        
        childCoordinators.append(gameCoordinator)
    }
}
