//
//  MultiObserver.swift
//  GameController
//
//  Created by Reid Chatham on 1/18/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

class MultiObservable<T> {
    typealias Observer = T -> Void
    var observers: [String:Observer] = [:]
    
    func addObserver(observer: Observer, key: String) {
        observer(value)
        self.observers[key] = observer
    }
    
    func removeObserverForkey(key: String) {
        self.observers.removeValueForKey(key)
    }
    
    var value: T {
        didSet {
            for (_, observer) in observers {
                observer(value)
            }
        }
    }
    
    init(_ v: T) {
        value = v
    }
}