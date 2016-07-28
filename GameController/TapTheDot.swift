//
//  TapTheDot.swift
//  GameController
//
//  Created by Reid Chatham on 1/9/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct TapTheDot : MiniGame {
    
    let gameRound: GameRound
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
        self.gameRound.setGameType(.TimedObjective(duration: 15))
        self.gameRound.updateScore{_ in 100}
    }
    
    func viewModel() -> TapTheDotViewModel {
        return TapTheDotViewModel(gameRound: gameRound)
    }
    
    func viewController() -> UIViewController {
        return TapTheDotViewController(viewModel: viewModel())
    }
}