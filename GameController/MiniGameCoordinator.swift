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

class MiniGameCoordinator {
    
    weak var delegate: MiniGameCoordinatorDelegate?
    
    private let miniGameRound = MiniGameRound()
    
    private var games: [MiniGame] = []
    
    private weak var navigationController : UINavigationController?
    
    init(games: [MiniGame]) {
        self.games = games
        miniGameRound.setGameDelegate(self)
    }
    
    func presentFromViewController(viewController: UIViewController) {
        guard var firstGame = getNextGame() else {
            navigationController?.dismissViewControllerAnimated(true) {
                self.delegate?.miniGameCoordinatorDidFinish(self)
            }
            return
        }
        firstGame.delegate = miniGameRound
        firstGame.dataSource = miniGameRound
        miniGameRound.setGameType(firstGame.gameType)
        
        let nav = UINavigationController(rootViewController: firstGame.gameViewController())
        nav.navigationBar.hidden = true
        viewController.presentViewController(nav, animated: true, completion: nil)
        navigationController = nav
    }
    
    private func getNextGame() -> MiniGame? {
        guard games.count > 0 else { return nil }
        return games.removeFirst()
    }
}

extension MiniGameCoordinator : MiniGameRoundDelegate {
    
    func gameRoundDidPause(miniGameRound: MiniGameRound) {}
    
    func gameRoundDidResume(miniGameRound: MiniGameRound) {}
    
    func gameRound(miniGameRound: MiniGameRound, endedGameWithScore score: Int) {
        
        delegate?.miniGameCoordinator(self, playerDidScore: score)
        
        guard var nextGame = getNextGame() else {
            navigationController?.dismissViewControllerAnimated(true, completion: nil)
            delegate?.miniGameCoordinatorDidFinish(self)
            return
        }
        nextGame.delegate = miniGameRound
        nextGame.dataSource = miniGameRound
        miniGameRound.setGameType(nextGame.gameType)
        
        let nextGameVC = nextGame.gameViewController()
        navigationController?.pushViewController(nextGameVC, animated: true)
    }
}
