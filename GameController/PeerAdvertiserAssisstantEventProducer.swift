//
//  PeerAdvertiserAssisstant.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum PeerAdvertiserAssisstantEvent {
    case None
    case DidDissmissInvitation
    case WillPresentInvitation
}

class PeerAdvertiserAssisstantEventProducer: NSObject {
    
    private let observer : Observable<PeerAdvertiserAssisstantEvent>
    
    init(observer: Observable<PeerAdvertiserAssisstantEvent>) {
        self.observer = observer
    }
}

extension PeerAdvertiserAssisstantEventProducer: MCAdvertiserAssistantDelegate {

    func advertiserAssistantDidDismissInvitation(advertiserAssistant: MCAdvertiserAssistant) {
        
        let event: PeerAdvertiserAssisstantEvent = .DidDissmissInvitation
        Async.main { self.observer.value = event }
    }
    
    func advertiserAssistantWillPresentInvitation(advertiserAssistant: MCAdvertiserAssistant) {
        
        let event: PeerAdvertiserAssisstantEvent = .WillPresentInvitation
        Async.main { self.observer.value = event }
    }
}
