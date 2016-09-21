//
//  MiniGameCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

protocol MiniGameCoordinatorDelegate: class {
    func miniGameCoordinator(_ miniGameCoordinator: MiniGameCoordinator, playerDidScore score: Int)
    func miniGameCoordinatorDidFinish(_ miniGameCoordinator: MiniGameCoordinator)
}

internal final class MiniGameCoordinator: CoordinatorType {
    
    fileprivate var games: [MiniGame] = []
    fileprivate weak var delegate: MiniGameCoordinatorDelegate?
    fileprivate let miniGameRound = MiniGameRound()
    fileprivate weak var navigationController : UINavigationController?
    
    // Does not present any child coordinators. Constant empty array.
    internal let childCoordinators: [CoordinatorType] = []
    
    init(games: [MiniGame], delegate: MiniGameCoordinatorDelegate) {
        self.games = games
        self.delegate = delegate
        miniGameRound.setGameDelegate(self)
    }
    
    func presentFromViewController(_ viewController: UIViewController) {
        guard let firstGame = getNextGame() else { return }
        let nav = UINavigationController(rootViewController: firstGame.gameViewController())
        nav.navigationBar.isHidden = true
        viewController.present(nav, animated: true, completion: nil)
        navigationController = nav
    }
    
    fileprivate func getNextGame() -> MiniGame? {
        guard games.count > 0 else {
            navigationController?.dismiss(animated: true) {
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
    
    func gameRoundDidPause(_ miniGameRound: MiniGameRound) {}
    
    func gameRoundDidResume(_ miniGameRound: MiniGameRound) {}
    
    func gameRound(_ miniGameRound: MiniGameRound, endedGameWithScore score: Int) {
        delegate?.miniGameCoordinator(self, playerDidScore: score)
        guard let nextGame = getNextGame() else { return }
        let nextGameVC = nextGame.gameViewController()
        navigationController?.pushViewController(nextGameVC, animated: true)
    }
}
