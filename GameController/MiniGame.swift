//
//  MiniGame.swift
//  GameController
//
//  Created by Reid Chatham on 1/2/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

public protocol MiniGameDelegate: class {
    func startGame(miniGame: MiniGame)
    func pauseGame(miniGame: MiniGame)
    func resumeGame(miniGame: MiniGame)
    func endGame(miniGame: MiniGame)
    func updateScore(miniGame: MiniGame, scoreUpdater updater: Int->Int)
}

public protocol MiniGameDataSource: class {
    func miniGameTimeRemaining() -> Int
    func miniGameScore() -> Int
}

///*
public enum MiniGameType {
    case Objective
    case Timed(duration: Int)
    case TimedObjective(duration: Int)
}
//*/

public protocol MiniGame {
    
    weak var delegate: MiniGameDelegate? { get set }
    weak var dataSource: MiniGameDataSource? { get set }
    
    var gameType: MiniGameType { get }
    var gameName: String { get }
    
    func readyViewController()  -> UIViewController?
    func gameViewController()   -> UIViewController
    func recapViewController()  -> UIViewController?
}