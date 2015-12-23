//
//  ViewController.swift
//  GameController
//
//  Created by Reid Chatham on 10/30/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import UIKit
import MultipeerConnectivity

enum MPCConnectionStyle {
    case Automatic
    case Assisstant
}

enum MPCAssisstantEvent {
    case None
    case BrowserDidFinish
    case BrowserWasCancelled
}

class PeerConnectionController: UINavigationController {
    
    typealias ServiceType = String //Not more than 15 characters!!!!!
    
    var peer : Peer? {
        didSet {
            guard let peer = peer else { return }
            guard connectionManager == nil else { return }
            connectionManager = PeerConnectionManager(
                serviceType: serviceType ?? defaultService,
                peer: peer)
        }
    }
    internal private(set) var connectionManager : PeerConnectionManager? { didSet { NSLog("%@", "connection manager set") } }
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    var serviceType : ServiceType {
        get {
            return connectionManager?.serviceType ?? (service ?? defaultService)
        }
        set(serviceType) {
            self.service = serviceType.characters.count <= 15 ? serviceType : defaultService
            guard let peer = peer else { return }
            let service = self.serviceType
            connectionManager = PeerConnectionManager(
                serviceType: service,
                peer: peer)
        }
    }
    private var service : ServiceType?
    private let defaultService : ServiceType = "default-service"
    
    
    let connectionStyle : MPCConnectionStyle = .Assisstant
    
    
    private let mpcAssisstantObserver = Observable<MPCAssisstantEvent>(.None)
    
    typealias MPCAssisstantListener = MPCAssisstantEvent->Void
    private var listeners : [MPCAssisstantListener] = []

    
    
    // LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAssisstant(hostinghandler hostingHandler: Void->Void, joinHandler: Void->Void) {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .Default) { [weak self] action in
            self?.startAdvertisingAssisstant()
            hostingHandler()
        })
        ac.addAction(UIAlertAction(title: "Join a session", style: .Default) { [weak self] action in
            self?.startAdvertisingAssisstant()
            joinHandler()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        topViewController?.presentViewController(ac, animated: true, completion: nil)
    }
    
    // Advertising Assisstant
    private func startAdvertisingAssisstant() {
        NSLog("%@", "start advertisingAssisstant")
        guard let connectionManager = connectionManager else { return }
        connectionManager.startAdvertisingAssisstant()
    }
    
    // Browsing Assisstant
    func browseForPeers(withListener listener: MPCAssisstantListener? = nil) {
        guard let connectionManager = connectionManager else { return }
        let browserVC = connectionManager.browserViewController()
        browserVC.delegate = self
        if let listener = listener { addListener(listener) }
        topViewController?.presentViewController(browserVC, animated: true, completion: nil)
    }
    
    func addListener(listener: MPCAssisstantListener) {
        listeners.append(listener)
        mpcAssisstantObserver.addObserver(listener)
    }
    
    func addListeners(listeners: [MPCAssisstantListener]) {
        listeners.forEach { addListener($0) }
    }

    func removeListeners() {
        listeners = []
        mpcAssisstantObserver.observers = []
    }
    
    func endConnection() {
        connectionManager = nil
    }
}

extension PeerConnectionController : MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        NSLog("%@", "browserViewControllerDidFinish")
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
        
        Async.main { self.mpcAssisstantObserver.value = .BrowserDidFinish }
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        NSLog("%@", "browserViewControllerWasCancelled")
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
        
        Async.main { self.mpcAssisstantObserver.value = .BrowserWasCancelled }
    }
}
