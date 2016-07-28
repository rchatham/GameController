//
//  Game2ViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit

protocol GameViewControllerDelegate {
    func didStartGame(gameViewController: GameViewController, withMiniGames games: [MiniGame])
}

class GameViewController: UIViewController {
    
    @IBOutlet weak var outputLabel: UILabel!
    
    var delegate: GameViewControllerDelegate?
    
    var viewModel : GameViewModel
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    @IBAction func startGame(sender: AnyObject) {
        let games = viewModel.sendStartGameData()
        delegate?.didStartGame(self, withMiniGames: games)
    }
    
    @IBAction func goBack(sender: UIButton) {
        viewModel.endConnection()
        self.dismissViewControllerAnimated(true) {}
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        outputLabel.text = viewModel.initialOutput()
    }
}
