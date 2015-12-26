//
//  JoinMatchViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation

struct JoinMatchViewModel {
    
    func gameViewModel(player: Player, connectionManager: PeerConnectionManager) -> Game2ViewModel {
        return Game2ViewModel(player: player, connectionManager: connectionManager)
    }
    
    func gameInfo(displayName: String, connectionType: PeerConnectionType = .Automatic, var serviceType: ServiceType = "deafult-service") -> (Player, PeerConnectionManager) {
        if serviceType.isEmpty { serviceType = "deafult-service" }
        let peer = Peer(displayName: displayName)
        let player = Player(peer: peer)
        return (player, self.connectionManager(connectionType, serviceType: serviceType, peer: peer))
    }
    
    func connectionManager(connectionType: PeerConnectionType, serviceType: ServiceType, peer: Peer) -> PeerConnectionManager {
        return PeerConnectionManager(connectionType: connectionType, serviceType: serviceType, peer: peer)
    }
    
    func player(peer: Peer) -> Player {
        return Player(peer: peer)
    }
    
    func peer(displayName: String) -> Peer {
        return Peer(displayName: displayName)
    }
}