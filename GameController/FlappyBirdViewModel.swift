//
//  FlappyBirdViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 1/8/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

protocol FlappyBirdViewModelDelegate {
    func endGame()
    func updateScore(_ updater: (Int)->Int)
}

struct FlappyBirdViewModel {
    
    fileprivate var delegate : FlappyBirdViewModelDelegate
    
    init(delegate: FlappyBirdViewModelDelegate) {
        self.delegate = delegate
    }
    
    func endGame() {
        delegate.endGame()
    }
    
    func updateScore(_ updater: (Int)->Int) {
        delegate.updateScore(updater)
    }
}
