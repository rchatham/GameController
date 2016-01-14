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
    
    var delegate : GameRoundDelegate? {
        set(delegate) {
            gameRound.delegate = delegate
        }
        get {
            return gameRound.delegate
        }
    }
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
    }
    
    mutating func dotTapped() { ++tapCount }
    
    func startGame(scoreUpdater updater: (Int->Int), gameOverScenario: (Int->Void)) {
        
        gameRound.startTimedGame(scoreUpdater: updater, gameOverScenario: gameOverScenario)
    }
}