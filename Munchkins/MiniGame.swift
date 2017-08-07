//
//  MiniGame.swift
//  GameController
//
//  Created by Reid Chatham on 1/2/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

public protocol MiniGameDelegate: class {
    func startGame(_ miniGame: MiniGame)
    func pauseGame(_ miniGame: MiniGame)
    func resumeGame(_ miniGame: MiniGame)
    func endGame(_ miniGame: MiniGame)
    func updateScore(_ miniGame: MiniGame, scoreUpdater updater: MiniGameScoreUpdater)
}

public protocol MiniGameDataSource: class {
    func miniGameTimeRemaining() -> Int
    func miniGameScore() -> Int
}

public enum MiniGameType {
    case objective
    case timed(duration: Int)
    case timedObjective(duration: Int)
}

public typealias MiniGameScoreUpdater = (Int)->Int

public protocol MiniGame {
    
    weak var delegate: MiniGameDelegate? { get set }
    weak var dataSource: MiniGameDataSource? { get set }
    
    var gameType: MiniGameType { get }
    var gameName: String { get }
    
    func readyViewController()  -> UIViewController?
    func gameViewController()   -> UIViewController
    func recapViewController()  -> UIViewController?
}
