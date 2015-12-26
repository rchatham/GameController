//
//  Game2ViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit

class Game2ViewController: UIViewController {
    
    @IBOutlet weak var outputLabel: UILabel!
    
    private var viewModel : Game2ViewModel
    
    init(viewModel: Game2ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindViewModel() {
        let labelLinker: String->Void = { output in
            self.outputLabel.text = output
        }
        viewModel.labelCallback = labelLinker
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension Game2ViewController {

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
