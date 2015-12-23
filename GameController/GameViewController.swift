//
//  GameViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/20/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var outputLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let peerController = (navigationController as? PeerConnectionController) else { return }
        guard let displayNames = peerController.connectionManager?.displayNames else { return }
        
        outputLabel.text = outputStringForArray(prefix: "Connected users:",
            array: displayNames,
            postfix: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let peerController = (navigationController as? PeerConnectionController) else { return }
        
        
        peerController.connectionManager?
            .listenOn(devicesChanged: {
                [weak self] (peer, names) -> Void in
                
                self?.outputLabel.text = self?.outputStringForArray(
                    prefix: "Connected users:",
                    array: names,
                    postfix: nil)
            })//.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        guard let peerController = (navigationController as? PeerConnectionController) else { return }
//        peerController.endConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func outputStringForArray(prefix prefix: String? = nil, array: [String], postfix: String? = nil) -> String {
        var output = ""
        switch prefix {
        case .None: break
        case.Some(let p): output += (p + "\n")
        }
        for string in array {
            output += (string + "\n")
        }
        switch postfix {
        case .None: break
        case .Some(let p): output += p
        }
        return output
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
