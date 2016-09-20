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
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        
        let path = Bundle.main.path(forResource: file, ofType: "sks")
        
        let sceneData: Data?
        do {
            sceneData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        let archiver = NSKeyedUnarchiver(forReadingWith: sceneData!)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! FlappyBirdGameScene
        archiver.finishDecoding()
        return scene
    }
}

class FlappyBirdGameViewController: UIViewController {

    @IBOutlet weak var sceneView: SKView! {
        didSet {
            view = sceneView
        }
    }
    
    fileprivate var viewModel : FlappyBirdViewModel
    
    init(viewModel: FlappyBirdViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "FlappyBirdGameViewController", bundle: nil)
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
        scene.scaleMode = .aspectFill
        
        sceneView.presentScene(scene)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        ESPresentationManager.sharedInstance.presentationController?.changeSize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        sceneView.
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.all
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
