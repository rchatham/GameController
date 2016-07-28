//
//  UnrollTheToiletPaper.swift
//  GameController
//
//  Created by Reid Chatham on 7/27/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct UnrollTheToiletPaper: MiniGame {
    
    let gameRound: GameRound
    
    init(gameRound: GameRound) {
        self.gameRound = gameRound
        self.gameRound.setGameType(.Objective)
    }
    
    func viewController() -> UIViewController {
        let vm = UnrollTheToiletPaperViewModel(gameRound: gameRound)
        return UnrollTheToiletPaperViewController(viewModel: vm)
    }
}