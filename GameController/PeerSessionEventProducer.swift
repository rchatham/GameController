//
//  PeerSessionEventProducer.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum PeerSessionEvent {
    case None
    case DevicesChanged(peer: Peer)
    case DidReceiveData(peer: Peer, data: NSData)
    case DidReceiveStream(peer: Peer, stream: NSStream, name: String)
    case StartedReceivingResource(peer: Peer, name: String, progress: NSProgress)
    case FinishedReceivingResource(peer: Peer, name: String, url: NSURL, error: NSError?)
    case DidReceiveCertificate(peer: Peer, certificate: [AnyObject]?, handler: (Bool) -> Void)
}

class PeerSessionEventProducer: NSObject {
    
    private let observer : Observable<PeerSessionEvent>
    
    init(observer: Observable<PeerSessionEvent>) {
        self.observer = observer
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

extension PeerSessionEventProducer: MCSessionDelegate {

    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        
        var peer : Peer
        
        switch state {
        case .Connected:
            peer = Peer.Connected(peerID)
        case .Connecting:
            peer = Peer.Connecting(peerID)
        case .NotConnected:
            peer = Peer.Disconnected(peerID)
        }
        
        let event: PeerSessionEvent = .DevicesChanged(peer: peer)
        Async.main { self.observer.value = event }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        
        let peer = Peer.Connected(peerID)
        let event: PeerSessionEvent = .DidReceiveData(peer: peer, data: data)
        Async.main { self.observer.value = event }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
        
        let peer = Peer.Connected(peerID)
        let event: PeerSessionEvent = .DidReceiveStream(peer: peer, stream: stream, name: streamName)
        Async.main { self.observer.value = event }
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        NSLog("%@", "didStartReceivingResourceWithName")
        
        let peer = Peer.Connected(peerID)
        let event: PeerSessionEvent = .StartedReceivingResource(peer: peer, name: resourceName, progress: progress)
        Async.main { self.observer.value = event }
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
        
        let peer = Peer.Connected(peerID)
        let event: PeerSessionEvent = .FinishedReceivingResource(peer: peer, name: resourceName, url: localURL, error: error)
        Async.main { self.observer.value = event }
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        NSLog("%@", "didReceiveCertificate")
        
        certificateHandler(true)
        
        let peer = Peer.Connected(peerID)
        let event: PeerSessionEvent = .DidReceiveCertificate(peer: peer, certificate: certificate, handler: certificateHandler)
        Async.main { self.observer.value = event }
    }
}
