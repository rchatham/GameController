//
//  GameRound.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 10/13/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

public protocol MiniGameRoundDelegate: class {
    func gameRoundDidPause(miniGameRound: MiniGameRound)
    func gameRoundDidResume(miniGameRound: MiniGameRound)
    func gameRound(miniGameRound: MiniGameRound, endedGameWithScore score: Int)
}

public class MiniGameRound {
    
    public typealias ScoreUpdater = Int->Int
    
    public private(set) var gameType : MiniGameType?
    
    private var delegate : MiniGameRoundDelegate?
    
    private var gameTimer: Timer?
    
    public var timeRemaining : Int? {
        // Should reuturn the time remaining or nil if not a timed game
        switch gameTimer {
        case .Some(let timer):
            return timer.timeRemaining
        case .None:
            switch gameType {
            case .Some(let type):
                switch type {
                case .Timed(let duration):
                    return duration
                case .TimedObjective(let duration):
                    return duration
                default: return nil
                }
            default: return nil
            }
        }
    }
    private(set) var isPaused = false {
        didSet {
            if oldValue != isPaused {
                if isPaused {
                    delegate?.gameRoundDidPause(self)
                } else {
                    delegate?.gameRoundDidResume(self)
                }
            }
        }
    }
    
    public private(set) var score = 0
    
    internal func setGameDelegate(delegate: MiniGameRoundDelegate) {
//        self.delegate = delegate
        if self.delegate == nil {
            self.delegate = delegate
        }
    }
    
    internal func setGameType(gameType: MiniGameType) {
        self.gameType = gameType
//        if self.gameType == nil {
//            self.gameType = gameType
//        }
    }
    
    private func startTimer() {
        
        guard let duration = timeRemaining else { return }
        gameTimer = Timer(timeInterval: Double(duration)) { self.gameOver() }
        
//        switch gameType! {
//        case .TimedObjective(duration: let duration):
//            
//            gameTimer = Timer(timeInterval: Double(duration)) { self.gameOver() }
//            
//        case .Timed(duration: let duration):
//            
//            gameTimer = Timer(timeInterval: Double(duration)) { self.gameOver() }
//            
//        default: break
//        }
    }
    
    private func updateScore(updater: ScoreUpdater) {
        score = updater(score)
    }
    
    private func pauseTimer() {
        if isPaused == false {
            
            gameTimer?.pause()
            isPaused = true
        }
    }
    
    private func resumeTimer() {
        if isPaused {
            
            gameTimer?.resume()
            isPaused = false
        }
    }
    
    private func endGame() {
        gameTimer?.stop()
        delegate!.gameRound(self, endedGameWithScore: score)
    }
    
    private func gameOver() {
        delegate!.gameRound(self, endedGameWithScore: score)
    }
}

extension MiniGameRound: MiniGameDelegate {
    
    public func startGame(miniGame: MiniGame) { startTimer() }
    public func pauseGame(miniGame: MiniGame) { pauseTimer() }
    public func resumeGame(miniGame: MiniGame) { resumeTimer() }
    public func endGame(miniGame: MiniGame) { endGame() }
    public func updateScore(miniGame: MiniGame, scoreUpdater updater: Int -> Int) { updateScore(updater) }
}

extension MiniGameRound: MiniGameDataSource {
    
    public func miniGameScore() -> Int { return score }
    public func miniGameTimeRemaining() -> Int { return timeRemaining ?? 0 }
}
