//
//  GameRound.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 10/13/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

protocol GameRoundDelegate {
    func gameRoundDidPause(gameRound: GameRound)
    func gameRoundDidResume(gameRound: GameRound)
    func gameRound(gameRound: GameRound, endedGameWithScore score: Int)
}

public final class GameRound : NSObject {
    
    public typealias ScoreUpdater = Int->Int
    
    public enum Type {
        case Timed(duration: Int)
        case Objective
        case TimedObjective(duration: Int)
    }
    
    public private(set) var gameType : Type?
    
    public var timeRemaining : Int? {
        switch gameTimer {
        case .Some(let timer):
            return Int(timer.fireDate.timeIntervalSinceNow)
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
            if isPaused {
                delegate?.gameRoundDidPause(self)
            } else {
                delegate?.gameRoundDidResume(self)
            }
        }
    }
    
    public private(set) var score = 0
    
    private var delegate : GameRoundDelegate?
    
    private var gameTimer : NSTimer!
    
    internal func setGameDelegate(delegate: GameRoundDelegate) {
        if self.delegate == nil {
            self.delegate = delegate
        }
    }
    
    public func setGameType(gameType: Type) {
        if self.gameType == nil {
            self.gameType = gameType
        }
    }
    
    public func startTimedGame() {
        switch gameType! {
        case .TimedObjective(duration: let duration):
            
            gameTimer = NSTimer.scheduledTimerWithTimeInterval(Double(duration),
                target: self, selector: #selector(GameRound.gameOver(_:)),
                userInfo: nil, repeats: false)
            
        case .Timed(duration: let duration):
            
            gameTimer = NSTimer.scheduledTimerWithTimeInterval(Double(duration),
                target: self, selector: #selector(GameRound.gameOver(_:)),
                userInfo: nil, repeats: false)
            
        default: break
        }
    }
    
    public func updateScore(updater: ScoreUpdater) {
        score = updater(score)
    }
    
    public func pauseGame() {
        if isPaused == false {
            
            switch gameType! {
            case .TimedObjective(duration: _):
                let gameTimerRemaining = gameTimer.fireDate.timeIntervalSinceNow
                if gameTimerRemaining > 0 {
                    gameTimer.invalidate()
                }
                
            case .Timed(duration: _):
                let gameTimerRemaining = gameTimer.fireDate.timeIntervalSinceNow
                if gameTimerRemaining > 0 {
                    gameTimer.invalidate()
                }
                
            default: break
            }
            
            isPaused = true
        }
    }
    
    public func resumeGame() {
        if isPaused {
            
            switch gameType! {
            case .TimedObjective(duration: _):
                gameTimer = NSTimer.scheduledTimerWithTimeInterval(Double(timeRemaining!),
                    target: self, selector: #selector(GameRound.gameOver(_:)),
                    userInfo: nil, repeats: false)
                
            case .Timed(duration: _):
                gameTimer = NSTimer.scheduledTimerWithTimeInterval(Double(timeRemaining!),
                    target: self, selector: #selector(GameRound.gameOver(_:)),
                    userInfo: nil, repeats: false)
                
            default: break
            }
            
            isPaused = false
        }
    }
    
    public func endGame() {
        gameTimer?.invalidate()
        delegate!.gameRound(self, endedGameWithScore: score)
    }
    
    internal func gameOver(sender: NSTimer) {
        sender.invalidate()
        delegate!.gameRound(self, endedGameWithScore: score)
    }
}

extension GameRound : NSCopying {
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let gameRound = GameRound()
        gameRound.delegate = delegate
        gameRound.gameType = gameType
        return gameRound
    }
}
