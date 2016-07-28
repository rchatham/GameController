//
//  TapTheDotViewController.swift
//  GameController
//
//  Created by Reid Chatham on 1/9/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

class TapTheDotViewController: UIViewController {
    
    var viewModel: TapTheDotViewModel
    
    init(viewModel: TapTheDotViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TapTheDotViewController.tappedDot(_:)))
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
        
        viewModel.startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedDot(gesture: UITapGestureRecognizer) {
        print("tappedDot")
        viewModel.dotTapped()
    }
}
