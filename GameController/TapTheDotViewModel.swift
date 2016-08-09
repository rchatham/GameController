//
//  TapTheDotViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 1/9/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

protocol TapTheDotViewModelDelegate {
    func startGame()
    func endGame()
    func updateScore(updater: Int->Int)
}

struct TapTheDotViewModel {
    
    private var delegate: TapTheDotViewModelDelegate
    
    private var tapCount = 0 {
        didSet {
            if tapCount >= 50 {
                delegate.endGame()
            }
        }
    }
    
    init(delegate: TapTheDotViewModelDelegate) {
        self.delegate = delegate
    }
    
    mutating func dotTapped() {
        tapCount += 1
    }
    
    func startGame() {
        delegate.startGame()
    }
    
    func scoreGame() {
        delegate.updateScore { (score) -> Int in
            return score - 1
        }
    }
}