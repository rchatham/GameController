//
//  PeerBrowser.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum PeerBrowserEvent {
    case None
    case DidNotStartBrowsingForPeers
    case FoundPeer(Peer)
    case LostPeer
}

class PeerBrowserEventProducer: NSObject {
    
    private let observer : Observable<PeerBrowserEvent>
    
    init(observer: Observable<PeerBrowserEvent>) {
        self.observer = observer
    }
}

extension PeerBrowserEventProducer: MCNearbyServiceBrowserDelegate {

    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
        
        let event : PeerBrowserEvent = .DidNotStartBrowsingForPeers
        Async.main { self.observer.value = event }
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        
        let peer = Peer.NotConnected(peerID)
        let event : PeerBrowserEvent = .FoundPeer(peer)
        Async.main { self.observer.value = event }
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        let event : PeerBrowserEvent = .LostPeer
        Async.main { self.observer.value = event }
    }
}
