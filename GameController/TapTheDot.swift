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
    
    let gameType: MiniGameType = .TimedObjective(duration: 15)
    let gameName = String(TapTheDot)
    
    func readyViewController() -> UIViewController? {
        return nil
    }
    
    func recapViewController() -> UIViewController? {
        return nil
    }
    
    func gameViewController() -> UIViewController {
        return TapTheDotViewController(viewModel: viewModel())
    }
    
    private func viewModel() -> TapTheDotViewModel {
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
    
    func updateScore(updater: Int -> Int) {
        delegate?.updateScore(self, scoreUpdater: updater)
    }
}