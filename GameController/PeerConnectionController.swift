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
    internal private(set) var connectionManager : PeerConnectionManager? { didSet { NSLog("%@", "connection manager set") } }
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    var serviceType : ServiceType {
        get {
            return connectionManager?.serviceType ?? defaultService
        }
        set(serviceType) {
            guard let peer = peer else { return }
            let service = serviceType.characters.count <= 15 ? serviceType : defaultService
            connectionManager = PeerConnectionManager(
                serviceType: service,
                peer: peer)
        }
    }
    private let defaultService : ServiceType = "default-service"
    
    
    
    var connectionStyle : MPCConnectionStyle = .Assisstant
    
    private var advertiserAssistant : MCAdvertiserAssistant?
    
    
    private let mpcAssisstantObserver = Observable<MPCAssisstantEvent>(.None)
    
    typealias MPCAssisstantListener = MPCAssisstantEvent->Void
    private var listeners : [MPCAssisstantListener] = []

    
    
//    private let mpcBrowserObserver = Observable<MPCBrowserEvent>(.None)
//    
//    typealias MPCBrowserEventListener = MPCBrowserEvent->Void
//    private var browserListeners : [MPCBrowserEventListener] = []
    
    
    
//    private let mpcAdvertiserObserver = Observable<MPCAdvertiserEvent>(.None)
//    
//    typealias MPCAdvertiserEventListener = MPCAdvertiserEvent->Void
//    private var advertiserListeners : [MPCAdvertiserEventListener] = []
    
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
    
    func presentAssisstant() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .Default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .Default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        topViewController?.presentViewController(ac, animated: true, completion: nil)
    }
    func startHosting(action: UIAlertAction!) {
        startAdvertisingAssisstant()
    }
    func joinSession(action: UIAlertAction!) {
        browseForPeers()
    }
    
    func presentAssisstant(hostingHandler: Void->Void, joinHandler: Void->Void) {
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
    
    // Advertising Advertiser
    private func startAdvertisingAssisstant() {
        NSLog("%@", "start advertisingAssisstant")
        guard let connectionManager = connectionManager else { return }
        advertiserAssistant = connectionManager.advertisingAssisstant()
//        advertiserAssistant?.delegate = self
        advertiserAssistant?.start()
    }
    private func stopAdvertisingAssisstant() {
        NSLog("%@", "stop advertisingAssisstant")
        advertiserAssistant?.stop()
        advertiserAssistant?.delegate = nil
        advertiserAssistant = nil
    }
    
    func browseForPeers() {
        guard let connectionManager = connectionManager else { return }
        let browserVC = connectionManager.browserViewController()
        browserVC.delegate = self
        topViewController?.presentViewController(browserVC, animated: true, completion: nil)
    }
    
    func browseForPeersWithListener(listener: MPCAssisstantListener) {
        guard let connectionManager = connectionManager else { return }
        let browserVC = connectionManager.browserViewController()
        addListener(listener)
        browserVC.delegate = self
        topViewController?.presentViewController(browserVC, animated: true, completion: nil)
    }
//    func browseForPeersWithListener(listener: MPCBrowserEventListener) {
//        guard let connectionManager = connectionManager else { return }
//        let browserVC = connectionManager.browserViewController()
//        addListener(listener)
//        browserVC.delegate = self
//        topViewController?.presentViewController(browserVC, animated: true, completion: nil)
//    }
    
    func addListener(listener: MPCAssisstantListener) {
        listeners.append(listener)
        mpcAssisstantObserver.addObserver(listener)
    }
//    func addListener(listener: MPCBrowserEventListener) {
//        browserListeners.append(listener)
//        mpcBrowserObserver.addObserver(listener)
//    }
//    func addListener(listener: MPCAdvertiserEventListener) {
//        advertiserListeners.append(listener)
//        mpcAdvertiserObserver.addObserver(listener)
//    }
    
    func addListeners(listeners: [MPCAssisstantListener]) {
        listeners.forEach { addListener($0) }
    }
//    func addlisteners(listeners: [MPCBrowserEventListener]) {
//        listeners.forEach { addListener($0) }
//    }
//    func addListeners(listeners: [MPCAdvertiserEventListener]) {
//        listeners.forEach { addListener($0) }
//    }

    func removeListeners() {
        listeners = []
        mpcAssisstantObserver.observers = []
        
//        removebrowserListeners()
//        removeAdvertiserListeners()
    }
//    func removebrowserListeners() {
//        browserListeners = []
//        mpcBrowserObserver.observers = nil
//    }
//    func removeAdvertiserListeners() {
//        advertiserListeners = []
//        mpcAdvertiserObserver.observers = nil
//    }
}

enum MPCAssisstantEvent {
    case None
//    case WillPresentInvitation
//    case DidDismissInvitation
    case ShouldPresentNearbyPeer(peer: Peer, withDiscoveryInfo: [String : String]?)
    case BrowserDidFinish
    case BrowserWasCancelled
}
//
//enum MPCAdvertiserEvent {
//    case None
//    case WillPresentInvitation
//    case DidDismissInvitation
//}

//enum MPCBrowserEvent {
//    case None
//    case ShouldPresentNearbyPeer(peer: Peer, withDiscoveryInfo: [String : String]?)
//    case BrowserDidFinish
//    case BrowserWasCancelled
//}

extension PeerConnectionController : MCAdvertiserAssistantDelegate {
    
    func advertiserAssistantWillPresentInvitation(advertiserAssistant: MCAdvertiserAssistant) {
        NSLog("%@", "advertiser will present invitation")
        
    }
    
    func advertiserAssistantDidDismissInvitation(advertiserAssistant: MCAdvertiserAssistant) {
        NSLog("%@", "advertiser did dismiss invitation")
    }
}

extension PeerConnectionController : MCBrowserViewControllerDelegate {
    
//    func browserViewController(browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
//        NSLog("%2", "browserViewController shouldPresentNearbyPeer: \(peerID) withDiscoveryInfo: \(info)")
//        
//        
////        mpcBrowserObserver.value = .ShouldPresentNearbyPeer(peer: <#T##Peer#>, withDiscoveryInfo: <#T##[String : String]?#>)
//        return true
//    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        NSLog("%@", "browserViewControllerDidFinish")
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
//        let event : MPCBrowserEvent = .BrowserDidFinish
//        mpcBrowserObserver.value = .BrowserDidFinish
        mpcAssisstantObserver.value = .BrowserDidFinish
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        NSLog("%@", "browserViewControllerWasCancelled")
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
//        mpcBrowserObserver.value = .BrowserWasCancelled
        mpcAssisstantObserver.value = .BrowserWasCancelled
    }
}
