//
//  CoverTheDotViewController.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 12/26/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

class CoverTheDotViewController: UIViewController {
    
    fileprivate var viewModel : CoverTheDotViewModel
    fileprivate lazy var animator: UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    fileprivate var dotView: DotView!
    fileprivate let blockBehavior = BlockBehavior()
    fileprivate var currentBlocks = [UIView]()
    fileprivate var blockSize: CGSize {
        let size = gameView.bounds.size.width / CGFloat(viewModel.sizeRatio())
        return CGSize(width: size, height: size)
    }

    @IBOutlet weak var gameView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer()
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.numberOfTapsRequired = 1
            tapGesture.addTarget(self, action: #selector(CoverTheDotViewController.tap(_:)))
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        animator.addBehavior(blockBehavior)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.startGame(scoreUpdater: {
            [weak self] score -> Int in
            // Score match
            
            guard let dotView = self?.dotView,
                let newPts = self?.blocksCoveringDot(dotView),
                let outputText = self?.viewModel.outputText()
                else { return score }
            self?.gameUpdateLabel.text = outputText
            
            return score + newPts
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        NotificationCenter.default.addObserver(
                forName: NSNotification.Name.UIApplicationDidBecomeActive,
                object: nil,
                queue: OperationQueue.main) { (notification) -> Void in
                
                    // Motionkit starts taking accelerometer updates.
                    AppDelegate.Static.Motion.getAccelerometerValues() {
                        [unowned self] (x: Double, y: Double, z: Double) in
                        
                        self.blockBehavior.gravity.gravityDirection = CGVector(dx: x, dy: -y)
                    }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        AppDelegate.Static.Motion.stopAccelerometerUpdates()
        
        dotView.removeFromSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if dotView == nil {
            dotView = DotView(frame: CGRect(x: gameView.frame.size.width/2,
                                            y: gameView.frame.size.height/2,
                                            width: 40,
                                            height: 40))
            gameView.addSubview(dotView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            
            // handling code
            let touchPosition = sender.location(in: gameView)
            let size = blockSize
            let x = touchPosition.x - (size.width/2)
            let y = touchPosition.y - (size.height/2)
            let location = CGPoint(x: x, y: y)
            dropBlocks(withLocation: location, size: size)
        }
    }
    
    fileprivate func blocksCoveringDot(_ dotView: DotView) -> Int {
        
        var blockCount = 0
        
        for view in gameView.subviews {
            if dotView !== view {
                if dotView.frame.intersects(view.frame) {
                    blockCount += 1
                }
            }
        }
        return blockCount
    }
    
    fileprivate func dropBlocks(withLocation location: CGPoint, size: CGSize) {
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
                currentBlocks.remove(at: 0)
            }
        }
    }
    
    fileprivate func removeBlocks() {
        for block in currentBlocks {
            blockBehavior.removeBlock(block)
        }
        currentBlocks.removeAll()
    }
}

extension CoverTheDotViewController : UIDynamicAnimatorDelegate {
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        AppDelegate.Static.Motion.stopAccelerometerUpdates()
    }
    
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        AppDelegate.Static.Motion.getAccelerometerValues() {
            [unowned self]
            (x: Double, y: Double, z: Double) in
            
            self.blockBehavior.gravity.gravityDirection = CGVector(dx: x, dy: -y)
        }
    }
    
}

