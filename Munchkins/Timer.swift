//
//  Timer.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

open class Timer: NSObject {
    
    open var timeRemaining: Int {
        return Int(timer?.fireDate.timeIntervalSinceNow ?? 0)
    }
    
    fileprivate let timeInterval: TimeInterval
    fileprivate let userInfo: AnyObject?
    fileprivate let callback: (Void)->Void
    fileprivate let repeats: Bool
    fileprivate let invalidateAfter: Date?
    fileprivate var timer: Foundation.Timer?
    fileprivate var timeToResume: TimeInterval = 0
    
    public init(timeInterval: TimeInterval,
         userInfo: AnyObject? = nil,
         repeats: Bool = false,
         invalidateAfter: TimeInterval? = nil,
         startOnCreation: Bool = true,
         callback: @escaping (Void)->Void) {
        
        self.timeInterval = timeInterval
        self.userInfo = userInfo
        self.repeats = repeats
        self.invalidateAfter = (invalidateAfter != nil) ? Date(timeIntervalSinceNow: invalidateAfter!) : nil
        self.callback = callback
        super.init()
        if startOnCreation {
            timer =  Foundation.Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(Timer.performCallback), userInfo: userInfo, repeats: repeats)
        }
    }
    
    public init(timeInterval: TimeInterval,
         userInfo: AnyObject?,
         repeats: Bool,
         startAfter: TimeInterval,
         invalidateAfter: TimeInterval,
         callback: @escaping (Void)->Void) {
        
        self.timeInterval = timeInterval
        self.userInfo = userInfo
        self.repeats = repeats
        self.invalidateAfter = Date(timeIntervalSinceNow: invalidateAfter)
        self.callback = callback
        super.init()
        Foundation.Timer.scheduledTimer(timeInterval: startAfter, target: self, selector: #selector(Timer.createTimer), userInfo: nil, repeats: false)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    internal func createTimer() {
        timer =  Foundation.Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(Timer.performCallback), userInfo: userInfo, repeats: repeats)
    }
    
    open func start() {
        if timer == nil {
            createTimer()
        }
    }
    
    open func pause() {
        self.timeToResume = timer?.fireDate.timeIntervalSinceNow ?? 0.0
        timer?.invalidate()
        timer = nil
    }
    
    open func resume() {
        timer = Foundation.Timer.scheduledTimer(timeInterval: timeToResume, target: self, selector: #selector(Timer.performCallback), userInfo: userInfo, repeats: repeats)
    }
    
    open func stop() {
        timer?.invalidate()
    }
    
    internal func performCallback(_ timer: Foundation.Timer) {
        callback()
        if invalidateAfter != nil && Date() > invalidateAfter! {
            timer.invalidate()
        }
    }
}
