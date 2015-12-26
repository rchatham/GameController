//
//  PeerBrowserViewControllerEventProducer.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum PeerBrowserViewControllerEvent {
    //    case ShouldPresentNearbyPeer
    case None
    case DidFinish
    case WasCancelled
}

class PeerBrowserViewControllerEventProducer: NSObject {
    
    private let observer: Observable<PeerBrowserViewControllerEvent>

    init(observer: Observable<PeerBrowserViewControllerEvent>) {
        self.observer = observer
    }
}

extension PeerBrowserViewControllerEventProducer: MCBrowserViewControllerDelegate {

//    func browserViewController(browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
//        return true
//    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        
        let event : PeerBrowserViewControllerEvent = .DidFinish
        Async.main { self.observer.value = event }
        
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        
        let event : PeerBrowserViewControllerEvent = .WasCancelled
        Async.main { self.observer.value = event }
        
        browserViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
