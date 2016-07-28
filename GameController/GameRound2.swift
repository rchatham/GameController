//
//  GameRound2.swift
//  GameController
//
//  Created by Reid Chatham on 1/20/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit


//protocol GameRoundDelegate2 : class {
//    
//    func roundOver(gameRound: GameRound2) -> (Void->Void)
//}
//
//struct GameRound2 {
//    
//    enum Type {
//        case Timed(duration: Int)
//        case Objective
//        case TimedObjective(duration: Int)
//    }
//    
//    weak var delegate : GameRoundDelegate2?
//    
//    let gameType : Type
//    
//    private var isPaused = false
//    
//    
//    init(gameType: Type) {
//        self.gameType = gameType
//        switch gameType {
//        case .Timed(duration: _): break
//        case .Objective: break
//        case .TimedObjective(duration: _): break
//        }
//    }
//    
//    
//    func startGame() {
//        
//    }
//    
//    func pauseGame() {
//        
//    }
//    
//    func resumeGame() {
//        
//    }
//    
//    func gameOver() {
//        
//        delegate?.roundOver(self)()
//    }
//}