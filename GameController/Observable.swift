//
//  Observable.swift
//  GameController
//
//  Created by Reid Chatham on 12/21/15.
//  Copyright © 2015 Reid Chatham. All rights reserved.
//

import Foundation

class Observable<T> {
    typealias Observer = T -> Void
    var observers: [Observer] = []
  
    func addObserver(observer: Observer) {
        observer(value)
        self.observers.append(observer)
    }
  
    var value: T {
        didSet {
            observers.forEach { observer in
                observer(value)
            }
        }
    }
  
    init(_ v: T) {
        value = v
    }
}
