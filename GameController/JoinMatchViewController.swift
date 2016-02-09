//
//  JoinMatchViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit

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
    
}

extension JoinMatchViewController {
    // MARK: Functions

    @IBAction func go(sender: UIButton) {
        
        guard let displayName = displayNameTextField.text else { return }
        guard !displayName.isEmpty else { return }
        
        switch (connectionStyleSwitcher.selectedSegmentIndex, serviceTypeTextField.text) {
            
        case (0, .None):
            let (player, connectionManager) = viewModel.gameInfo(displayName)
            startGame(connectionManager: connectionManager, player: player)
            
        case (0, .Some(let serviceType)):
            let (player, connectionManager) = viewModel.gameInfo(displayName, serviceType: serviceType)
            startGame(connectionManager: connectionManager, player: player)
            
        case (1, .None):
            let (player, connectionManager) = viewModel.gameInfo(displayName, connectionType: connectionTypeForInt(1))
            startGame(connectionManager: connectionManager, player: player)
            
        case (1, .Some(let serviceType)):
            let (player, connectionManager) = viewModel.gameInfo(displayName, connectionType: connectionTypeForInt(1), serviceType: serviceType)
            startGame(connectionManager: connectionManager, player: player)
            
        default: break
        }
    }
    
    func connectionTypeForInt(int: Int) -> PeerConnectionType {
        return connectionTypeForInt2(int) { [weak self] browserAssisstant in
            
            self?.presentViewController(browserAssisstant.peerBrowserViewController(), animated: true, completion: nil)
        }
    }
    
    func connectionTypeForInt2(int: Int, completion: PeerBrowserAssisstant->Void) -> PeerConnectionType {
        switch int {
        case 1: return PeerConnectionType.InviteOnly(completion)
        default: return .Automatic
        }
    }
    
    func presentGameController(viewModel: Game2ViewModel) {
        let gameVC = Game2ViewController(viewModel: viewModel)
        self.presentViewController(gameVC, animated: true, completion: nil)
    }
    
    func startGame(var connectionManager connectionManager: PeerConnectionManager, player: Player) {
        connectionManager.start { [weak self] in
            guard let gameVM = self?.viewModel.gameViewModel(player, connectionManager: connectionManager) else { return }
            self?.presentGameController(gameVM)
        }
    }
    
}

extension JoinMatchViewController {
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension JoinMatchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}

extension JoinMatchViewController {
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
