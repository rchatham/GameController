//: Playground - noun: a place where people can play

import Cocoa
import MultipeerConnectivity

var str = "Hello, playground"


enum Peer {
    case CurrentUser(MCPeerID)
    case Connected(MCPeerID)
    case Connecting(MCPeerID)
    case Disconnected(MCPeerID)
}

