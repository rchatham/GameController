//
//  Game2ViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit
import Architecture

internal protocol GameViewControllerDelegate: class {
    func didStartGame(_ gameViewController: GameViewController, withMiniGames games: [MiniGame])
    func didQuitGame(_ gameViewController: GameViewController)
}

internal final class GameViewController: UIViewController, ViewModelable {
    
    internal let viewModel : GameViewModel
    weak var delegate: GameViewControllerDelegate?
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        outputLabel.text = viewModel.outputStringForArray()
        viewModel.connectionManager.start()
    }
    
    func incrementScoreBy(_ points: Int) {
        viewModel.incrementScoreBy(points)
    }
    
    fileprivate func bindViewModel() {
        viewModel.labelCallback = { [weak self] output in
            self?.outputLabel?.text = output
        }
        
        viewModel.gameStartCallback = { [unowned self] games in
            self.viewModel.connectionManager.closeSession()
            self.delegate?.didStartGame(self, withMiniGames: games)
        }
    }
    
    @IBOutlet weak var outputLabel: UILabel!
    
    @IBAction func startGame(_ sender: AnyObject) {
        let games = viewModel.sendStartGameData()
        delegate?.didStartGame(self, withMiniGames: games)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        viewModel.endConnection()
        delegate?.didQuitGame(self)
    }
}
