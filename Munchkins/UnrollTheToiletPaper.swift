//
//  UnrollTheToiletPaper.swift
//  GameController
//
//  Created by Reid Chatham on 7/27/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

struct UnrollTheToiletPaper: MiniGame {
    
    weak var delegate: MiniGameDelegate?
    weak var dataSource: MiniGameDataSource?
    
    let gameType: MiniGameType = .objective
    let gameName = String(describing: UnrollTheToiletPaper.self)
    
    func readyViewController() -> UIViewController? {
        return nil
    }
    
    func recapViewController() -> UIViewController? {
        return nil
    }
    
    func gameViewController() -> UIViewController {
        let vm = UnrollTheToiletPaperViewModel(delegate: self)
        return UnrollTheToiletPaperViewController(viewModel: vm)
    }
}

extension UnrollTheToiletPaper: UnrollTheToiletPaperViewModelDelegate {
    
    func endGame() {
        delegate?.endGame(self)
    }
    
    func updateScore(_ updater: (Int) -> Int) {
        delegate?.updateScore(self, scoreUpdater: updater)
    }
}
