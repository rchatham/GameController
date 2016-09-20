//
//  JoinMatchViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit
import PeerConnectivity

internal protocol JoinMatchViewControllerDelegate: class {
    func startGameWithConnection(_ connectionManager: PeerConnectionManager)
}

internal final class JoinMatchViewController: UIViewController {
    
    fileprivate let viewModel : JoinMatchViewModel
    fileprivate weak var delegate: JoinMatchViewControllerDelegate?
    
    init(viewModel: JoinMatchViewModel, delegate: JoinMatchViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func go(_ sender: UIButton) {
        
        guard let displayName = displayNameTextField.text
            , !displayName.isEmpty
            else { return }
        
        let connectionType = viewModel.connectionTypeForInt(connectionStyleSwitcher.selectedSegmentIndex)
        let connectionManager = viewModel.getConnectionManager(
            displayName: displayName,
            connectionType: connectionType,
            serviceType: serviceTypeTextField.text ?? ""
        )
        delegate?.startGameWithConnection(connectionManager)
    }
    
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
}

extension JoinMatchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
