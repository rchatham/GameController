//
//  JoinMatchViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import PeerConnectivity

internal final class JoinMatchViewModel {
    
    func getConnectionManager(displayName: String, connectionType: PeerConnectionType = .automatic, serviceType: ServiceType = "default-service") -> PeerConnectionManager {
        var serviceType = serviceType
        if serviceType.isEmpty { serviceType = "default-service" }
        let connectionManager = PeerConnectionManager(serviceType: serviceType, connectionType: connectionType, displayName: displayName)
        return connectionManager
    }
    
    func connectionTypeForInt(_ int: Int) -> PeerConnectionType {
        switch int {
        case 0: return .automatic
        case 1: return .inviteOnly
        default: fatalError("Switch case not handled!")
        }
    }
}
