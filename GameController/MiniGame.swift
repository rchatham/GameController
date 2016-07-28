//
//  MiniGame.swift
//  GameController
//
//  Created by Reid Chatham on 1/2/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

public protocol MiniGame {
    
    var gameRound : GameRound { get }
    
    init(gameRound: GameRound)
    
    func viewController() -> UIViewController
}