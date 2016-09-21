//
//  JoinMatchCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 8/16/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit
import PeerConnectivity

internal final class JoinMatchCoordinator: CoordinatorType {
    
    fileprivate weak var navigationController: UINavigationController?
    fileprivate var childCoordinators: [CoordinatorType] = []
    
    func startOnNavigationController(_ navigationController: UINavigationController) {
        let joinMatchVM = JoinMatchViewModel()
        let joinMatchVC = JoinMatchViewController(viewModel: joinMatchVM, delegate: self)
        navigationController.setViewControllers([joinMatchVC], animated: false)
        navigationController.isNavigationBarHidden = true
        self.navigationController = navigationController
    }
}

extension JoinMatchCoordinator: JoinMatchViewControllerDelegate {
    
    func startGameWithConnection(_ connectionManager: PeerConnectionManager) {
        
        guard let navigationController = navigationController else { return }
        let gameCoordinator = GameCoordinator(connectionManager: connectionManager, delegate: self)
        
        switch connectionManager.connectionType {
        case .automatic:
            gameCoordinator.startOnViewController(navigationController.viewControllers[0])
        case .inviteOnly:
            let browser = connectionManager.browserViewController { (event) in
                switch event {
                case .didFinish:
                    gameCoordinator.startOnViewController(navigationController.viewControllers[0])
                default: break
                }
            }!
            navigationController.viewControllers[0].present(browser, animated: true, completion: nil)
        case .custom: fatalError("Unsupported connection type!")
        }
        
        childCoordinators.append(gameCoordinator)
    }
}

extension JoinMatchCoordinator: GameCoordinatorDelegate {
    
    func didFinish(_ gameCoordinator: GameCoordinator) {
        childCoordinators.remove(at: childCoordinators.index(where: { $0 === gameCoordinator })!)
    }
}
