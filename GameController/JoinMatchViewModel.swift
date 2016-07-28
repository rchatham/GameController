//
//  JoinMatchViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import PeerConnectivity

struct JoinMatchViewModel {
    
    func getConnectionManager(displayName: String, connectionType: PeerConnectionType = .Automatic, serviceType: ServiceType = "deafult-service") -> PeerConnectionManager {
        var serviceType = serviceType
        if serviceType.isEmpty { serviceType = "deafult-service" }
        let peer = Peer(displayName: displayName)
        let connectionManager = PeerConnectionManager(serviceType: serviceType, connectionType: connectionType, peer: peer)
        return connectionManager
    }
}