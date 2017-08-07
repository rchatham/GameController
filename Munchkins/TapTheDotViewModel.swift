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
    func updateScore(_ updater: (Int)->Int)
}

struct TapTheDotViewModel {
    
    fileprivate var delegate: TapTheDotViewModelDelegate
    
    fileprivate var tapCount = 0 {
        didSet {
            if tapCount >= 50 {
                delegate.endGame()
            }
        }
    }
    
    init(delegate: TapTheDotViewModelDelegate) {
        self.delegate = delegate
        
        _ = Timer(timeInterval: 1) {
            delegate.updateScore { (score) -> Int in
            return score - 1
            }
        }
    }
    
    mutating func dotTapped() {
        delegate.updateScore { (score) -> Int in
            return score + 1
        }
        tapCount += 1
    }
    
    func startGame() {
        delegate.startGame()
    }
    
//    func scoreGame() {
//        delegate.updateScore { (score) -> Int in
//            return score - 1
//        }
//    }
}
