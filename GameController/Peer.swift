//
//  Peer.swift
//  GameController
//
//  Created by Reid Chatham on 12/19/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum Peer {
    case CurrentUser(MCPeerID)
    case Connected(MCPeerID)
    case Connecting(MCPeerID)
    case Disconnected(MCPeerID)
    
    var peerID : MCPeerID {
        switch self {
        case .CurrentUser(let pid): return pid
        case .Connected(let pid): return pid
        case .Connecting(let pid): return pid
        case .Disconnected(let pid): return pid
        }
    }
    
    var displayName : String {
        return peerID.displayName
    }
    
    // displayName Must not be longer than 63 bytes in UTF8 Encoding according to the Apple documentation 
    // ( xcdoc://?url=developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MCPeerID_class/index.html#//apple_ref/swift/cl/c:objc(cs)MCPeerID )
    init(displayName: String) {
        let peerID = MCPeerID(displayName: displayName)
        self = .CurrentUser(peerID)
    }
}

extension Peer : Equatable {}
func ==(lhs: Peer, rhs: Peer) -> Bool {
    switch (lhs, rhs) {
    case (.CurrentUser(let pid1), .CurrentUser(let pid2)):
        return pid1 == pid2
    case (let lhs, let rhs):
        return lhs.peerID == rhs.peerID
    default: break
    }
}
//func ==(lhs: Peer, rhs: Peer) -> Bool {
//    switch (lhs, rhs) {
//    case (.CurrentUser(let pid1), .CurrentUser(let pid2)):
//        return pid1 == pid2
//    case (.Connected(let pid1), .Connected(let pid2)):
//        return pid1 == pid2
//    case (.Connecting(let pid1), .Connecting(let pid2)):
//        return pid1 == pid2
//    case (.Disconnected(let pid1), .Disconnected(let pid2)):
//        return pid1 == pid2
//    default: return false
//    }
//}

extension Peer : Hashable {
    var hashValue : Int {
        return peerID.hashValue
    }
}