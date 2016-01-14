//
//  TapTheDotViewController.swift
//  GameController
//
//  Created by Reid Chatham on 1/9/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

class TapTheDotViewController: UIViewController, GameRoundDelegate {
    
    var viewModel: TapTheDotViewModel
    
    init(viewModel: TapTheDotViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dotView : UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let sideLength : CGFloat = 100
        dotView = UIView(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
        dotView?.center = view.center
        dotView?.layer.cornerRadius = sideLength/2
        dotView?.backgroundColor = UIColor.redColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tappedDot:"))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        dotView?.addGestureRecognizer(tapGesture)
        view.addSubview(dotView!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dotView?.center = view.center
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.startGame(scoreUpdater: {
//            [weak self]
            score -> Int in
            print("Score match")
            
            return score - 1
            
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedDot(gesture: UITapGestureRecognizer) {
        print("tappedDot")
        viewModel.dotTapped()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
