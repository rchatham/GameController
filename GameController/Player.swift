//
//  Player.swift
//  GameController
//
//  Created by Reid Chatham on 11/1/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import PeerConnectivity

struct Player {
    
    let peer : Peer
    var score : Int = 0
    
    var name: String { return peer.displayName }
    
    
    init(playerName: String) {
        self.peer = Peer(displayName: playerName)
    }
    
    init(peer : Peer) {
        self.peer = peer
    }
    
    
    mutating func incrementScoreBy(points: Int) {
        self.score += points
    }
}

extension Player : Equatable {}
func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.peer == rhs.peer
}

extension Player: Hashable {
    var hashValue : Int {
        return peer.hashValue
    }
}