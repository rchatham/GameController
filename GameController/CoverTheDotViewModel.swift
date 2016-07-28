//
//  CoverTheDotViewModel.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 12/26/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import Foundation

struct CoverTheDotViewModel {
 
    private let gameRound : GameRound
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
    }
    
    mutating func startGame(scoreUpdater updater: GameRound.ScoreUpdater) {
        gameRound.startTimedGame()
        switch gameRound.gameType! {
        case .Timed(let duration):
            _ = Timer(timeInterval: 1,
                      userInfo: nil,
                      repeats: true,
                      invalidateAfter: Double(duration),
                      startOnCreation: true,
                      callback: {
                    return self.gameRound.updateScore(updater)
            })
        default: break
        }
    }
    
    func sizeRatio() -> Int {
        return Int.random(10) + 3
    }
    
    func maxBlocks() -> Int {
        return Int.random(10) + 1
    }
    
    func outputText() -> String {
        switch gameRound.gameType! {
        case .Timed(let duration):
            return "Time Remaining: \(gameRound.timeRemaining ?? duration) Score: \(gameRound.score)"
        default: return ""
        }
    }
}
