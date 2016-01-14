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
        self.gameRound.score = 100
        self.gameRound.scoreUpdater = { score -> Int in
            return score - 1
        }
        
    }
    
    func viewModel() -> TapTheDotViewModel {
        return TapTheDotViewModel(gameRound: gameRound)
    }
    
    func viewController() -> UIViewController {
        return TapTheDotViewController(viewModel: viewModel())
    }
}