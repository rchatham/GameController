//
//  CoverTheDotViewModel.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 12/26/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import Foundation

protocol CoverTheDotViewModelDelegate {
    func startGame()
    func updateScore(updater: Int->Int)
}

protocol CoverTheDotViewModelDataSource {
    func miniGameTimeRemaining() -> Int
    func miniGameScore() -> Int
}

struct CoverTheDotViewModel {
 
//    private weak var delegate: MiniGameDelegate?
    private var delegate: CoverTheDotViewModelDelegate
    private var dataSource: CoverTheDotViewModelDataSource
    
//    let timer : Timer
    
    init(delegate: CoverTheDotViewModelDelegate, dataSource: CoverTheDotViewModelDataSource) {
        self.delegate = delegate
        self.dataSource = dataSource
    }
    
    mutating func startGame(scoreUpdater updater: MiniGameRound.ScoreUpdater) {
        delegate.startGame()
//        switch gameRound.gameType! {
//        case .Timed(let duration):
            _ = Timer(timeInterval: 1, repeats: true, invalidateAfter: Double(dataSource.miniGameTimeRemaining())) {
                    self.delegate.updateScore(updater)
            }
//        default: break
//        }
    }
    
    func sizeRatio() -> Int {
        return Int.random(10) + 3
    }
    
    func maxBlocks() -> Int {
        return Int.random(10) + 1
    }

    func outputText() -> String {
        return "Time Remaining: \(dataSource.miniGameTimeRemaining()) Score: \(dataSource.miniGameScore())"
    }
}
