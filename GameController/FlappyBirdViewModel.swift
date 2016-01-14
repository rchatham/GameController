//
//  FlappyBirdViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 1/8/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

struct FlappyBirdViewModel {
    
    private var currentRound: GameRound
    
    var delegate : GameRoundDelegate? {
        set(delegate) {
            currentRound.delegate = delegate
        }
        get {
            return currentRound.delegate
        }
    }
    
    init(gameRound: GameRound) {
        currentRound = gameRound
    }
    
    func endGame() {
        currentRound.endGame()
    }
    
    func updateScore(updater: Int->Int) {
        currentRound.updateScore(updater)
    }
}