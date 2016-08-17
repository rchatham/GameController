//
//  MiniGameCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

protocol MiniGameCoordinatorDelegate: class {
    func miniGameCoordinator(miniGameCoordinator: MiniGameCoordinator, playerDidScore score: Int)
    func miniGameCoordinatorDidFinish(miniGameCoordinator: MiniGameCoordinator)
}

internal final class MiniGameCoordinator {
    
    private var games: [MiniGame] = []
    private weak var delegate: MiniGameCoordinatorDelegate?
    private let miniGameRound = MiniGameRound()
    private weak var navigationController : UINavigationController?
    
    init(games: [MiniGame], delegate: MiniGameCoordinatorDelegate) {
        self.games = games
        self.delegate = delegate
        miniGameRound.setGameDelegate(self)
    }
    
    func presentFromViewController(viewController: UIViewController) {
        guard let firstGame = getNextGame() else { return }
        let nav = UINavigationController(rootViewController: firstGame.gameViewController())
        nav.navigationBar.hidden = true
        viewController.presentViewController(nav, animated: true, completion: nil)
        navigationController = nav
    }
    
    private func getNextGame() -> MiniGame? {
        guard games.count > 0 else {
            navigationController?.dismissViewControllerAnimated(true) {
                self.delegate?.miniGameCoordinatorDidFinish(self)
            }
            return nil
        }
        var nextGame = games.removeFirst()
        nextGame.delegate = miniGameRound
        nextGame.dataSource = miniGameRound
        miniGameRound.setGameType(nextGame.gameType)
        return nextGame
    }
}

extension MiniGameCoordinator : MiniGameRoundDelegate {
    
    func gameRoundDidPause(miniGameRound: MiniGameRound) {}
    
    func gameRoundDidResume(miniGameRound: MiniGameRound) {}
    
    func gameRound(miniGameRound: MiniGameRound, endedGameWithScore score: Int) {
        delegate?.miniGameCoordinator(self, playerDidScore: score)
        guard let nextGame = getNextGame() else { return }
        let nextGameVC = nextGame.gameViewController()
        navigationController?.pushViewController(nextGameVC, animated: true)
    }
}
