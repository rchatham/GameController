//
//  PeerConnectionListener.swift
//  GameController
//
//  Created by Reid Chatham on 12/25/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation

enum PeerConnectionEvent {
    case Ready
    case Started
    case DevicesChanged(peer: Peer, displayNames: [String])
    case ReceivedData(peer: Peer, data: NSData)
    case ReceivedStream(peer: Peer, stream: NSStream, name: String)
    case StartedReceivingResource(peer: Peer, name: String, progress: NSProgress)
    case FinishedReceivingResource(peer: Peer, name: String, url: NSURL, error: NSError?)
    case ReceivedCertificate(peer: Peer, certificate: [AnyObject]?, handler: (Bool) -> Void)
    case Error(PeerConnectionError)
    case Ended
}

enum PeerConnectionError : ErrorType {
    case Error(NSError)
    case DidNotStartAdvertisingPeer(NSError)
    case DidNotStartBrowsingForPeers(NSError)
}

struct PeerConnectionListener {
    
    private let peerEventObserver : Observable<PeerConnectionEvent>
    
    typealias Listener = PeerConnectionEvent->Void
    internal private(set) var listeners : [Listener] = []
    
    init(observer: Observable<PeerConnectionEvent>) {
        peerEventObserver = observer
    }
    
    // Listeners
    private mutating func addListener(listener: Listener) -> PeerConnectionListener {
        listeners.append(listener)
        peerEventObserver.addObserver(listener)
        return self
    }
    
    private mutating func addListeners(listeners: [Listener]) -> PeerConnectionListener {
        listeners.forEach { addListener($0) }
        return self
    }
    
    private mutating func removeListeners() {
        listeners = []
        peerEventObserver.observers = []
    }
    
    
    typealias ReadyListener = Void->Void
    typealias StartListener = Void->Void
    typealias SessionEndedListener = Void->Void
    
    typealias DevicesChangedListener = (peer: Peer, displayNames: [String])->Void
    typealias DataListener = (peer: Peer, data: NSData)->Void
    typealias StreamListener = (peer: Peer, stream: NSStream, name: String)->Void
    typealias StartedReceivingResourceListener = (peer: Peer, name: String, progress: NSProgress)->Void
    typealias FinishedReceivingResourceListener = (peer: Peer, name: String, url: NSURL, error: NSError?)->Void
    typealias CertificateReceivedListener = (peer: Peer, certificate: [AnyObject]?, handler: (Bool) -> Void)->Void
    
    typealias ErrorListener = (error: PeerConnectionError)->Void
    
    mutating func listenOn(ready ready: ReadyListener = { _ in },
        started: StartListener = { _ in },
        devicesChanged: DevicesChangedListener = { _ in },
        dataReceived: DataListener = { _ in },
        streamReceived: StreamListener = { _ in },
        receivingResourceStarted: StartedReceivingResourceListener = { _ in },
        receivingResourceFinished: FinishedReceivingResourceListener = { _ in },
        certificateReceived: CertificateReceivedListener = { _ in },
        ended: SessionEndedListener = { _ in },
        error: ErrorListener = { _ in }
        ) -> PeerConnectionListener {
            
            addListener { event in
                switch event {
                    
                case .Ready: ready()
                case .Started: started()
                    
                case .DevicesChanged(peer: let peer, displayNames: let names):
                    devicesChanged(peer: peer, displayNames: names)
                    
                case .ReceivedData(peer: let peer, data: let data):
                    dataReceived(peer: peer, data: data)
                    
                case .ReceivedStream(peer: let peer, stream: let stream, name: let name):
                    streamReceived(peer: peer, stream: stream, name: name)
                    
                case .StartedReceivingResource(peer: let peer, name: let name, progress: let progress):
                    receivingResourceStarted(peer: peer, name: name, progress: progress)
                    
                case .FinishedReceivingResource(peer: let peer, name: let name, url: let url, error: let error):
                    receivingResourceFinished(peer: peer, name: name, url: url, error: error)
                    
                case .ReceivedCertificate(peer: let peer, certificate: let certificate, handler: let handler):
                    certificateReceived(peer: peer, certificate: certificate, handler: handler)
                    
                case .Ended: ended()
                case .Error(let e): error(error: e)
                    
//                default: break
                }
            }
            return self
    }
    
    mutating func stopListening() {
        removeListeners()
    }
}