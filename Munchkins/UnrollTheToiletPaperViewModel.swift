//
//  UnrollTheToiletPaperViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 7/27/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

protocol UnrollTheToiletPaperViewModelDelegate {
    func updateScore(_ updater: (Int)->Int)
    func endGame()
}

struct UnrollTheToiletPaperViewModel {
    
    fileprivate var delegate: UnrollTheToiletPaperViewModelDelegate
    
    internal fileprivate(set) var toiletPaperRipped = false
    fileprivate var runningTotal: Int = 0
    
    init(delegate: UnrollTheToiletPaperViewModelDelegate) {
        self.delegate = delegate
    }
    
    mutating func pullToiletPaperWith(velocity: (x: Float, y: Float), translation: (x: Float, y: Float)) {
        if velocity.y < 0 {
            // print("Swiping the wrong way dummy!")
        } else if velocity.x > 10 || velocity.x < -10
            && velocity.y > 45
            && translation.x > 50 || translation.x < -50 {
            rip()
        } else {
            unroll(Float(translation.y))
        }
    }
    
    mutating func unroll(_ lengthOfButtTissue: Float) {
        // print("Unrolled \(translation.y) toilet paper")
        runningTotal += Int(lengthOfButtTissue)
        print(runningTotal)
    }
    
    mutating func rip() {
        // print("Ripped the toilet paper!")
        toiletPaperRipped = true
    }
    
    mutating func endGame() {
        delegate.updateScore { _ in return self.runningTotal/1000 }
        delegate.endGame()
    }
}
