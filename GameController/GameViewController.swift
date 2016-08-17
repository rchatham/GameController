//
//  Game2ViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit

internal protocol GameViewControllerDelegate: class {
    func didStartGame(gameViewController: GameViewController, withMiniGames games: [MiniGame])
    func didQuitGame(gameViewController: GameViewController)
}

internal final class GameViewController: UIViewController {
    
    private let viewModel : GameViewModel
    private weak var delegate: GameViewControllerDelegate?
    
    init(viewModel: GameViewModel, delegate: GameViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        outputLabel.text = viewModel.outputStringForArray()
    }
    
    func incrementScoreBy(points: Int) {
        viewModel.incrementScoreBy(points)
    }
    
    private func bindViewModel() {
        viewModel.labelCallback = { [weak self] output in
            guard self?.outputLabel != nil else { return }
            self?.outputLabel.text = output
        }
        
        viewModel.gameStartCallback = { [unowned self] games in
            self.delegate?.didStartGame(self, withMiniGames: games)
        }
    }
    
    @IBOutlet weak var outputLabel: UILabel!
    
    @IBAction func startGame(sender: AnyObject) {
        let games = viewModel.sendStartGameData()
        delegate?.didStartGame(self, withMiniGames: games)
    }
    
    @IBAction func goBack(sender: UIButton) {
        viewModel.endConnection()
        delegate?.didQuitGame(self)
//        self.dismissViewControllerAnimated(true) {}
    }
}
