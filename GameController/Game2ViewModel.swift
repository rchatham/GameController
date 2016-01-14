//
//  Game2ViewModel.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation

class Game2ViewModel {
    
    var player : Player {
        didSet {
            let scoreObject : [String:AnyObject] = ["score":player.score]
            let scoreData = NSKeyedArchiver.archivedDataWithRootObject(scoreObject)
            connectionManager.sendData(scoreData)
        }
    }
    var connectedPlayers : [Player] = []
    
    private var connectionManager : PeerConnectionManager
    
    private var gamesArray : [MiniGame] = []
    
    
    var labelCallback : (String->Void)? {
        didSet {
            guard let labelCallback = labelCallback else { return }
            connectionManager
                .listenOn(devicesChanged: { _, displayNames in
                let output = self.outputStringForArray(prefix: "Connected gremlins:",
                    array: displayNames,
                postfix: "My score: \(self.player.score)")
                labelCallback(output)
            })
        }
    }
    
    var gameStartCallback : Void->Void = {}
    
    init(player: Player, connectionManager: PeerConnectionManager) {
        self.player = player
        self.connectionManager = connectionManager
        
        self.connectionManager
            .listenOn(devicesChanged: { (peer: Peer, displayNames: [String]) -> Void in
                switch peer {
                case .Connected(_):
                    self.connectedPlayers += [Player(peer: peer)]
                case .NotConnected(_):
                    guard let index = self.connectedPlayers.indexOf(Player(peer: peer)) else { return }
                    self.connectedPlayers.removeAtIndex(index)
                default: break
                }
            
            }, dataRecieved: { [weak self]
                (peer: Peer, data: NSData) -> Void in
                
                guard let dataObject = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:AnyObject] else { return }
                
                if let score = dataObject["score"] as? Int {
                    print(score)
                    self?.connectedPlayers = self!.connectedPlayers.map { (var player) in
                        if player.peer == peer {
                            player.score = score
                            return player
                        } else {
                            return player
                        }
                    }
                    self?.labelCallback?(self!.initialOutput())
                
                }
                if let gamesNames = dataObject["start"] as? [String] {
                    
                    for gameName in gamesNames {
                        switch gameName {
                        case "CoverTheDot":
                            self?.gamesArray.append(CoverTheDot(gameRound: GameRound(gameType: .Timed(duration: 15))))
                        case "TapTheDot":
                            self?.gamesArray.append(TapTheDot(gameRound: GameRound(gameType: .Objective)))
                        default: break
                        }
                    }
                    self?.gameStartCallback()
                }
        })
    }
    
    func initiateGame() {
        let timedRound = GameRound(gameType: .Timed(duration:15))
        let objectiveRound = GameRound(gameType: .Objective)
        let ctd = CoverTheDot(gameRound: timedRound.copy() as! GameRound)
        gamesArray.append(ctd)
        let ttd = TapTheDot(gameRound: objectiveRound.copy() as! GameRound)
        gamesArray.append(ttd)
        
//        let flpybrd = FlappyBird(gameRound: objectiveRound.copy() as! GameRound)
//        gamesArray.append(flpybrd)
        
        gamesArray.shuffleInPlace()
    }
    
    func sendStartGameData() {
        
        var gamesNames : [String] = []
        
        for game in gamesArray {
            switch game {
            case _ where (game as? CoverTheDot) != nil:
                gamesNames.append("CoverTheDot")
            case _ where (game as? TapTheDot) != nil:
                gamesNames.append("TapTheDot")
            default: break
            }
        }
        
        let startObject : [String:AnyObject] = ["start":gamesNames]
        let startData = NSKeyedArchiver.archivedDataWithRootObject(startObject)
        connectionManager.sendData(startData)
    }
    
    func getNextGame() -> MiniGame? {
        guard gamesArray.count > 0 else { return nil }
        return gamesArray.removeFirst()
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
//        for string in array {
//            output += (string + "\n")
//        }
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

struct GameList {
    
    static func coverTheDot(duration: Int) -> CoverTheDot {
        let gameRound = GameRound(gameType: .Timed(duration: duration))
        return CoverTheDot(gameRound: gameRound)
    }
    static func tapTheDot(taps: Int) -> TapTheDot {
        let gameRound = GameRound(gameType: .Objective)
        return TapTheDot(gameRound: gameRound)
    }
}

//typealias GameType = Int->MiniGame
//enum Games : GameType {
//}