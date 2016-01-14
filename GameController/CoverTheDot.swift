//
//  CoverTheDot.swift
//  GameController
//
//  Created by Reid Chatham on 1/2/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct CoverTheDot : MiniGame {
    
    let gameRound : GameRound
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
    }
    
    func viewModel() -> CoverTheDotViewModel {
        return CoverTheDotViewModel(gameRound: gameRound)
    }
    
    func viewController() -> UIViewController {
        return CoverTheDotViewController(viewModel: viewModel())
    }
}