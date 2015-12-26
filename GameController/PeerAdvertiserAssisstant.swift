//
//  PeerAdvertiserAssisstant.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct PeerAdvertiserAssisstant {
    
    private let session : PeerSession
    private let assisstant : MCAdvertiserAssistant
    private let eventProducer : PeerAdvertiserAssisstantEventProducer?
    
    init(session: PeerSession, serviceType: ServiceType, eventProducer: PeerAdvertiserAssisstantEventProducer? = nil) {
        self.session = session
        self.eventProducer = eventProducer
        assisstant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session.session)
        if let eventProducer = eventProducer { assisstant.delegate = eventProducer }
    }
    
    func startAdvertisingAssisstant() {
        if let eventProducer = eventProducer { assisstant.delegate = eventProducer }
        assisstant.start()
    }
    
    func stopAdvertisingAssisstant() {
        assisstant.stop()
        assisstant.delegate = nil
    }
}