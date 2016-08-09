//
//  UnrollTheToiletPaperViewController.swift
//  GameController
//
//  Created by Reid Chatham on 7/27/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

class UnrollTheToiletPaperViewController: UIViewController {
    
    private var viewModel: UnrollTheToiletPaperViewModel
    
    init(viewModel: UnrollTheToiletPaperViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(UnrollTheToiletPaperViewController.unroll))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func unroll(gesture: UIPanGestureRecognizer) {
        
        guard viewModel.toiletPaperRipped == false
            else {
                view.removeGestureRecognizer(gesture)
                return viewModel.endGame()
        }
        
        let velocity = gesture.translationInView(view)
        let translation = gesture.velocityInView(view)
        
        if velocity.y < 0 {
            print("Swiping the wrong way dummy!")
        } else if velocity.x > 10 || velocity.x < -10
            && velocity.y > 45
            && translation.x > 50 || translation.x < -50 {
            viewModel.rip()
            print("Ripped the toilet paper!")
        } else {
            viewModel.unroll(Float(translation.y))
            print("Unrolled \(translation.y) toilet paper")
        }
    }
}
