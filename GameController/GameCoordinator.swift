//
//  GameCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit
import PeerConnectivity

internal class GameCoordinator {
    
    let connectionManager: PeerConnectionManager
    
    private weak var gameViewController: GameViewController?
    
    init(connectionManager: PeerConnectionManager) {
        self.connectionManager = connectionManager
    }
    
    func startOnViewController(viewController: UIViewController) {
        let localPlayer = Player(peer: connectionManager.peer)
        let gameVM = GameViewModel(player: localPlayer, connectionManager: connectionManager)
        let gameViewController = GameViewController(viewModel: gameVM)
        gameViewController.delegate = self
        viewController.presentViewController(gameViewController, animated: true, completion: nil)
        self.gameViewController = gameViewController
    }
}

extension GameCoordinator: GameViewControllerDelegate {
    
    func didStartGame(gameViewController: GameViewController, withMiniGames games: [MiniGame]) {
        let miniGameCoordinator = MiniGameCoordinator(games: games)
        miniGameCoordinator.delegate = self
        miniGameCoordinator.presentFromViewController(gameViewController)
    }
}

extension GameCoordinator: MiniGameCoordinatorDelegate {
    
    func miniGameCoordinator(miniGameCoordinator: MiniGameCoordinator, playerDidScore score: Int) {
        gameViewController?.viewModel.player.incrementScoreBy(score)
    }
    
    func miniGameCoordinatorDidFinish(miniGameCoordinator: MiniGameCoordinator) {
        
    }
}