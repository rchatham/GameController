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
    
    func getConnectionManager(displayName displayName: String, connectionType: PeerConnectionType = .Automatic, serviceType: ServiceType = "default-service") -> PeerConnectionManager {
        var serviceType = serviceType
        if serviceType.isEmpty { serviceType = "default-service" }
        let connectionManager = PeerConnectionManager(serviceType: serviceType, connectionType: connectionType, displayName: displayName)
        return connectionManager
    }
    
    func connectionTypeForInt(int: Int) -> PeerConnectionType {
        switch int {
        case 0: return .Automatic
        case 1: return .InviteOnly
        default: fatalError("Switch case not handled!")
        }
    }
}