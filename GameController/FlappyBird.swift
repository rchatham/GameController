//
//  FlappyBird.swift
//  GameController
//
//  Created by Reid Chatham on 1/8/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct FlappyBird : MiniGame {
    
    weak var delegate: MiniGameDelegate?
    weak var dataSource: MiniGameDataSource?
    
    let gameType: MiniGameType = .Objective
    
    var gameName: String {
        return String(FlappyBird)
    }
    
    func readyViewController() -> UIViewController? {
        return nil
    }
    
    func recapViewController() -> UIViewController? {
        return nil
    }
    
    func gameViewController() -> UIViewController {
        return FlappyBirdGameViewController(viewModel: viewModel())
    }
    
    private func viewModel() -> FlappyBirdViewModel {
        return FlappyBirdViewModel(delegate: self)
    }
}

extension FlappyBird: FlappyBirdViewModelDelegate {
    
    func endGame() {
        delegate?.endGame(self)
    }
    
    func updateScore(updater: Int->Int) {
        delegate?.updateScore(self, scoreUpdater: updater)
    }
}