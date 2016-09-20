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
    
    var gameStartCallback : ([MiniGame])->Void = {_ in}
    var labelCallback : ((String)->Void)?
    
    fileprivate(set) var player : Player {
        didSet {
            let scoreObject : [String:AnyObject] = ["score":player.score as AnyObject]
            connectionManager.sendEvent(scoreObject)
        }
    }
    fileprivate(set) var connectedPlayers : [Player] = []
    fileprivate let connectionManager : PeerConnectionManager
    
    init(connectionManager: PeerConnectionManager) {
        self.player = Player(peer: connectionManager.peer)
        self.connectionManager = connectionManager
        
        self.connectionManager
            .listenOn({ [weak self] (event) in
                
                switch event {
                case .devicesChanged(let peer, _):
                    
                    switch peer.status {
                    case .connected:
                        guard let players = self?.connectedPlayers,
                            !players.contains(Player(peer: peer))
                            else { return }
                        self?.connectedPlayers += [Player(peer: peer)]
                        
                    case .notConnected:
                        guard let index = self?.connectedPlayers.index(of: Player(peer: peer)) else { return }
                        self?.connectedPlayers.remove(at: index)
                        
                    default : break
                    }
                    if let output = self?.outputStringForArray() {
                        self?.labelCallback?(output)
                    }
                    
                case .receivedEvent(let peer, let eventInfo):
                    
                    if let gamesNames = eventInfo["start"] as? [String] {
                        
                        var games: [MiniGame] = []
                        
                        for gameName in gamesNames {
                            switch gameName {
                            case "CoverTheDot":
                                games.append(CoverTheDot())
                            case "TapTheDot":
                                games.append(TapTheDot())
                            case "FlappyBird":
                                games.append(FlappyBird())
                            default : break
                            }
                        }
                        self?.gameStartCallback(games)
                    }
                    else if let score = eventInfo["score"] as? Int {
                        self?.connectedPlayers = self!.connectedPlayers.map { (player) in
                            if player.peer == peer {
                                return Player(peer: peer, score: score)
                            } else {
                                return player
                            }
                        }
                        if let output = self?.outputStringForArray() {
                            self?.labelCallback?(output)
                        }
                    }
                    
                default : break
                }
            }, withKey: "GameSetup")
    }
    
    func sendStartGameData() -> [MiniGame] {
        
        var gamesArray : [MiniGame] = [
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
                gamesNames.append(String(describing: CoverTheDot.self))
            case _ where (game as? TapTheDot) != nil:
                gamesNames.append(String(describing: TapTheDot.self))
            case _ where (game as? FlappyBird) != nil:
                gamesNames.append(String(describing: FlappyBird.self))
            case _ where (game as? UnrollTheToiletPaper) != nil:
                gamesNames.append(String(describing: UnrollTheToiletPaper.self))
            default: break
            }
        }
        
        let startObject : [String:AnyObject] = ["start":gamesNames as AnyObject]
        connectionManager.sendEvent(startObject)
        
        return gamesArray
    }
    
    func incrementScoreBy(_ points: Int) {
        player.incrementScoreBy(points)
    }
    
    func endConnection() {
        connectionManager.stop()
    }
    
    func outputStringForArray() -> String {
        
        let output = "Connected gremlins:\n"
            + (connectedPlayers.map { "Player: \($0.name), Score: \($0.score)\n" }.reduce("",+))
            + "My score: \(player.score)"
        
        return output
    }
}
