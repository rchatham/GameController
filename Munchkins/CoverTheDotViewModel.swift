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
    func updateScore(_ updater: (Int)->Int)
}

protocol CoverTheDotViewModelDataSource {
    func miniGameTimeRemaining() -> Int
    func miniGameScore() -> Int
}

struct CoverTheDotViewModel {
 
    fileprivate var delegate: CoverTheDotViewModelDelegate
    fileprivate var dataSource: CoverTheDotViewModelDataSource
    
    init(delegate: CoverTheDotViewModelDelegate, dataSource: CoverTheDotViewModelDataSource) {
        self.delegate = delegate
        self.dataSource = dataSource
    }
    
    mutating func startGame(scoreUpdater updater: @escaping MiniGameScoreUpdater) {
        self.delegate.startGame()
        
        let delegate = self.delegate
        _ = Timer(timeInterval: 1, repeats: true, invalidateAfter: Double(dataSource.miniGameTimeRemaining())) {
            
                delegate.updateScore(updater)
        }
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
