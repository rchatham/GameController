//
//  JoinMatchViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import Architecture
import PeerConnectivity

internal final class JoinMatchViewModel: NilStateViewModel {
    let state: State<Void, NoError>? = nil

    typealias Network = NilRouter
    
    func getConnectionManager(displayName: String, connectionType: PeerConnectionType = .automatic, serviceType: ServiceType = "default-service") -> PeerConnectionManager {
        return PeerConnectionService.shared.getConnectionManager(displayName: displayName, connectionType: connectionType, serviceType: serviceType)
    }
    
    func connectionTypeForInt(_ int: Int) -> PeerConnectionType {
        switch int {
        case 0: return .automatic
        case 1: return .inviteOnly
        default: fatalError("Switch case not handled!")
        }
    }
}
