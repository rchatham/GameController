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
    case InviteOnly(MCBrowserViewController->Void)
    case InviteOnly2(PeerBrowserAssisstant->Void)
}

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
                observer.value = .DevicesChanged(peer: peer, displayNames: self.connectedPeers.map { $0.displayName })
            case .DidReceiveData(peer: _, data: _): break
            default: break
            }
        }
    }
}

extension PeerConnectionManager {
    // Start/Stop
    
    func start(completion: Void->Void) {
        session.startSession()
        switch connectionType {
        case .Automatic:
            browser.startBrowsing()
            advertiser.startAdvertising()
//            advertiserAssisstant.startAdvertisingAssisstant()
            
            observeBrowserFoundPeer(browserObserver)
            observeAdertiserInvitation(advertiserObserver)
            completion()
            
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
            handler(browserAssisstant.peerBrowserViewController())
            
        case .InviteOnly2(let handler):
            browserViewControllerObserver.addObserver { event in
                switch event {
                case .DidFinish: completion()
                case .WasCancelled: self.stop()
                case .None: break
                }
            }
            browserAssisstant.startBrowsingAssisstant()
            advertiserAssisstant.startAdvertisingAssisstant()
            handler(browserAssisstant)
        }
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
    typealias StartedRecievingResourceListener = (peer: Peer, name: String, progress: NSProgress)->Void
    typealias FinishedRecievingResourceListener = (peer: Peer, name: String, url: NSURL, error: NSError?)->Void
    typealias CertificateRecievedListener = (peer: Peer, certificate: [AnyObject]?, handler: (Bool) -> Void)->Void
    typealias ErrorListener = (error: PeerConnectionError)->Void
    
    mutating func listenOn(ready ready: ReadyListener = { _ in },
        started: StartListener = { _ in },
        devicesChanged: DevicesChangedListener = { _ in },
        dataRecieved: DataListener = { _ in },
        streamRecieved: StreamListener = { _ in },
        recievingResourceStarted: StartedRecievingResourceListener = { _ in },
        recievingResourceFinished: FinishedRecievingResourceListener = { _ in },
        certificateRecieved: CertificateRecievedListener = { _ in },
        ended: SessionEndedListener = { _ in },
        error: ErrorListener = { _ in }
        ) {
            
        listener.listenOn(
            ready: ready,
            started: started,
            devicesChanged: devicesChanged,
            dataRecieved: dataRecieved,
            streamRecieved: streamRecieved,
            recievingResourceStarted: recievingResourceStarted,
            recievingResourceFinished: recievingResourceFinished,
            certificateRecieved: certificateRecieved,
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
            case .DidReceiveInvitationFromPeer(peer: let peer, withContext: _, invitationHandler: let handler):
                let accept = self.session.session.myPeerID.hashValue > peer.peerID.hashValue
                handler(accept, self.session.session)
                if accept {
                    self.advertiser.stopAdvertising()
                }
            default: break
            }
        }
    }
}