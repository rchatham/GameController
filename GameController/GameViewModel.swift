//
//  Game2ViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import PeerConnectivity

internal final class GameViewModel {
    
    var gameStartCallback : [MiniGame]->Void = {_ in}
    var labelCallback : (String->Void)? {
        didSet {
            guard let labelCallback = labelCallback else { return }
            connectionManager.listenOn(devicesChanged: { _, peers in
                let output = self.outputStringForArray()
                labelCallback(output)
            }, withKey: "LabelCallback")
        }
    }
    
    private(set) var player : Player {
        didSet {
            let scoreObject : [String:AnyObject] = ["score":player.score]
            connectionManager.sendEvent(scoreObject)
        }
    }
    private(set) var connectedPlayers : [Player] = []
    private let connectionManager : PeerConnectionManager
    
    init(connectionManager: PeerConnectionManager) {
        self.player = Player(peer: connectionManager.peer)
        self.connectionManager = connectionManager
        
        self.connectionManager
            .listenOn(devicesChanged: { [weak self] (peer: Peer, displayNames: [Peer]) -> Void in
                switch peer.status {
                case .Connected(_):
                    guard let players = self?.connectedPlayers
                        where !players.contains(Player(peer: peer))
                        else { return }
                    self?.connectedPlayers += [Player(peer: peer)]
                case .NotConnected(_):
                    guard let index = self?.connectedPlayers.indexOf(Player(peer: peer)) else { return }
                    self?.connectedPlayers.removeAtIndex(index)
                default: break
                }
            
            }, dataReceived: { [weak self] (peer: Peer, data: NSData) -> Void in
                
                guard let dataObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:AnyObject]
                    else { return }
                
                if let gamesNames = dataObject["start"] as? [String] {
                    
                    var games: [MiniGame] = []
                    
                    for gameName in gamesNames {
                        switch gameName {
                        case "CoverTheDot":
                            games.append(CoverTheDot())
                        case "TapTheDot":
                            games.append(TapTheDot())
                        case "FlappyBird":
                            games.append(FlappyBird())
                        default: break
                        }
                    }
                    self?.gameStartCallback(games)
                }
                else if let score = dataObject["score"] as? Int {
                    self?.connectedPlayers = self!.connectedPlayers.map { (player) in
                        if player.peer == peer {
                            return Player(peer: peer, score: score)
                        } else {
                            return player
                        }
                    }
                    self?.labelCallback?(self!.outputStringForArray())
                
                }
            }, withKey: "GameSetup")
    }
    
    func sendStartGameData() -> [MiniGame] {
        
        var gamesArray: [MiniGame] = [
            CoverTheDot(),
            TapTheDot(),
            FlappyBird(),
            UnrollTheToiletPaper()
        ]
        
        gamesArray.shuffleInPlace()
        
        var gamesNames : [String] = []
        
        for game in gamesArray {
            switch game {
            case _ where (game as? CoverTheDot) != nil:
                gamesNames.append(String(CoverTheDot))
            case _ where (game as? TapTheDot) != nil:
                gamesNames.append(String(TapTheDot))
            case _ where (game as? FlappyBird) != nil:
                gamesNames.append(String(FlappyBird))
            case _ where (game as? UnrollTheToiletPaper) != nil:
                gamesNames.append(String(UnrollTheToiletPaper))
            default: break
            }
        }
        
        let startObject : [String:AnyObject] = ["start":gamesNames]
        connectionManager.sendEvent(startObject)
        
        return gamesArray
    }
    
    func incrementScoreBy(points: Int) {
        player.incrementScoreBy(points)
    }
    
    func endConnection() {
        connectionManager.stop()
    }
    
    func outputStringForArray() -> String {
        
        let output = "Connected gremlins:\n"
            + (connectedPlayers.map { "Player: \($0.name), Score: \($0.score)\n" }.reduce("",combine: +))
            + "My score: \(player.score)"
        
        return output
    }
}
