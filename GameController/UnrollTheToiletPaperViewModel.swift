//
//  UnrollTheToiletPaperViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 7/27/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

struct UnrollTheToiletPaperViewModel {
    
    private let gameRound: GameRound
    internal private(set) var toiletPaperRipped = false
    private var runningTotal: Int = 0
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
    }
    
    mutating func unroll(lengthOfButtTissue: Float) {
        runningTotal += Int(lengthOfButtTissue)
        print(runningTotal)
    }
    
    mutating func rip() {
        toiletPaperRipped = true
    }
    
    func endGame() {
        gameRound.updateScore { _ in return self.runningTotal/1000 }
        gameRound.endGame()
    }
}