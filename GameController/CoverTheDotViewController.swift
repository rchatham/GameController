//
//  CoverTheDotViewController.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 12/26/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

class CoverTheDotViewController: UIViewController, GameRoundDelegate {
    
    private var viewModel : CoverTheDotViewModel
    
    lazy var animator: UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    var dotView: DotView!
    
    let blockBehavior = BlockBehavior()
    
    var currentBlocks = [UIView]()
    
    var blockSize: CGSize {
        let size = gameView.bounds.size.width / CGFloat(viewModel.sizeRatio())
        return CGSize(width: size, height: size)
    }

    
    @IBOutlet weak var gameView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.numberOfTapsRequired = 1
            tapGesture.addTarget(self, action: Selector("tap:"))
            gameView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet weak var gameUpdateLabel: UILabel! {
        didSet {
            gameUpdateLabel.text = viewModel.outputText()
        }
    }
    
    init(viewModel: CoverTheDotViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CoverTheDotViewController {
    // Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        animator.addBehavior(blockBehavior)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.startGame(scoreUpdater: {
            [weak self]
            score -> Int in
            print("Score match")
            
            guard let dotView = self?.dotView else { return score }
            guard let newPts = self?.blocksCoveringDot(dotView) else { return score }
            guard let outputText = self?.viewModel.outputText() else { return score }
            self?.gameUpdateLabel.text = outputText
            
            return score + newPts
            
            }, gameOverScenario: { [weak self] score in
                
                guard let pvc = self?.presentingViewController as? Game2ViewController else { return }
                pvc.viewModel.player.incrementScoreBy(score)
                
                if let subviews = self?.view.subviews {
                    for view in subviews {
                        view.removeFromSuperview()
                    }
                }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        NSNotificationCenter
            .defaultCenter()
            .addObserverForName(UIApplicationDidBecomeActiveNotification,
                object: nil, queue: NSOperationQueue.mainQueue()) {
                    (notification) -> Void in
                
                    print("Motionkit starts taking accelerometer updates")
                    let motionKit = AppDelegate.Motion.Kit
                    motionKit.getAccelerometerValues(){
                        [unowned self]
                        (x: Double, y: Double, z: Double) in
                        
                        self.blockBehavior.gravity.gravityDirection = CGVector(dx: x, dy: -y)
                    }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if dotView == nil {
            dotView = DotView(frame: CGRect(x: gameView.frame.size.width/2 , y: gameView.frame.size.height/2, width: 40, height: 40))
            gameView.addSubview(dotView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CoverTheDotViewController {
    // MARK: Gesture functions
    
    func tap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            // handling code
            print("Handle tap with ended state")
            let touchPosition = sender.locationInView(gameView)
            let size = blockSize
            let x = touchPosition.x - (size.width/2)
            let y = touchPosition.y - (size.height/2)
            let location = CGPoint(x: x, y: y)
            dropBlocks(withLocation: location, size: size)
        }
    }
}

extension CoverTheDotViewController : UIDynamicAnimatorDelegate {
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        
    }
    
    func dynamicAnimatorWillResume(animator: UIDynamicAnimator) {
        let motionKit = AppDelegate.Motion.Kit
        motionKit.getAccelerometerValues() {
            [unowned self]
            (x: Double, y: Double, z: Double) in
            
            self.blockBehavior.gravity.gravityDirection = CGVector(dx: x, dy: -y)
        }
    }
    
}

extension CoverTheDotViewController {
    
    func blocksCoveringDot(dotView: DotView) -> Int {
        
        var blockCount = 0
        
        for view in gameView.subviews {
            if dotView !== view {
//            if !dotView.isEqual(view) {
                if CGRectIntersectsRect(dotView.frame, view.frame) {
                    ++blockCount
                }
            }
        }
        return blockCount
    }
    
    func dropBlocks(withLocation location: CGPoint, size: CGSize) {
        let frame = CGRect(origin: location, size: size)
        
        let blockCount = viewModel.maxBlocks()
        for _ in 0..<Int.random(blockCount) {
            let blockView = UIView(frame:frame)
            blockView.backgroundColor = UIColor.random
            currentBlocks.append(blockView)
            blockBehavior.addBlock(blockView)
        }
        
        if currentBlocks.count > blockCount {
            for _ in blockCount..<currentBlocks.count {
                blockBehavior.removeBlock(currentBlocks[0])
                currentBlocks.removeAtIndex(0)
            }
        }
    }
    
    func removeBlocks() {
        for block in currentBlocks {
            blockBehavior.removeBlock(block)
        }
        currentBlocks.removeAll()
    }
}
