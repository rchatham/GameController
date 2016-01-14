//
//  PeerAdvertiser.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct PeerAdvertiser {
    
    private let session : PeerSession
    private let advertiser : MCNearbyServiceAdvertiser
    private let eventProducer : PeerAdvertiserEventProducer
    
    init(session: PeerSession, serviceType: ServiceType, eventProducer: PeerAdvertiserEventProducer) {
        self.session = session
        self.eventProducer = eventProducer
        advertiser = MCNearbyServiceAdvertiser(peer: session.peer.peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = eventProducer
    }
    
    func startAdvertising() {
        advertiser.delegate = eventProducer
        advertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
        advertiser.delegate = nil
    }
    
//    func peerAdvertiserAssistant(serviceType: ServiceType, eventProducer: PeerAdvertiserAssisstantEventProducer? = nil) -> MCAdvertiserAssistant {
//        let assisstant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session.session)
//        if let eventProducer = eventProducer { assisstant.delegate = eventProducer }
//        return assisstant
//    }
    
}