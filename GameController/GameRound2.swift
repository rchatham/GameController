//
//  GameRound2.swift
//  GameController
//
//  Created by Reid Chatham on 1/20/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit


protocol GameRoundDelegate2 : class {
    
    func roundOver(gameRound: GameRound2) -> (Void->Void)
}

extension GameRoundDelegate2 where Self : UIViewController {
    func roundOver(gameRound: GameRound) -> (Void -> Void) {
        return { [weak self] _ in
            
            guard self != nil else { return }
            guard let pvc = (self!.presentingViewController as? Game2ViewController) else {
                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            
            guard let nextGame = pvc.viewModel.getNextGame() else {
                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            let nextGameVC = nextGame.viewController()

            self!.navigationController?.pushViewController(nextGameVC, animated: true)
        }
    }
}


struct GameRound2 {
    
    
    enum Type {
        case Timed(duration: Int)
        case Objective
        case TimedObjective(duration: Int)
    }
    
    weak var delegate : GameRoundDelegate2?
    
    let gameType : Type
    
    private var isPaused = false
    
    
    init(gameType: Type) {
        self.gameType = gameType
        switch gameType {
        case .Timed(duration: _): break
        case .Objective: break
        case .TimedObjective(duration: _): break
        }
    }
    
    
    func startGame() {
        
    }
    
    func pauseGame() {
        
    }
    
    func resumeGame() {
        
    }
    
    func gameOver() {
        
        delegate?.roundOver(self)()
    }
}