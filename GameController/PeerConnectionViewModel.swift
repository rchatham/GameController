//
//  PlayerConnectionManager.swift
//  GameController
//
//  Created by Reid Chatham on 10/30/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum MPCError : ErrorType {
    case Error(NSError)
    case DidNotStartAdvertisingPeer(NSError)
    case DidNotStartBrowsingForPeers(NSError)
}

// Event representations of all of the possible delegate calls for MCSession, MCNearbyServiceBrowser, and MCNearbyServiceAdvertiser
enum MPCEvent {
    case Ready
    case Started
    case DevicesChanged(peer: Peer, displayNames: [String])
    case RecievedData(peer: Peer, data: NSData)
    case RecievedStream(peer: Peer, stream: NSStream, name: String)
    case StartedRecievingResource(peer: Peer, name: String, progress: NSProgress)
    case FinishedRecievingResource(peer: Peer, name: String, url: NSURL, error: NSError?)
//    case RecievedCertificate(peer: Peer, certificate: [AnyObject]?, handler: (Bool) -> Void)
    case Error(MPCError)
    case Ended
}

// Will be used for making data serializable for transfer
protocol MPCSerializable {
    var mpcSerialized: NSData { get }
    init(mpcSerialized: NSData)
}

class PeerConnectionViewModel : NSObject {
    
    private let peer : Peer
    internal private(set) var connectedPeers: [Peer] = []
    
    var displayNames : [String] {
        return connectedPeers.map { $0.displayName }
    }
    
    var sessionDisplayNames : [String] {
        return session.connectedPeers.map { $0.displayName }
    }
    
    private let mpcEventObserver : Observable<MPCEvent>
    
    typealias Listener = MPCEvent->Void
    private var listeners : [Listener] = []
    
    
    let serviceType : String
    
    private let session : MCSession
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    private var advertiserAssistant : MCAdvertiserAssistant
    
    private var isStarted = false
    
    
    init(serviceType: String, peer: Peer, eventListener listener: (MPCEvent->Void)? = nil) {
        
        self.serviceType = serviceType
        
        self.peer = peer
        session = MCSession(
            peer: self.peer.peerID,
            securityIdentity: nil,
            encryptionPreference: MCEncryptionPreference.Required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(
            peer: self.peer.peerID,
            discoveryInfo: nil,
            serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(
            peer: self.peer.peerID,
            serviceType: serviceType)
        advertiserAssistant = MCAdvertiserAssistant(
            serviceType: serviceType,
            discoveryInfo: nil,
            session: session)
        
        mpcEventObserver = Observable(.Ready)
        
        super.init()
        
        guard let listener = listener else { return }
        addListener(listener)
        start()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        startSession()
        startAdvertisingPeer()
        startBrowsingForPeers()
        mpcEventObserver.value = .Started
        isStarted = true
    }
    
    func startWithListener(listener: Listener) {
        startSession()
        startAdvertisingPeer()
        startBrowsingForPeers()
        addListener(listener)
        mpcEventObserver.value = .Started
        isStarted = true
    }
    
    func startWithListeners(listeners: [Listener]) {
        startSession()
        startAdvertisingPeer()
        startBrowsingForPeers()
        addListeners(listeners)
        mpcEventObserver.value = .Started
        isStarted = true
    }
    
    func stop() {
        stopSession()
        stopAdvertisingPeer()
        stopBrowsingForPeers()
        stopAdvertisingAssisstant()
        mpcEventObserver.value = .Ended
        removeListeners()
    }
    
    // Listeners
    func addListener(listener: Listener) -> PeerConnectionViewModel {
        listeners.append(listener)
        mpcEventObserver.addObserver(listener)
        return self
    }
    
    func addListeners(listeners: [Listener]) -> PeerConnectionViewModel {
        listeners.forEach { addListener($0) }
        return self
    }
    
    func removeListeners() {
        listeners = []
        mpcEventObserver.observers = []
    }
    
    // Session
    private func startSession() {
        NSLog("%@", "startSession")
        session.delegate = self
    }
    private func stopSession() {
        NSLog("%@", "stopSession")
        session.disconnect()
        session.delegate = nil
    }
    
//    func sendEvent() {
//        
//        
//        let
//        
//        do {
//            try session.sendData(data, toPeers: peers, withMode: .Reliable)
//        } catch let error {
//            NSLog("%@", "Error sending data: \(error)")
//        }
//    }
    
    func sendEvent(event: String, object: AnyObject? = nil, toPeers peers: [Peer]?) {
        let peers = (peers != nil) ? (peers!.map { $0.peerID }) : session.connectedPeers
        guard !peers.isEmpty else { return }
        var rootObject: [String: AnyObject] = ["event": event]
        
        if let object = object {
            rootObject["object"] = object
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(rootObject)
        
        do {
            try session.sendData(data, toPeers: peers, withMode: .Reliable)
        } catch let error {
            NSLog("%@", "Error sending data: \(error)")
        }
    }
    
    func sendResourceAtURL(resourceURL: NSURL, withName resourceName: String, toPeers peers: [Peer]?, withCompletionHandler completionHandler: ((NSError?) -> Void)?) -> [NSProgress?]? {
            
        return (peers?.map { $0.peerID } ?? session.connectedPeers) .map { peerID in
            return session.sendResourceAtURL(resourceURL, withName: resourceName, toPeer: peerID, withCompletionHandler: completionHandler)
        }
    }
    
    func startStreamWithName(streamName: String, toPeer peer: Peer) {
        
        do {
            try session.startStreamWithName(streamName, toPeer: peer.peerID)
        } catch let error {
            NSLog("%@", "Error starting stream with data: \(error)")
        }
    }
    
    // Browsing
    private func startBrowsingForPeers() {
        NSLog("%@", "startBrowsingForPeers")
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    private func stopBrowsingForPeers() {
        NSLog("%@", "stopBrowsingForPeers")
        serviceBrowser.stopBrowsingForPeers()
        serviceBrowser.delegate = nil
    }
    
    // Browser Assisstant
    func browserViewController() -> MCBrowserViewController {
        return MCBrowserViewController(
            browser: serviceBrowser,
            session: session)
    }
    
    // Advestising
    private func startAdvertisingPeer() {
        NSLog("%@", "startAdvertisingPeer")
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    private func stopAdvertisingPeer() {
        NSLog("%@", "stopAdvertisingPeer")
        serviceAdvertiser.stopAdvertisingPeer()
        serviceAdvertiser.delegate = nil
    }
    
    // Advertising Assisstant
    func startAdvertisingAssisstant() {
        NSLog("%@", "startAdvertisingAssisstant")
        session.delegate = self
        advertiserAssistant.start()
    }
    private func stopAdvertisingAssisstant() {
        NSLog("%@", "stopAdvertisingAssisstant")
        advertiserAssistant.stop()
        advertiserAssistant.delegate = nil
    }
    
}

// Listener extension
extension PeerConnectionViewModel {
    
    typealias ReadyListener = Void->Void
    typealias StartListener = Void->Void
    typealias SessionEndedListener = Void->Void
    
    typealias DevicesChangedListener = (peer: Peer, displayNames: [String])->Void
    typealias DataListener = (peer: Peer, data: NSData)->Void
    typealias StreamListener = (peer: Peer, stream: NSStream, name: String)->Void
    typealias StartedRecievingResourceListener = (peer: Peer, name: String, progress: NSProgress)->Void
    typealias FinishedRecievingResourceListener = (peer: Peer, name: String, url: NSURL, error: NSError?)->Void
//    typealias CertificateRecievedListener = (peer: Peer, certificate: [AnyObject]?, handler: (Bool) -> Void)->Void
    
    typealias ErrorListener = (error: MPCError)->Void
    
    func listenOn(ready ready: ReadyListener = { _ in },
        started: StartListener = { _ in },
        devicesChanged: DevicesChangedListener = { _ in },
        dataRecieved: DataListener = { _ in },
        streamRecieved: StreamListener = { _ in },
        recievingResourceStarted: StartedRecievingResourceListener = { _ in },
        recievingResourceFinished: FinishedRecievingResourceListener = { _ in },
//        certificateRecieved: CertificateRecievedListener = { _ in },
        ended: SessionEndedListener = { _ in },
        error: ErrorListener = { _ in }
        ) -> PeerConnectionViewModel {
        
        addListener { event in
            switch event {
                
            case .Ready: ready()
            case .Started: started()
                
            case .DevicesChanged(peer: let peer, displayNames: let names):
                devicesChanged(peer: peer, displayNames: names)
                
            case .RecievedData(peer: let peer, data: let data):
                dataRecieved(peer: peer, data: data)
                
            case .RecievedStream(peer: let peer, stream: let stream, name: let name):
                streamRecieved(peer: peer, stream: stream, name: name)
                
            case .StartedRecievingResource(peer: let peer, name: let name, progress: let progress):
                recievingResourceStarted(peer: peer, name: name, progress: progress)
                
            case .FinishedRecievingResource(peer: let peer, name: let name, url: let url, error: let error):
                recievingResourceFinished(peer: peer, name: name, url: url, error: error)
                
//            case .RecievedCertificate(peer: let peer, certificate: let certificate, handler: let handler):
//                certificateRecieved(peer: peer, certificate: certificate, handler: handler)
                
            case .Ended: ended()
            case .Error(let e): error(error: e)
                
//            default: break
            }
        }
        return self
    }
    
}
//
//extension MCSessionState {
//    func stringValue() -> String {
//        switch(self) {
//        case .NotConnected: return "NotConnected"
//        case .Connecting: return "Connecting"
//        case .Connected: return "Connected"
//            //        default: return "Unknown"
//        }
//    }
//}

extension PeerConnectionViewModel : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        
        var peer : Peer
        
        switch state {
        case .Connecting:
            peer = Peer.Connecting(peerID)
        case .Connected:
            peer = Peer.Connected(peerID)
            switch connectedPeers.map({ $0.peerID }).indexOf(peerID) {
            case .Some(let index): connectedPeers[index] = peer
            case .None: connectedPeers.append(peer)
            }
        case .NotConnected:
            peer = Peer.NotConnected(peerID)
            connectedPeers = connectedPeers.filter { $0.peerID != peerID }
        }
        
        assert(Set(displayNames) == Set(sessionDisplayNames) && displayNames.count == sessionDisplayNames.count)
        
        let event = MPCEvent.DevicesChanged(peer: peer, displayNames: displayNames)
        Async.main { self.mpcEventObserver.value = event }
        
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        
        let peer = peerForPeerID(peerID)
        let event = MPCEvent.RecievedData(peer: peer, data: data)
        Async.main { self.mpcEventObserver.value = event }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
        
        let peer = peerForPeerID(peerID)
        let event = MPCEvent.RecievedStream(peer: peer, stream: stream, name: streamName)
        Async.main { self.mpcEventObserver.value = event }
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
        
        let peer = peerForPeerID(peerID)
        let event = MPCEvent.StartedRecievingResource(peer: peer, name: resourceName, progress: progress)
        Async.main { self.mpcEventObserver.value = event }
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
        
        let peer = peerForPeerID(peerID)
        let event = MPCEvent.FinishedRecievingResource(peer: peer, name: resourceName, url: localURL, error: error)
        Async.main { self.mpcEventObserver.value = event }
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        NSLog("%@", "didReceiveCertificate")
        
        certificateHandler(true)
        
//        let peer = peerForPeerID(peerID)
//        let event = MPCEvent.RecievedCertificate(peer: peer, certificate: certificate, handler: certificateHandler)
//        Async.main { self.mpcEventObserver.value = event }
    }
    
    private func peerForPeerID(peerID: MCPeerID) -> Peer {
        switch connectedPeers.map({ $0.peerID }).indexOf(peerID) {
        case .None: return Peer.Connected(peerID)
        case .Some(let index): return connectedPeers[index]
        }
    }
}

extension PeerConnectionViewModel : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
        
        let error = MPCError.DidNotStartAdvertisingPeer(error)
        Async.main { self.mpcEventObserver.value = .Error(error) }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        invitationHandler(true, self.session)
        
        let accept = self.session.myPeerID.hashValue > peerID.hashValue
        invitationHandler(accept, self.session)
        if accept {
            stopAdvertisingPeer()
        }
    }
}

extension PeerConnectionViewModel : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
        
        let error = MPCError.DidNotStartBrowsingForPeers(error)
        Async.main { self.mpcEventObserver.value = .Error(error) }
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 30)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}
