//
//  CoverTheDot.swift
//  GameController
//
//  Created by Reid Chatham on 1/2/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct CoverTheDot: MiniGame {
    
    weak var delegate: MiniGameDelegate?
    weak var dataSource: MiniGameDataSource?
    
    let gameType: MiniGameType = .timed(duration: 15)
    let gameName = String(describing: CoverTheDot.self)
    
    func readyViewController() -> UIViewController? {
        return nil
    }
    
    func recapViewController() -> UIViewController? {
        return nil
    }
    
    func gameViewController() -> UIViewController {
        let vm = CoverTheDotViewModel(delegate: self, dataSource: self)
        return CoverTheDotViewController(viewModel: vm)
    }
}

extension CoverTheDot: CoverTheDotViewModelDelegate {
    
    func startGame() {
         delegate?.startGame(self)
    }
    
    func updateScore(_ updater: (Int) -> Int) {
        delegate?.updateScore(self, scoreUpdater: updater)
    }
}

extension CoverTheDot: CoverTheDotViewModelDataSource {
    
    func miniGameTimeRemaining() -> Int {
        return dataSource?.miniGameTimeRemaining() ?? 0
    }
    
    func miniGameScore() -> Int {
        return dataSource?.miniGameScore() ?? 0
    }
}
