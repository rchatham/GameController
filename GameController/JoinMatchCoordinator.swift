//
//  JoinMatchCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 8/16/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit
import PeerConnectivity

internal final class JoinMatchCoordinator {
    
    private weak var navigationController: UINavigationController?
    private var gameCoordinator: GameCoordinator?
    
    func startOnNavigationController(navigationController: UINavigationController) {
        let joinMatchVM = JoinMatchViewModel()
        let joinMatchVC = JoinMatchViewController(viewModel: joinMatchVM, delegate: self)
        navigationController.setViewControllers([joinMatchVC], animated: false)
        navigationController.navigationBarHidden = true
        self.navigationController = navigationController
    }
}

extension JoinMatchCoordinator: JoinMatchViewControllerDelegate {
    
    func startGameWithConnection(connectionManager: PeerConnectionManager) {
        
        guard let navigationController = navigationController else { return }
        gameCoordinator = GameCoordinator(connectionManager: connectionManager, delegate: self)
        
        switch connectionManager.connectionType {
        case .Automatic:
            gameCoordinator?.startOnViewController(navigationController.viewControllers[0])
        case .InviteOnly:
            let browser = connectionManager.browserViewController { [weak self] (event) in
                switch event {
                case .DidFinish:
                    self?.gameCoordinator?.startOnViewController(navigationController.viewControllers[0])
                default: break
                }
            }!
            navigationController.viewControllers[0].presentViewController(browser, animated: true, completion: nil)
        case .Custom: fatalError("Unsupported connection type!")
        }
    }
}

extension JoinMatchCoordinator: GameCoordinatorDelegate {
    
    func didFinish(gameCoordinator: GameCoordinator) {
        self.gameCoordinator = nil
    }
}