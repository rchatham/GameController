//
//  FlappyBird.swift
//  GameController
//
//  Created by Reid Chatham on 1/8/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct FlappyBird : MiniGame {
    
    let gameRound : GameRound
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
        self.gameRound.setGameType(.Objective)
    }
    
    func viewModel() -> FlappyBirdViewModel {
        return FlappyBirdViewModel(gameRound: gameRound)
    }
    
    func viewController() -> UIViewController {
        return FlappyBirdGameViewController(viewModel: viewModel())
    }
}