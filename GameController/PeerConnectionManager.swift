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

enum MPCEvent {
    case Ready
    case Started
    case DevicesChanged(peer: Peer, displayNames: [String])
    case RecievedData(peer: Peer, data: NSData)
    case RecievedStream(peer: Peer, stream: NSStream, name: String)
    case StartedRecievingResource(peer: Peer, name: String, progress: NSProgress)
    case FinishedRecievingResource(peer: Peer, name: String, url: NSURL, error: NSError?)
    case RecievedCertificate(peer: Peer, certificate: [AnyObject]?, handler: (Bool) -> Void)
    case Error(MPCError)
    case Ended
}

protocol MPCSerializable {
    var mpcSerialized: NSData { get }
    init(mpcSerialized: NSData)
}

class PeerConnectionManager : NSObject {
    
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
    
//    private let peerID : MCPeerID
    private let session : MCSession
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let advertiserAssistant : MCAdvertiserAssistant
    private let serviceBrowser : MCNearbyServiceBrowser
    
    
    init(serviceType: String, peer: Peer, eventListener listener: (MPCEvent->Void)? = nil) {
        
        self.peer = peer
//        peerID = self.peer.peerID
        session = MCSession(
            peer: self.peer.peerID,
            securityIdentity: nil,
            encryptionPreference: MCEncryptionPreference.Required)
        serviceAdvertiser = MCNearbyServiceAdvertiser(
            peer: self.peer.peerID,
            discoveryInfo: nil,
            serviceType: serviceType)
        advertiserAssistant = MCAdvertiserAssistant(
            serviceType: serviceType,
            discoveryInfo: nil,
            session: session)
        serviceBrowser = MCNearbyServiceBrowser(
            peer: self.peer.peerID,
            serviceType: serviceType)
        
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
    }
    
    func startWithListener(listener: Listener) {
        startSession()
        startAdvertisingPeer()
        startBrowsingForPeers()
        addListener(listener)
        mpcEventObserver.value = .Started
    }
    
    func startWithListeners(listeners: [Listener]) {
        startSession()
        startAdvertisingPeer()
        startBrowsingForPeers()
        addListeners(listeners)
        mpcEventObserver.value = .Started
    }
    
    func stop() {
        stopSession()
        stopAdvertisingPeer()
        stopBrowsingForPeers()
        mpcEventObserver.value = .Ended
        removeListeners()
    }
    
    // Listeners
    func addListener(listener: Listener) -> PeerConnectionManager {
        listeners.append(listener)
        mpcEventObserver.addObserver(listener)
        return self
    }
    
    func addListeners(listeners: [Listener]) -> PeerConnectionManager {
        listeners.forEach { addListener($0) }
        return self
    }
    
    func removeListeners() {
        listeners = []
        mpcEventObserver.observers = nil
    }
    
    // Session
    private func startSession() {
        NSLog("%@", "start session")
        session.delegate = self
    }
    private func stopSession() {
        NSLog("%@", "stop session")
        session.disconnect()
        session.delegate = nil
    }
    
    func sendEvent(event: String, object: AnyObject? = nil, toPeers peers: [MCPeerID]?) {
        let peers = (peers ?? session.connectedPeers)
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
        NSLog("%@", "start browsing for peers")
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    private func stopBrowsingForPeers() {
        NSLog("%@", "stop browsing for peers")
        serviceBrowser.stopBrowsingForPeers()
        serviceBrowser.delegate = nil
    }
    
    // Browser Assisstant
    func browserViewController() -> MCBrowserViewController {
//        stopBrowsingForPeers()
        return MCBrowserViewController(browser: serviceBrowser, session: session)
    }
    
    // Advestising
    private func startAdvertisingPeer() {
        NSLog("%@", "start advertising peer")
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    private func stopAdvertisingPeer() {
        NSLog("%@", "stop advertising peer")
        serviceAdvertiser.stopAdvertisingPeer()
        serviceAdvertiser.delegate = nil
    }
    
    // Advertising Assisstant
    private func startAdvertisingAssisstant() {
        NSLog("%@", "start advertising assisstant")
        advertiserAssistant.start()
    }
    private func stopAdvertisingAssisstant() {
        NSLog("%@", "stop advertising assisstant")
        advertiserAssistant.stop()
    }
    
}

// Listener extension
extension PeerConnectionManager {
    
    typealias ReadyListener = Void->Void
    typealias StartListener = Void->Void
    typealias SessionEndedListener = Void->Void
    
    typealias DevicesChangedListener = (peer: Peer, displayNames: [String])->Void
    typealias DataListener = (peer: Peer, data: NSData)->Void
    typealias StreamListener = (peer: Peer, stream: NSStream, name: String)->Void
    typealias StartedRecievingResourceListener = (peer: Peer, name: String, progress: NSProgress)->Void
    typealias FinishedRecievingResourceListener = (peer: Peer, name: String, url: NSURL, error: NSError?)->Void
    typealias CertificateRecievedListener = (peer: Peer, certificate: [AnyObject]?, handler: (Bool) -> Void)->Void
    
    typealias ErrorListener = (error: MPCError)->Void
    
    
    func listenOn(ready ready: ReadyListener? = nil,
        started: StartListener? = nil,
        devicesChanged: DevicesChangedListener? = nil,
        dataRecieved: DataListener? = nil,
        streamRecieved: StreamListener? = nil,
        recievingResourceStarted: StartedRecievingResourceListener? = nil,
        recievingResourceFinished: FinishedRecievingResourceListener? = nil,
        certificateRecieved: CertificateRecievedListener? = nil,
        ended: SessionEndedListener? = nil,
        error: ErrorListener? = nil) -> PeerConnectionManager {
        
        addListener { event in
            switch event {
                
            case .Ready: ready?()
            case .Started: started?()
                
            case .DevicesChanged(peer: let peer, displayNames: let names):
                devicesChanged?(peer: peer, displayNames: names)
                
            case .RecievedData(peer: let peer, data: let data):
                dataRecieved?(peer: peer, data: data)
                
            case .RecievedStream(peer: let peer, stream: let stream, name: let name):
                streamRecieved?(peer: peer, stream: stream, name: name)
                
            case .StartedRecievingResource(peer: let peer, name: let name, progress: let progress):
                recievingResourceStarted?(peer: peer, name: name, progress: progress)
                
            case .FinishedRecievingResource(peer: let peer, name: let name, url: let url, error: let error):
                recievingResourceFinished?(peer: peer, name: name, url: url, error: error)
                
            case .RecievedCertificate(peer: let peer, certificate: let certificate, handler: let handler):
                certificateRecieved?(peer: peer, certificate: certificate, handler: handler)
                
            case .Ended: ended?()
            case .Error(let e): error?(error: e)
            }
        }
        return self
    }
    
}

extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
            //        default: return "Unknown"
        }
    }
}

extension PeerConnectionManager : MCSessionDelegate {
    
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
            peer = Peer.Disconnected(peerID)
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
        
//        let trust = self.session.myPeerID.hashValue < peerID.hashValue
//        certificateHandler(trust)
        
        let peer = peerForPeerID(peerID)
        let event = MPCEvent.RecievedCertificate(peer: peer, certificate: certificate, handler: certificateHandler)
        Async.main { self.mpcEventObserver.value = event }
    }
    
    private func peerForPeerID(peerID: MCPeerID) -> Peer {
        switch connectedPeers.map({ $0.peerID }).indexOf(peerID) {
        case .None: return Peer.Connected(peerID)
        case .Some(let index): return connectedPeers[index]
        }
    }
}

extension PeerConnectionManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
        
        let error = MPCError.DidNotStartAdvertisingPeer(error)
        Async.main { self.mpcEventObserver.value = .Error(error) }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        invitationHandler(true, self.session)
        
//        let accept = self.session.myPeerID.hashValue > peerID.hashValue
//        invitationHandler(accept, self.session)
//        if accept {
//            stopAdvertisingPeer()
//        }
    }
}

extension PeerConnectionManager : MCNearbyServiceBrowserDelegate {
    
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

extension PeerConnectionManager : MCAdvertiserAssistantDelegate {
    
    func advertiserAssistantWillPresentInvitation(advertiserAssistant: MCAdvertiserAssistant) {
        NSLog("%@", "advertiser will present invitation")
        
    }
    
    func advertiserAssistantDidDismissInvitation(advertiserAssistant: MCAdvertiserAssistant) {
        NSLog("%@", "advertiser did dismiss invitation")
    }
}
