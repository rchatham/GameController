//
//  GameRound.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 10/13/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

protocol GameRoundDelegate : class {
    
    func roundOver(gameRound: GameRound) -> (Void->Void)
}

extension GameRoundDelegate where Self : UIViewController {
    func roundOver(gameRound: GameRound) -> (Void -> Void) {
        return { [weak self] _ in
            
            guard self != nil else { return }
            guard let pvc = (self!.presentingViewController as? Game2ViewController) else {
                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            
            guard let nextGame = pvc.viewModel.getNextGame() else {
                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            let nextGameVC = nextGame.viewController()
            
            self!.navigationController?.pushViewController(nextGameVC, animated: true)
        }
    }
}

class GameRound : NSObject {
    
    enum Type {
        case Timed(duration: Int)
        case Objective
        case TimedObjective(duration: Int)
    }
    
    weak var delegate : GameRoundDelegate?
    
    let gameType : Type
    
    
    var gameTimer : NSTimer!
    var scoreTimer : NSTimer!
    var timeRemaining : Int?
    
    //Set this if you need to automatically check for updates to the score
    var scoreUpdater : (Int->Int) = { $0 }
    var shouldEndGame : Int->Void = {_ in}
    
    private(set) var isPaused = false
    
    var score = 0 {
        didSet {
            
            switch gameType {
            case .Timed(duration: _):
                guard timeRemaining > 0 else { scoreTimer.invalidate(); return }
            default: break
            }
        }
    }
    
    init(gameType: Type) {
        self.gameType = gameType
        switch gameType {
        case .Timed(duration: let duration):
            timeRemaining = duration
        case .Objective: break
        case .TimedObjective(duration: let duration):
            timeRemaining = duration
        }
        
        super.init()
    }
    
    func startTimedGame(scoreUpdater updater: (Int->Int) = { $0 }, gameOverScenario: Int->Void) {
            
        scoreUpdater = updater
        shouldEndGame = gameOverScenario
        
        switch gameType {
        case .TimedObjective(duration: let gameDuration):
            
            gameTimer = NSTimer.scheduledTimerWithTimeInterval(Double(gameDuration),
                target: self, selector: Selector("gameOver:"),
                userInfo: nil, repeats: false)
            scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                target: self, selector: Selector("scoreGame:"),
                userInfo: nil, repeats: true)
            
        case .Timed(duration: let gameDuration):
            
            gameTimer = NSTimer.scheduledTimerWithTimeInterval(Double(gameDuration),
                target: self, selector: Selector("gameOver:"),
                userInfo: nil, repeats: false)
            scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                target: self, selector: Selector("scoreGame:"),
                userInfo: nil, repeats: true)
            
        case .Objective: break
        default: break
        }
    }
    
    func updateScore(updater: (Int->Int)) { //Use when you want to manually update the score
        score = updater(score)
    }
    
    func scoreGame(timer: NSTimer) {
        print("Score game")
        timeRemaining? -= 1
        score = scoreUpdater(score)
    }
    
    func pauseGame() {
        isPaused = true
        
        switch gameType {
        case .TimedObjective(duration: _):
            let gameTimerRemaining = gameTimer.fireDate.timeIntervalSinceNow
            if gameTimerRemaining > 0 {
                gameTimer.invalidate()
                scoreTimer.invalidate()
                timeRemaining = Int(gameTimerRemaining)
            }
            
        case .Timed(duration: _):
            let gameTimerRemaining = gameTimer.fireDate.timeIntervalSinceNow
            if gameTimerRemaining > 0 {
                gameTimer.invalidate()
                scoreTimer.invalidate()
                timeRemaining = Int(gameTimerRemaining)
            }
        
        case .Objective: break
        default: break
        }
    }
    
    func resumeGame() {
        if isPaused {
            
            switch gameType {
            case .TimedObjective(duration: _):
                gameTimer = NSTimer.scheduledTimerWithTimeInterval(Double(timeRemaining!),
                    target: self, selector: Selector("gameOver:"),
                    userInfo: nil, repeats: false)
                scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                    target: self, selector: Selector("scoreGame:"),
                    userInfo: nil, repeats: true)
                
            case .Timed(duration: _):
                gameTimer = NSTimer.scheduledTimerWithTimeInterval(Double(timeRemaining!),
                    target: self, selector: Selector("gameOver:"),
                    userInfo: nil, repeats: false)
                scoreTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                    target: self, selector: Selector("scoreGame:"),
                    userInfo: nil, repeats: true)
                
            case .Objective: break
            default: break
            }
            
            isPaused = false
        }
    }
    
    func endGame() {
        scoreTimer?.invalidate()
        gameTimer?.invalidate()
        shouldEndGame(score)
        delegate?.roundOver(self)()
    }
    
    func gameOver(sender: NSTimer) {
        scoreTimer.invalidate()
        shouldEndGame(score)
        delegate?.roundOver(self)()
    }
}

extension GameRound : NSCopying {
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return GameRound(gameType: gameType)
    }
}
