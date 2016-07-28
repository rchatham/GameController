//
//  MiniGameCoordinator.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

protocol MiniGameCoordinatorDelegate {
    func miniGameCoordinator(miniGameCoordinator: MiniGameCoordinator, playerDidScore score: Int)
    func miniGameCoordinatorDidFinish(miniGameCoordinator: MiniGameCoordinator)
}

class MiniGameCoordinator {
    
    var delegate: MiniGameCoordinatorDelegate?
    
    private var games : [MiniGame]
    
    private weak var navigationController : UINavigationController?
    
    init(games: [MiniGame]) {
        self.games = games
        for game in self.games {
            game.gameRound.setGameDelegate(self)
        }
    }
    
    func presentFromViewController(viewController: UIViewController) {
        guard let firstGame = getNextGame() else {
            navigationController?.dismissViewControllerAnimated(true) {
                self.delegate?.miniGameCoordinatorDidFinish(self)
            }
            return
        }
        let nav = UINavigationController(rootViewController: firstGame.viewController())
        nav.navigationBar.hidden = true
        viewController.presentViewController(nav, animated: true, completion: nil)
        navigationController = nav
    }
    
    func getNextGame() -> MiniGame? {
        guard games.count > 0 else { return nil }
        return games.removeFirst()
    }
}

extension MiniGameCoordinator : GameRoundDelegate {
    
    func gameRoundDidPause(gameRound: GameRound) {}
    
    func gameRoundDidResume(gameRound: GameRound) {}
    
    func gameRound(gameRound: GameRound, endedGameWithScore score: Int) {
        
        delegate?.miniGameCoordinator(self, playerDidScore: score)
        
        guard let nextGame = self.getNextGame() else {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            self.delegate?.miniGameCoordinatorDidFinish(self)
            return
        }
        let nextGameVC = nextGame.viewController()
        self.navigationController?.pushViewController(nextGameVC, animated: true)
    }
}
