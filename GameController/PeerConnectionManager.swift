//
//  PeerConnectionViewModel2.swift
//  GameController
//
//  Created by Reid Chatham on 12/23/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation
import MultipeerConnectivity

typealias ServiceType = String

enum PeerConnectionType {
    case Automatic
//    case InviteOnly(MCBrowserViewController->Void)
    case InviteOnly(PeerBrowserAssisstant->Void)
}

/*
Functional wrapper for Apple's MultipeerConnectivity framework.
*/
struct PeerConnectionManager {
    
    private let connectionType : PeerConnectionType
    private let serviceType : ServiceType
    
    private let sessionObserver = Observable<PeerSessionEvent>(.None)
    private let browserObserver = Observable<PeerBrowserEvent>(.None)
    private let browserViewControllerObserver = Observable<PeerBrowserViewControllerEvent>(.None)
    private let advertiserObserver = Observable<PeerAdvertiserEvent>(.None)
    private let advertiserAssisstantObserver = Observable<PeerAdvertiserAssisstantEvent>(.None)
    
    
    private let sessionEventProducer : PeerSessionEventProducer
    private let browserEventProducer : PeerBrowserEventProducer
    private let browserViewControllerEventProducer : PeerBrowserViewControllerEventProducer
    private let advertiserEventProducer : PeerAdvertiserEventProducer
    private let advertiserAssisstantEventProducer : PeerAdvertiserAssisstantEventProducer
    
    
    private let peer : Peer
    private let session : PeerSession
    private let browser : PeerBrowser
    private let browserAssisstant : PeerBrowserAssisstant
    private let advertiser : PeerAdvertiser
    private let advertiserAssisstant : PeerAdvertiserAssisstant
    
    private var listener : PeerConnectionListener
    
    var connectedPeers : [Peer] {
        return session.connectedPeers
    }
    
    var displayNames : [String] {
        return connectedPeers.map { $0.displayName }
    }
    
    init(connectionType: PeerConnectionType, serviceType: ServiceType, peer: Peer) {
        self.connectionType = connectionType
        self.serviceType = serviceType
        self.peer = peer
        
        sessionEventProducer = PeerSessionEventProducer(observer: sessionObserver)
        browserEventProducer = PeerBrowserEventProducer(observer: browserObserver)
        browserViewControllerEventProducer = PeerBrowserViewControllerEventProducer(observer: browserViewControllerObserver)
        advertiserEventProducer = PeerAdvertiserEventProducer(observer: advertiserObserver)
        advertiserAssisstantEventProducer = PeerAdvertiserAssisstantEventProducer(observer: advertiserAssisstantObserver)
        
        session = PeerSession(peer: peer, eventProducer: sessionEventProducer)
        browser = PeerBrowser(session: session, serviceType: serviceType, eventProducer: browserEventProducer)
        browserAssisstant = PeerBrowserAssisstant(session: session, serviceType: serviceType, eventProducer: browserViewControllerEventProducer)
        advertiser = PeerAdvertiser(session: session, serviceType: serviceType, eventProducer: advertiserEventProducer)
        advertiserAssisstant = PeerAdvertiserAssisstant(session: session, serviceType: serviceType, eventProducer: advertiserAssisstantEventProducer)
        
        let observer = Observable<PeerConnectionEvent>(.Ready)
        listener = PeerConnectionListener(observer: observer)
        
        
        sessionObserver.addObserver { event in
            switch event {
            case .DevicesChanged(peer: let peer):
                observer.value = .DevicesChanged(peer: peer, displayNames: self.displayNames)
            case .DidReceiveData(peer: let peer, data: let data):
                observer.value = .ReceivedData(peer: peer, data: data)
            case .DidReceiveCertificate(peer: let peer, certificate: let certificate, handler: let handler):
                observer.value = .ReceivedCertificate(peer: peer, certificate: certificate, handler: handler)
            case .DidReceiveStream(peer: let peer, stream: let stream, name: let name):
                observer.value = .ReceivedStream(peer: peer, stream: stream, name: name)
            case .StartedReceivingResource(peer: let peer, name: let name, progress: let progress):
                observer.value = .StartedReceivingResource(peer: peer, name: name, progress: progress)
            case .FinishedReceivingResource(peer: let peer, name: let name, url: let url, error: let error):
                observer.value = .FinishedReceivingResource(peer: peer, name: name, url: url, error: error)
            default: break
            }
        }
    }
}

extension PeerConnectionManager {
    // Start/Stop
    
    mutating func start(completion: Void->Void) {
        session.startSession()
        switch connectionType {
        case .Automatic:
            browser.startBrowsing()
            advertiser.startAdvertising()
//            advertiserAssisstant.startAdvertisingAssisstant()
            
            listener.listenOn(certificateReceived: { (peer, certificate, handler) -> Void in
                handler(true)
                })
            
            observeBrowserFoundPeer(browserObserver)
            observeAdertiserInvitation(advertiserObserver)
            completion()
            
//        case .InviteOnly(let handler):
//            browserViewControllerObserver.addObserver { event in
//                switch event {
//                case .DidFinish: completion()
//                case .WasCancelled: self.stop()
//                case .None: break
//                }
//            }
//            browserAssisstant.startBrowsingAssisstant()
//            advertiserAssisstant.startAdvertisingAssisstant()
//            handler(browserAssisstant.peerBrowserViewController())
            
        case .InviteOnly(let handler):
            browserViewControllerObserver.addObserver { event in
                switch event {
                case .DidFinish: completion()
                case .WasCancelled: self.stop()
                case .None: break
                }
            }
            browserAssisstant.startBrowsingAssisstant()
            advertiserAssisstant.startAdvertisingAssisstant()
            
            listener.listenOn(certificateReceived: { (peer, certificate, handler) -> Void in
                handler(true)
            })
            
            handler(browserAssisstant)
        }
    }
    
    func sendData(data: NSData) {
        session.sendData(data)
    }
    
    func stop() {
        session.stopSession()
        browser.stopBrowsing()
        advertiser.stopAdvertising()
        advertiserAssisstant.stopAdvertisingAssisstant()
    }
}

extension PeerConnectionManager {
    // Add listener

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
        dataRecieved: DataListener = { _ in },
        streamRecieved: StreamListener = { _ in },
        recievingResourceStarted: StartedReceivingResourceListener = { _ in },
        recievingResourceFinished: FinishedReceivingResourceListener = { _ in },
        certificateRecieved: CertificateReceivedListener = { _ in },
        ended: SessionEndedListener = { _ in },
        error: ErrorListener = { _ in }
        ) {
            
        listener.listenOn(
            ready: ready,
            started: started,
            devicesChanged: devicesChanged,
            dataReceived: dataRecieved,
            streamReceived: streamRecieved,
            receivingResourceStarted: recievingResourceStarted,
            receivingResourceFinished: recievingResourceFinished,
            certificateReceived: certificateRecieved,
            ended: ended,
            error: error)
    }
    
    mutating func stopListening() {
        listener.stopListening()
    }
}

extension PeerConnectionManager {
    // MARK: Automatic session response
    
    private func observeBrowserFoundPeer(observer: Observable<PeerBrowserEvent>) {
        observer.addObserver { event in
            switch event {
            case .FoundPeer(let peer):
                self.browser.invitePeer(peer)
            default: break
            }
        }
    }
    
    private func observeAdertiserInvitation(observer: Observable<PeerAdvertiserEvent>) {
        observer.addObserver { event in
            switch event {
            case .DidReceiveInvitationFromPeer(peer: _, withContext: _, invitationHandler: let handler):
                handler(true, self.session.session)
//                let accept = self.session.session.myPeerID.hashValue > peer.peerID.hashValue
//                handler(accept, self.session.session)
//                if accept {
                    self.advertiser.stopAdvertising()
//                }
            default: break
            }
        }
    }
    
    private func advertiseOnLostConnection(observer: Observable<PeerSessionEvent>) {
        observer.addObserver { event in
            switch event {
            case .DevicesChanged(peer: _) where self.connectedPeers.count <= 0 :
                self.advertiser.startAdvertising()
            default: break
            }
        }
    }
}