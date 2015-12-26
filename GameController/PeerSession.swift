//
//  PeerSession.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct PeerSession {
    
    let peer : Peer
    let session : MCSession
    private let eventProducer: PeerSessionEventProducer
    
    var connectedPeers : [Peer] {
        return session.connectedPeers.map { Peer.Connected($0) }
    }
    
    init(peer: Peer, eventProducer: PeerSessionEventProducer) {
        self.peer = peer
        self.eventProducer = eventProducer
        session = MCSession(peer: peer.peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Optional)
        session.delegate = eventProducer
    }
    
    func startSession() {
        session.delegate = eventProducer
    }
    
    func stopSession() {
        session.disconnect()
        session.delegate = nil
    }
    
    func sendData(data: NSData) {
        do {
            try session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
        } catch let error {
            NSLog("%@", "Error sending data: \(error)")
        }
    }
    
}