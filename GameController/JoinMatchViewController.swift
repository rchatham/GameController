//
//  JoinMatchViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit
import PeerConnectivity

class JoinMatchViewController: UIViewController {
    
    @IBOutlet weak var displayNameTextField: UITextField! {
        didSet {
            displayNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var connectionStyleSwitcher: UISegmentedControl! {
        didSet {
            connectionStyleSwitcher.selectedSegmentIndex = 0
        }
    }
    
    @IBOutlet weak var serviceTypeTextField: UITextField!
    
    
    private let viewModel : JoinMatchViewModel
    
    init(viewModel: JoinMatchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func go(sender: UIButton) {
        
        guard let displayName = displayNameTextField.text
            where !displayName.isEmpty
            else { return }
        
        switch (connectionStyleSwitcher.selectedSegmentIndex, serviceTypeTextField.text) {
            
        case (0, .None):
            startGame(connectionManager: viewModel.getConnectionManager(displayName))
            
        case (0, .Some(let serviceType)):
            startGame(connectionManager: viewModel.getConnectionManager(displayName, serviceType: serviceType))
            
        case (1, .None):
            startGame(connectionManager: viewModel.getConnectionManager(displayName, connectionType: connectionTypeForInt(1)))
            
        case (1, .Some(let serviceType)):
            startGame(connectionManager: viewModel.getConnectionManager(displayName, connectionType: connectionTypeForInt(1), serviceType: serviceType))
            
        default: fatalError("Invalid connection settings!")
        }
    }
    
    func connectionTypeForInt(int: Int) -> PeerConnectionType {
        switch int {
        case 0: return .Automatic
        case 1: return .InviteOnly
        default: fatalError("Switch case not handled!")
        }
    }
    
    func startGame(connectionManager connectionManager: PeerConnectionManager) {
        connectionManager.start()
        
        switch connectionManager.connectionType {
        case .Automatic:
            let gameCoordinator = GameCoordinator(connectionManager: connectionManager)
            gameCoordinator.startOnViewController(self)
        case .InviteOnly:
            let browser = connectionManager.browserViewController { (event) in
                switch event {
                case .DidFinish:
                    let gameCoordinator = GameCoordinator(connectionManager: connectionManager)
                    gameCoordinator.startOnViewController(self)
                default: break
                }
            }!
            presentViewController(browser, animated: true, completion: nil)
        case .Custom: break
            // TODO: - Determine what this case would look like in use and if this handles the case appropriately
        }
    }
}

extension JoinMatchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}
