//
//  CoverTheDot.swift
//  GameController
//
//  Created by Reid Chatham on 1/2/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct CoverTheDot: MiniGame {
    
    let gameRound: GameRound
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
        self.gameRound.setGameType(.Timed(duration: 15))
    }
    
    func viewController() -> UIViewController {
        let vm = CoverTheDotViewModel(gameRound: gameRound)
        return CoverTheDotViewController(viewModel: vm)
    }
}