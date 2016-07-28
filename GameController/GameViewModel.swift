//
//  Game2ViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import PeerConnectivity

class GameViewModel {
    
    var player : Player {
        didSet {
            let scoreObject : [String:AnyObject] = ["score":player.score]
            connectionManager.sendEvent(scoreObject)
        }
    }
    var connectedPlayers : [Player] = []
    
    private var connectionManager : PeerConnectionManager
    
    
    var labelCallback : (String->Void)? {
        didSet {
            guard let labelCallback = labelCallback else { return }
            connectionManager.listenOn(devicesChanged: { _, peers in
                let output = self.outputStringForArray(prefix: "Connected gremlins:",
                    array: peers.map{ $0.displayName },
                postfix: "My score: \(self.player.score)")
                labelCallback(output)
            }, withKey: "LabelCallback")
        }
    }
    
    var gameStartCallback : [MiniGame]->Void = {_ in}
    
    init(player: Player, connectionManager: PeerConnectionManager) {
        self.player = player
        self.connectionManager = connectionManager
        
        self.connectionManager
            .listenOn(devicesChanged: { [weak self] (peer: Peer, displayNames: [Peer]) -> Void in
                switch peer {
                case .Connected(_):
                    self?.connectedPlayers += [Player(peer: peer)]
                case .NotConnected(_):
                    guard let index = self?.connectedPlayers.indexOf(Player(peer: peer)) else { return }
                    self?.connectedPlayers.removeAtIndex(index)
                default: break
                }
            
            }, dataReceived: { [weak self] (peer: Peer, data: NSData) -> Void in
                
                guard let dataObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:AnyObject]
                    else { return }
                
                if let score = dataObject["score"] as? Int {
                    self?.connectedPlayers = self!.connectedPlayers.map { (player) in
                        if player.peer == peer {
                            var player = Player(peer: peer)
                            player.score = score
                            return player
                        } else {
                            return player
                        }
                    }
                    self?.labelCallback?(self!.initialOutput())
                
                }
                if let gamesNames = dataObject["start"] as? [String] {
                    
                    var games: [MiniGame] = []
                    
                    for gameName in gamesNames {
                        switch gameName {
                        case "CoverTheDot":
                            games.append(CoverTheDot(gameRound: GameRound()))
                        case "TapTheDot":
                            games.append(TapTheDot(gameRound: GameRound()))
                        case "FlappyBird":
                            games.append(FlappyBird(gameRound: GameRound()))
                        default: break
                        }
                    }
                    self?.gameStartCallback(games)
                }
            }, withKey: "GameSetup")
    }
    
    func sendStartGameData() -> [MiniGame] {
        
        var gamesArray: [MiniGame] = [
            CoverTheDot(gameRound: GameRound()),
            TapTheDot(gameRound: GameRound()),
            FlappyBird(gameRound: GameRound()),
            UnrollTheToiletPaper(gameRound: GameRound())
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
    
    
    func endConnection() {
        connectionManager.stop()
    }
    
    func initialOutput() -> String {
        return outputStringForArray(prefix: "Connected gremlins:",
            array: connectionManager.displayNames,
            postfix: "My score: \(player.score)")
    }
    
    private func outputStringForArray(
        prefix prefix: String? = nil,
        array: [String],
        postfix: String? = nil) -> String {
            
        var output = ""
        switch prefix {
        case .None: break
        case.Some(let p): output += (p + "\n")
        }
        for player in connectedPlayers {
            output += "Player: \(player.name), Score: \(player.score)\n"
        }
        switch postfix {
        case .None: break
        case .Some(let p): output += p
        }
            
        return output
    }
}

enum PlayerChange {
    case Connected(player: Player)
    case NotConnected(player: Player)
    case Scored(player: Player)
}
