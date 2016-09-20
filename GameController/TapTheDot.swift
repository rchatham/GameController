//
//  TapTheDot.swift
//  GameController
//
//  Created by Reid Chatham on 1/9/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct TapTheDot : MiniGame {
    
    weak var delegate: MiniGameDelegate?
    weak var dataSource: MiniGameDataSource?
    
    let gameType: MiniGameType = .timedObjective(duration: 15)
    let gameName = String(describing: TapTheDot.self)
    
    func readyViewController() -> UIViewController? {
        return nil
    }
    
    func recapViewController() -> UIViewController? {
        return nil
    }
    
    func gameViewController() -> UIViewController {
        return TapTheDotViewController(viewModel: viewModel())
    }
    
    fileprivate func viewModel() -> TapTheDotViewModel {
        return TapTheDotViewModel(delegate: self)
    }
}

extension TapTheDot: TapTheDotViewModelDelegate {
    
    func endGame() {
        delegate?.endGame(self)
    }
    
    func startGame() {
        delegate?.startGame(self)
    }
    
    func updateScore(_ updater: (Int) -> Int) {
        delegate?.updateScore(self, scoreUpdater: updater)
    }
}
