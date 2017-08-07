//
//  PeerConnectionService.swift
//  GameController
//
//  Created by Reid Chatham on 8/2/17.
//  Copyright © 2017 Reid Chatham. All rights reserved.
//

import Foundation
import PluggableApplicationDelegate
import PeerConnectivity

class PeerConnectionService: NSObject, ApplicationService {
    
    static let shared = PeerConnectionService()
    
//    private(set) internal var manager: PeerConnectionManager?
    
    func getConnectionManager(displayName: String, connectionType: PeerConnectionType = .automatic, serviceType: ServiceType = "default-service") -> PeerConnectionManager {
        var serviceType = serviceType
        if serviceType.isEmpty { serviceType = "default-service" }
        let connectionManager = PeerConnectionManager(serviceType: serviceType, connectionType: connectionType, displayName: displayName)
        return connectionManager
    }
}
