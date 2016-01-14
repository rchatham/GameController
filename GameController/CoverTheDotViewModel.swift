//
//  CoverTheDotViewModel.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 12/26/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import Foundation

struct CoverTheDotViewModel {
 
    private let currentRound : GameRound
    
    var delegate : GameRoundDelegate? {
        set(delegate) {
            currentRound.delegate = delegate
        }
        get {
            return currentRound.delegate
        }
    }
    
    func sizeRatio() -> Int {
        return Int.random(10) + 3
    }
    func maxBlocks() -> Int {
        return Int.random(10) + 1
    }
    
//    var sizeRatio : Int {
//        return Int.random(10) + 3
//    }
//    var maxBlocks : Int {
//        return Int.random(10) + 1
//    }
    
    init(gameRound: GameRound) {
        self.currentRound = gameRound
    }
    
    func startGame(scoreUpdater updater: (Int->Int), gameOverScenario: (Int->Void)) {
        
        currentRound.startTimedGame(scoreUpdater: updater, gameOverScenario: gameOverScenario)
    }
    
    func outputText() -> String {
        return "Time Remaining: \(currentRound.timeRemaining ?? 0) Score: \(currentRound.score)"

    }
}

private extension Int {
    static func random(max: Int) -> Int {
        return Int(arc4random() % UInt32(max))
    }
}