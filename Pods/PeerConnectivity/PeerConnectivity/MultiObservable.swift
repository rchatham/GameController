//
//  MultiObserver.swift
//  GameController
//
//  Created by Reid Chatham on 1/18/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

internal class MultiObservable<T> {
    internal typealias Observer = T -> Void
    internal var observers: [String:Observer] = [:]
    
    internal func addObserver(observer: Observer, key: String) {
        observer(value)
        self.observers[key] = observer
    }
    
    internal func removeObserverForkey(key: String) {
        self.observers.removeValueForKey(key)
    }
    
    internal var value: T {
        didSet {
            for (_, observer) in observers {
                observer(value)
            }
        }
    }
    
    internal init(_ v: T) {
        value = v
    }
}