//
//  PickPlayerViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/20/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit

class PickPlayerViewController: UIViewController {
    
    let useBrowser = false

    @IBOutlet weak var textField: UITextField!
    
    @IBAction func go(sender: AnyObject) {
        
        guard let text = textField.text else { return }
        let peer = Peer(displayName: text)
        guard let peerController = (navigationController as? PeerConnectionController) else { return }
        peerController.peer = peer
        
        switch useBrowser {
        case true:
            peerController.browseForPeersWithListener { [unowned self] event in
                switch event {
                case .BrowserDidFinish: self.performSegueWithIdentifier("JoinGameSession", sender: self)
                default: break
                }
            }
        case false: performSegueWithIdentifier("JoinGameSession", sender: self)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
