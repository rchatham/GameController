//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        let sceneData: NSData?
        do {
            sceneData = try NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! FlappyBirdGameScene
        archiver.finishDecoding()
        return scene
    }
}

//class FlappyBirdGameViewController: UIViewController {
class FlappyBirdGameViewController: UIViewController { //, GameRoundDelegate {

    @IBOutlet weak var sceneView: SKView! {
        didSet {
            view = sceneView
        }
    }
    
    private var viewModel : FlappyBirdViewModel
    
    init(viewModel: FlappyBirdViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "FlappyBirdGameViewController", bundle: nil)
//        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let scene = FlappyBirdGameScene.unarchiveFromFile("FlappyBirdGameScene") as? FlappyBirdGameScene else { return }
        
        scene.gameOverScenario = { [weak self] in
            self?.viewModel.endGame()
        }
        scene.scoreUpdater = { [weak self] score in
            self?.viewModel.updateScore { oldScore in
                return score
            }
        }
        
        // Configure the view.
//        let skView = self.view as! SKView
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        sceneView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        sceneView.presentScene(scene)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        ESPresentationManager.sharedInstance.presentationController?.changeSize()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        sceneView.
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}

//extension FlappyBirdGameViewController: ESModalViewDelegate {
//    
//    func modalPresentationSize() -> CGSize {
//        return UIScreen.mainScreen().bounds.size
//    }
//}