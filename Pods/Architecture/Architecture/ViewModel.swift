//
//  ViewModel.swift
//  CoordinatorType-iOSExample
//
//  Created by Reid Chatham on 6/1/17.
//  Copyright © 2017 Reid Chatham. All rights reserved.
//

import Foundation

/// The ViewModel maintains a view's state object as well as it's interface with it's network.
public protocol ViewModel: Stateful, Networking {}

/// Conforming to Stateful means you keep a state object.
public protocol Stateful {
    associatedtype Data
    associatedtype E: Error
    var state: State<Data, E>? { get }
}

/// Conforming to Networking means you have access to a network router
public protocol Networking {
    associatedtype Network: NetworkRouter
    weak var network: Network? { get }
}

extension Networking {
    public weak var network: Network? {
        return Network.shared as Self.Network
    }
}


/// NilStateViewModel. 
/// Initializes with no state for the ViewModel but needs a network specified.
public protocol NilStateViewModel: ViewModel {
    typealias E = NoError
    typealias Data = Void
}

/// NilNetworkViewModel. 
/// Initializes with no network, needs the state specified.
public protocol NilNetworkViewModel: ViewModel {
    typealias Network = NilRouter
}

extension NilNetworkViewModel {
    weak var network: NilRouter? { return nil }
}
