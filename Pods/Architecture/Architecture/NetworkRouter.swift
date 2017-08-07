//
//  NetworkRouter.swift
//  CoordinatorType-iOSExample
//
//  Created by Reid Chatham on 6/1/17.
//  Copyright © 2017 Reid Chatham. All rights reserved.
//

import Foundation

/// Networking object which can be used to make data calls.
public protocol NetworkRouter: class {
    static var shared: Self { get }
}

/// A NetworkRouter that cannot be used to perform any functions.
public final class NilRouter: NetworkRouter {
    public static let shared = NilRouter()
}
