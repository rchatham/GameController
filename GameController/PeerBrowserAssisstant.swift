//
//  PeerBrowserViewController.swift
//  GameController
//
//  Created by Reid Chatham on 12/24/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct PeerBrowserAssisstant {
    
    private let session : PeerSession
    private let browserViewController : MCBrowserViewController
    private let eventProducer: PeerBrowserViewControllerEventProducer
    
    init(session: PeerSession, serviceType: ServiceType, eventProducer: PeerBrowserViewControllerEventProducer) {
        self.session = session
        self.eventProducer = eventProducer
        browserViewController = MCBrowserViewController(serviceType: serviceType, session: session.session)
        browserViewController.delegate = eventProducer
    }
    
    func peerBrowserViewController() -> MCBrowserViewController {
        return browserViewController
    }
    
    func startBrowsingAssisstant() {
        browserViewController.delegate = eventProducer
    }
    
    func stopBrowsingAssistant() {
        browserViewController.delegate = nil
    }
}