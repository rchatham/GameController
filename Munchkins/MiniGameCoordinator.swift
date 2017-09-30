//
//  MiniGameCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit
import CoordinatorType
import PeerConnectivity

protocol MiniGameCoordinatorDelegate: CoordinatorTypeDelegate {
    func miniGameCoordinator(_ miniGameCoordinator: MiniGameCoordinator, playerDidScore score: Int)
}

internal final class MiniGameCoordinator: NavigationCoordinatorType {

    let connectionManager: PeerConnectionManager
    
    weak var delegate: CoordinatorTypeDelegate? {
        return _delegate
    }
    fileprivate let _delegate: MiniGameCoordinatorDelegate
    
    fileprivate var games: [MiniGame] = []
    fileprivate let miniGameRound = MiniGameRound()
    internal weak var navigationController: UINavigationController?
    
    // Does not present any child coordinators. Constant empty array.
    var childCoordinators: [CoordinatorType] = []
    
    init(games: [MiniGame], connectionManager: PeerConnectionManager, delegate: MiniGameCoordinatorDelegate) {
        self.games = games
        self.connectionManager = connectionManager
        self._delegate = delegate
        miniGameRound.setGameDelegate(self)
    }
    
    func rootViewController() -> UIViewController {
        return nextViewController() ?? UIViewController()
    }
    
    fileprivate func nextViewController() -> UIViewController? {
        return getNextGame()?.gameViewController()
    }
    
    fileprivate func getNextGame() -> MiniGame? {
        guard games.count > 0 else {
            navigationController?.dismiss(animated: true) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.connectionManager.openSession()
                strongSelf.delegate?.coordinatorDidFinish(strongSelf)
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
        _delegate.miniGameCoordinator(self, playerDidScore: score)
        guard let nextGame = getNextGame() else { return }
        let nextGameVC = nextGame.gameViewController()
        navigationController?.pushViewController(nextGameVC, animated: true)
    }
}
