//
//  UnrollTheToiletPaperViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 7/27/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

protocol UnrollTheToiletPaperViewModelDelegate {
    func updateScore(updater: Int->Int)
    func endGame()
}

struct UnrollTheToiletPaperViewModel {
    
    private var delegate: UnrollTheToiletPaperViewModelDelegate
    
    internal private(set) var toiletPaperRipped = false
    private var runningTotal: Int = 0
    
    init(delegate: UnrollTheToiletPaperViewModelDelegate) {
        self.delegate = delegate
    }
    mutating func unroll(lengthOfButtTissue: Float) {
        runningTotal += Int(lengthOfButtTissue)
        print(runningTotal)
    }
    
    mutating func rip() {
        toiletPaperRipped = true
    }
    
    mutating func endGame() {
        delegate.updateScore { _ in return self.runningTotal/1000 }
        delegate.endGame()
    }
}