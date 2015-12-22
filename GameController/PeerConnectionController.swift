//
//  ViewController.swift
//  GameController
//
//  Created by Reid Chatham on 10/30/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PeerConnectionController: UINavigationController {
    
    typealias ServiceType = String //Not more than 15 characters!!!!!
    
    var peer : Peer? {
        didSet {
            guard let peer = peer else { return }
//            guard connectionManager == nil else { return }
            connectionManager = PeerConnectionManager(
                serviceType: serviceType ?? defaultService,
                peer: peer)
        }
    }
    var connectionManager : PeerConnectionManager? { didSet { NSLog("%@", "connection manager set") } }
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    var serviceType : ServiceType? {
        didSet {
            guard let peer = peer else { return }
            let service = serviceType != nil && serviceType!.characters.count <= 15 ? serviceType! : defaultService
            connectionManager = PeerConnectionManager(
                serviceType: service,
                peer: peer)
        }
    }
    private let defaultService : ServiceType = "default-service"
    
    private let mpcBrowserObserver = Observable<MPCBrowserEvent>(.None)
    
    typealias MPCBrowserEventListener = MPCBrowserEvent->Void
    private var listeners : [MPCBrowserEventListener] = []
    
    
    // LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func browseForPeers() {
        guard let connectionManager = connectionManager else { return }
        let browserVC = connectionManager.browserViewController()
        browserVC.delegate = self
        topViewController?.presentViewController(browserVC, animated: true, completion: nil)
    }
    
    func browseForPeersWithListener(listener: MPCBrowserEventListener) {
        guard let connectionManager = connectionManager else { return }
        let browserVC = connectionManager.browserViewController()
        addListener(listener)
        browserVC.delegate = self
        topViewController?.presentViewController(browserVC, animated: true, completion: nil)
    }
    
    func addListener(listener: MPCBrowserEventListener) {
        listeners.append(listener)
        mpcBrowserObserver.addObserver(listener)
    }
    
    func addListeners(listeners: [MPCBrowserEventListener]) {
        listeners.forEach { addListener($0) }
    }

    func removeListeners() {
        listeners = []
        mpcBrowserObserver.observers = nil
    }
}

enum MPCBrowserEvent {
    case None
    case BrowserDidFinish
    case BrowserWasCancelled
}

extension PeerConnectionController : MCBrowserViewControllerDelegate {
    
    func browserViewController(browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        NSLog("%2", "browserViewController shouldPresentNearbyPeer: \(peerID) withDiscoveryInfo: \(info)")
        return true
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        NSLog("%@", "browserViewControllerDidFinish")
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
        mpcBrowserObserver.value = .BrowserDidFinish
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        NSLog("%@", "browserViewControllerWasCancelled")
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
        mpcBrowserObserver.value = .BrowserWasCancelled
    }
}
