//
//  PeerBrowser.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct PeerBrowser {
    
    private let session : PeerSession
    private let browser : MCNearbyServiceBrowser
    private let eventProducer : PeerBrowserEventProducer
    
    init(session: PeerSession, serviceType: ServiceType, eventProducer: PeerBrowserEventProducer) {
        self.session = session
        self.eventProducer = eventProducer
        browser = MCNearbyServiceBrowser(peer: session.peer.peerID, serviceType: serviceType)
        browser.delegate = eventProducer
    }
    
    func invitePeer(peer: Peer) {
        browser.invitePeer(peer.peerID, toSession: session.session, withContext: nil, timeout: 30)
    }
    
    func startBrowsing() {
        browser.delegate = eventProducer
        browser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser.stopBrowsingForPeers()
        browser.delegate = nil
    }
    
}