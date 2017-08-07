//
//  GameRound.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 10/13/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

internal protocol MiniGameRoundDelegate: class {
    func gameRoundDidPause(_ miniGameRound: MiniGameRound)
    func gameRoundDidResume(_ miniGameRound: MiniGameRound)
    func gameRound(_ miniGameRound: MiniGameRound, endedGameWithScore score: Int)
}

internal class MiniGameRound {
    
    fileprivate typealias ScoreUpdater = (Int)->Int
    
    internal fileprivate(set) var gameType : MiniGameType?
    internal fileprivate(set) var score = 0
    fileprivate(set) var isPaused = false {
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
    
    internal var timeRemaining : Int? {
        // Returns the time remaining, the duration, or nil if not a timed game
        if let timer = gameTimer {
            return timer.timeRemaining
        }
        guard let type = gameType else { return nil }
        switch type {
        case .timed(let duration):
            return duration
        case .timedObjective(let duration):
            return duration
        default: return nil
        }
    }
    
    internal func setGameDelegate(_ delegate: MiniGameRoundDelegate) {
        if self.delegate == nil {
            self.delegate = delegate
        }
    }
    
    internal func setGameType(_ gameType: MiniGameType) {
        score = 0
        gameTimer?.stop()
        gameTimer = nil
        self.gameType = gameType
    }
    
    // MARK: - Private
    
    fileprivate weak var delegate : MiniGameRoundDelegate?
    fileprivate var gameTimer: Timer?
    
    fileprivate func startTimer() {
        guard let duration = timeRemaining else { return }
        gameTimer = Timer(timeInterval: Double(duration)) { [weak self] in self?.gameOver() }
    }
    
    fileprivate func updateScore(_ updater: ScoreUpdater) {
        score = updater(score)
    }
    
    fileprivate func pauseTimer() {
        if isPaused == false {
            gameTimer?.pause()
            isPaused = true
        }
    }
    
    fileprivate func resumeTimer() {
        if isPaused {
            gameTimer?.resume()
            isPaused = false
        }
    }
    
    fileprivate func endGame() {
        gameTimer?.stop()
        delegate!.gameRound(self, endedGameWithScore: score)
    }
    
    fileprivate func gameOver() {
        delegate!.gameRound(self, endedGameWithScore: score)
    }
}

extension MiniGameRound: MiniGameDelegate {
    internal func startGame(_ miniGame: MiniGame) { startTimer() }
    internal func pauseGame(_ miniGame: MiniGame) { pauseTimer() }
    internal func resumeGame(_ miniGame: MiniGame) { resumeTimer() }
    internal func endGame(_ miniGame: MiniGame) { endGame() }
    internal func updateScore(_ miniGame: MiniGame, scoreUpdater updater: (Int) -> Int) { updateScore(updater) }
}

extension MiniGameRound: MiniGameDataSource {
    internal func miniGameScore() -> Int { return score }
    internal func miniGameTimeRemaining() -> Int { return timeRemaining ?? 0 }
}
