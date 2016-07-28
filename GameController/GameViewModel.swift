//
//  Game2ViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import PeerConnectivity

struct GameViewModel {
    
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
            .listenOn(devicesChanged: { /*[weak self]*/ (peer: Peer, displayNames: [Peer]) -> Void in
                switch peer {
                case .Connected(_):
                    self.connectedPlayers += [Player(peer: peer)]
                case .NotConnected(_):
                    guard let index = self.connectedPlayers.indexOf(Player(peer: peer)) else { return }
                    self.connectedPlayers.removeAtIndex(index)
                default: break
                }
            
            }, dataReceived: { /*[weak self]*/ (peer: Peer, data: NSData) -> Void in
                
                guard let dataObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:AnyObject]
                    else { return }
                
                if let score = dataObject["score"] as? Int {
                    self.connectedPlayers = self.connectedPlayers.map { (player) in
                        if player.peer == peer {
                            var player = Player(peer: peer)
                            player.score = score
                            return player
                        } else {
                            return player
                        }
                    }
                    self.labelCallback?(self.initialOutput())
                
                }
                if let gamesNames = dataObject["start"] as? [String] {
                    
                    var games: [MiniGame] = []
                    
                    for gameName in gamesNames {
                        switch gameName {
                        case "CoverTheDot":
                            let gameRound = GameRound()
                            gameRound.setGameType(.Timed(duration: 15))
                            let ctd = CoverTheDot(gameRound: gameRound)
                            games.append(ctd)
                        case "TapTheDot":
                            let gameRound = GameRound()
                            gameRound.setGameType(.TimedObjective(duration: 15))
                            let ttd = TapTheDot(gameRound: GameRound())
                            games.append(ttd)
                        default: break
                        }
                    }
                    self.gameStartCallback(games)
                }
            }, withKey: "GameSetup")
    }
    
    func sendStartGameData() -> [MiniGame] {
        
        var gamesArray: [MiniGame] = []
        
        let timedRound = GameRound()
        let timedObjectiveRound = GameRound()
        let objectiveRound = GameRound()
        
        timedRound.setGameType(.Timed(duration: 15))
        timedObjectiveRound.setGameType(.TimedObjective(duration: 15))
        objectiveRound.setGameType(.Objective)
        
        let ctd = CoverTheDot(gameRound: timedRound.copy() as! GameRound)
        let ttd = TapTheDot(gameRound: timedObjectiveRound.copy() as! GameRound)
        let flpybrd = FlappyBird(gameRound: objectiveRound.copy() as! GameRound)
        
        gamesArray.append(ctd)
        gamesArray.append(ttd)
        gamesArray.append(flpybrd)
        
        gamesArray.shuffleInPlace()
        
        var gamesNames : [String] = []
        
        for game in gamesArray {
            switch game {
            case _ where (game as? CoverTheDot) != nil:
                gamesNames.append(String(CoverTheDot))
            case _ where (game as? TapTheDot) != nil:
                gamesNames.append(String(TapTheDot))
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

//struct GameList {
//    
//    static func coverTheDot(duration: Int) -> CoverTheDot {
//        let gameRound = GameRound(gameType: .Timed(duration: duration))
//        return CoverTheDot(gameRound: gameRound)
//    }
//    static func tapTheDot(taps: Int) -> TapTheDot {
//        let gameRound = GameRound(gameType: .TimedObjective(duration: 15))
//        return TapTheDot(gameRound: gameRound)
//    }
//}

//typealias GameType = Int->MiniGame
//enum Games : GameType {
//}