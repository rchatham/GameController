//
//  GameCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit
import PeerConnectivity

internal protocol GameCoordinatorDelegate: class {
    func didFinish(_ gameCoordinator: GameCoordinator)
}

internal final class GameCoordinator: CoordinatorType {
    
    fileprivate let connectionManager: PeerConnectionManager
    fileprivate weak var delegate: GameCoordinatorDelegate?
    fileprivate weak var gameViewController: GameViewController?
    fileprivate(set) internal var childCoordinators: [CoordinatorType] = []
    
    init(connectionManager: PeerConnectionManager, delegate: GameCoordinatorDelegate) {
        self.connectionManager = connectionManager
        self.delegate = delegate
    }
    
    func startOnViewController(_ viewController: UIViewController) {
        connectionManager.start()
        let gameVM = GameViewModel(connectionManager: connectionManager)
        let gameViewController = GameViewController(viewModel: gameVM, delegate: self)
        viewController.present(gameViewController, animated: true, completion: nil)
        self.gameViewController = gameViewController
    }
}

extension GameCoordinator: GameViewControllerDelegate {
    
    func didStartGame(_ gameViewController: GameViewController, withMiniGames games: [MiniGame]) {
        connectionManager.closeSession()
        let miniGameCoordinator = MiniGameCoordinator(games: games, delegate: self)
        miniGameCoordinator.presentFromViewController(gameViewController)
        childCoordinators.append(miniGameCoordinator)
    }
    
    func didQuitGame(_ gameViewController: GameViewController) {
        delegate?.didFinish(self)
        gameViewController.dismiss(animated: true, completion: nil)
    }
}

extension GameCoordinator: MiniGameCoordinatorDelegate {
    
    func miniGameCoordinator(_ miniGameCoordinator: MiniGameCoordinator, playerDidScore score: Int) {
        gameViewController?.incrementScoreBy(score)
    }
    
    func miniGameCoordinatorDidFinish(_ miniGameCoordinator: MiniGameCoordinator) {
        childCoordinators.remove(at: childCoordinators.index(where: { $0 === miniGameCoordinator })!)
        self.connectionManager.openSession()
    }
}
