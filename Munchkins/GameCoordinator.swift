//
//  GameCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit
import CoordinatorType
import PeerConnectivity

internal final class GameCoordinator: CoordinatorType {
    
    let connectionManager: PeerConnectionManager
    
    weak var delegate: CoordinatorTypeDelegate?
    fileprivate weak var gameViewController: GameViewController?
    internal var childCoordinators: [CoordinatorType] = []
    
    init(connectionManager: PeerConnectionManager, delegate: CoordinatorTypeDelegate) {
        self.connectionManager = connectionManager
        self.delegate = delegate
    }
    
    func viewController() -> UIViewController {
        let gameVM = GameViewModel(connectionManager: connectionManager)
        let gameViewController = GameViewController(viewModel: gameVM)
        gameViewController.delegate = self
        self.gameViewController = gameViewController
        return gameViewController
    }
}

extension GameCoordinator: GameViewControllerDelegate {
    
    func didStartGame(_ gameViewController: GameViewController, withMiniGames games: [MiniGame]) {
        let miniGameCoordinator = MiniGameCoordinator(games: games, connectionManager: connectionManager, delegate: self)
        childCoordinators.append(miniGameCoordinator)
        miniGameCoordinator.start(onViewController: gameViewController, animated: true)
    }
    
    func didQuitGame(_ gameViewController: GameViewController) {
        gameViewController.dismiss(animated: true, completion: nil)
        delegate?.coordinatorDidFinish(self)
    }
}

extension GameCoordinator: MiniGameCoordinatorDelegate {
    
    func miniGameCoordinator(_ miniGameCoordinator: MiniGameCoordinator, playerDidScore score: Int) {
        gameViewController?.incrementScoreBy(score)
    }
}
