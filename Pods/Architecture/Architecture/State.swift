//
//  State.swift
//  CoordinatorType-iOSExample
//
//  Created by Reid Chatham on 6/1/17.
//  Copyright © 2017 Reid Chatham. All rights reserved.
//

import Foundation

/// State object which takes generic data and error types and can represent the different states of that object.
public enum State<Data, E: Error> {
    case loading(Progress?)
    case loaded(Data?)
    case error(E)
}

/// Empty enum which cannot be instantiated describing an error that cannot be initialized.
public enum NoError: Error {}
