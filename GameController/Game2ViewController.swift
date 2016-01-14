//
//  Game2ViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit

class Game2ViewController: UIViewController {
    
    @IBOutlet weak var outputLabel: UILabel! {
        didSet {
            self.outputLabel.text = viewModel.initialOutput()
        }
    }
    
    var viewModel : Game2ViewModel
    
    init(viewModel: Game2ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindViewModel() {
        viewModel.labelCallback = { [weak self] output in
            guard self?.outputLabel != nil else { return }
            self?.outputLabel.text = output
        }
        
        viewModel.gameStartCallback = { [weak self] in
            self?.presentGame()
        }
    }
    
    
//    let detailTransitioningDelegate: ESPresentationManager = ESPresentationManager.sharedInstance
    
    @IBAction func startGame(sender: AnyObject) {
        
        viewModel.initiateGame()
        viewModel.sendStartGameData()
        presentGame()
    }
    
    func presentGame() {
        
        guard let firstGame = viewModel.getNextGame() else { return }
        
        let firstGameVC = firstGame.viewController()
        let navCtrl = UINavigationController(rootViewController: firstGameVC)
        navCtrl.setNavigationBarHidden(true, animated: true)
        presentViewController(navCtrl, animated: true, completion: nil)
    }
}

extension Game2ViewController {
    //MARK: Functions
    
    @IBAction func goBack(sender: UIButton) {
        viewModel.endConnection()
        self.dismissViewControllerAnimated(true) {}
    }
    
}

extension Game2ViewController {
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputLabel.text = viewModel.initialOutput()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        outputLabel.text = viewModel.initialOutput()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension Game2ViewController {
    
//    func startGame() {
//        
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
