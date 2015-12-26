//
//  Game2ViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation

struct Game2ViewModel {
    
    private let player : Player
    private var connectionManager : PeerConnectionManager
    
    var labelCallback : (String->Void)? {
        didSet {
            guard let labelCallback = labelCallback else { return }
            connectionManager.listenOn(devicesChanged: { _, displayNames in
                let output = self.outputStringForArray(prefix: "Connected gremlins:", array: displayNames)
                labelCallback(output)
            })
        }
    }
    
    init(player: Player, connectionManager: PeerConnectionManager) {
        self.player = player
        self.connectionManager = connectionManager
    }
    
    func endConnection() {
        connectionManager.stop()
    }
    
    func initialOutput() -> String {
        return outputStringForArray(prefix: "Connected gremlins:", array: connectionManager.connectedPeers.map { $0.displayName })
    }
    
    private func outputStringForArray(prefix prefix: String? = nil, array: [String], postfix: String? = nil) -> String {
        var output = ""
        switch prefix {
        case .None: break
        case.Some(let p): output += (p + "\n")
        }
        for string in array {
            output += (string + "\n")
        }
        switch postfix {
        case .None: break
        case .Some(let p): output += p
        }
        return output
    }
}