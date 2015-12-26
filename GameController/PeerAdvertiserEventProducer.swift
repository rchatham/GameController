//
//  PeerAdvertiser.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum PeerAdvertiserEvent {
    case None
    case DidNotStartAdvertisingPeer
    case DidReceiveInvitationFromPeer(peer: Peer, withContext: NSData?, invitationHandler: (Bool, MCSession) -> Void)
}

class PeerAdvertiserEventProducer: NSObject {
    
    private let observer : Observable<PeerAdvertiserEvent>
    
    init(observer: Observable<PeerAdvertiserEvent>) {
        self.observer = observer
    }
}

extension PeerAdvertiserEventProducer: MCNearbyServiceAdvertiserDelegate {

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
        
        let event: PeerAdvertiserEvent = .DidNotStartAdvertisingPeer
        Async.main { self.observer.value = event }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        let peer = Peer.NotConnected(peerID)
        let event: PeerAdvertiserEvent = .DidReceiveInvitationFromPeer(peer: peer, withContext: context, invitationHandler: invitationHandler)
        Async.main { self.observer.value = event }
    }
}
