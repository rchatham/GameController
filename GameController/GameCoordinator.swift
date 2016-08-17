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
    func didFinish(gameCoordinator: GameCoordinator)
}

internal final class GameCoordinator {
    
    private let connectionManager: PeerConnectionManager
    private weak var delegate: GameCoordinatorDelegate?
    private weak var gameViewController: GameViewController?
    private var miniGameCoordinator: MiniGameCoordinator?
    
    init(connectionManager: PeerConnectionManager, delegate: GameCoordinatorDelegate) {
        self.connectionManager = connectionManager
        self.delegate = delegate
    }
    
    func startOnViewController(viewController: UIViewController) {
        connectionManager.start()
        let gameVM = GameViewModel(connectionManager: connectionManager)
        let gameViewController = GameViewController(viewModel: gameVM, delegate: self)
        viewController.presentViewController(gameViewController, animated: true, completion: nil)
        self.gameViewController = gameViewController
    }
}

extension GameCoordinator: GameViewControllerDelegate {
    
    func didStartGame(gameViewController: GameViewController, withMiniGames games: [MiniGame]) {
        connectionManager.closeSession()
        miniGameCoordinator = MiniGameCoordinator(games: games, delegate: self)
        miniGameCoordinator!.presentFromViewController(gameViewController)
    }
    
    func didQuitGame(gameViewController: GameViewController) {
        delegate?.didFinish(self)
        gameViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension GameCoordinator: MiniGameCoordinatorDelegate {
    
    func miniGameCoordinator(miniGameCoordinator: MiniGameCoordinator, playerDidScore score: Int) {
        gameViewController?.incrementScoreBy(score)
    }
    
    func miniGameCoordinatorDidFinish(miniGameCoordinator: MiniGameCoordinator) {
        self.miniGameCoordinator = nil
        self.connectionManager.openSession()
    }
}