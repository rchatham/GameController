//
//  TapTheDotViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 1/9/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation


struct TapTheDotViewModel {
    
    private let gameRound: GameRound
    
    private var tapCount = 0 {
        didSet {
            if tapCount >= 50 {
                gameRound.endGame()
            }
        }
    }
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
    }
    
    mutating func dotTapped() {
        tapCount += 1
    }
    
    func startGame() {
        gameRound.startTimedGame()
    }
    
    func scoreGame() {
        gameRound.updateScore { (score) -> Int in
            return score - 1
        }
    }
}