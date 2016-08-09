//
//  GameRound.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 10/13/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

internal protocol MiniGameRoundDelegate: class {
    func gameRoundDidPause(miniGameRound: MiniGameRound)
    func gameRoundDidResume(miniGameRound: MiniGameRound)
    func gameRound(miniGameRound: MiniGameRound, endedGameWithScore score: Int)
}

internal class MiniGameRound {
    
    private typealias ScoreUpdater = Int->Int
    
    internal private(set) var gameType : MiniGameType?
    
    private var delegate : MiniGameRoundDelegate?
    
    private var gameTimer: Timer?
    
    internal var timeRemaining : Int? {
        // Should reuturn the time remaining, the duration, or nil if not a timed game
        if let timer = gameTimer {
            return timer.timeRemaining
        }
        guard let type = gameType else { return nil }
        switch type {
        case .Timed(let duration):
            return duration
        case .TimedObjective(let duration):
            return duration
        default: return nil
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
    
    internal private(set) var score = 0
    
    internal func setGameDelegate(delegate: MiniGameRoundDelegate) {
        if self.delegate == nil {
            self.delegate = delegate
        }
    }
    
    internal func setGameType(gameType: MiniGameType) {
        self.gameType = gameType
    }
    
    private func startTimer() {
        guard let duration = timeRemaining else { return }
        gameTimer = Timer(timeInterval: Double(duration)) { self.gameOver() }
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
    
    internal func startGame(miniGame: MiniGame) { startTimer() }
    internal func pauseGame(miniGame: MiniGame) { pauseTimer() }
    internal func resumeGame(miniGame: MiniGame) { resumeTimer() }
    internal func endGame(miniGame: MiniGame) { endGame() }
    internal func updateScore(miniGame: MiniGame, scoreUpdater updater: Int -> Int) { updateScore(updater) }
}

extension MiniGameRound: MiniGameDataSource {
    
    internal func miniGameScore() -> Int { return score }
    internal func miniGameTimeRemaining() -> Int { return timeRemaining ?? 0 }
}
