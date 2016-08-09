//
//  Timer.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

public class Timer: NSObject {
    
    public var timeRemaining: Int {
        return Int(timer?.fireDate.timeIntervalSinceNow ?? 0)
    }
    
    private let timeInterval: NSTimeInterval
    private let userInfo: AnyObject?
    private let callback: Void->Void
    private let repeats: Bool
    private let invalidateAfter: NSDate?
    private var timer: NSTimer?
    private var timeToResume: NSTimeInterval = 0
    
    public init(timeInterval: NSTimeInterval,
         userInfo: AnyObject? = nil,
         repeats: Bool = false,
         invalidateAfter: NSTimeInterval? = nil,
         startOnCreation: Bool = true,
         callback: Void->Void) {
        
        self.timeInterval = timeInterval
        self.userInfo = userInfo
        self.repeats = repeats
        self.invalidateAfter = (invalidateAfter != nil) ? NSDate(timeIntervalSinceNow: invalidateAfter!) : nil
        self.callback = callback
        super.init()
        if startOnCreation {
            timer =  NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(Timer.performCallback), userInfo: userInfo, repeats: repeats)
        }
    }
    
    public init(timeInterval: NSTimeInterval,
         userInfo: AnyObject?,
         repeats: Bool,
         startAfter: NSTimeInterval,
         invalidateAfter: NSTimeInterval,
         callback: Void->Void) {
        
        self.timeInterval = timeInterval
        self.userInfo = userInfo
        self.repeats = repeats
        self.invalidateAfter = NSDate(timeIntervalSinceNow: invalidateAfter)
        self.callback = callback
        super.init()
        NSTimer.scheduledTimerWithTimeInterval(startAfter, target: self, selector: #selector(Timer.createTimer), userInfo: nil, repeats: false)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    internal func createTimer() {
        timer =  NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(Timer.performCallback), userInfo: userInfo, repeats: repeats)
    }
    
    public func start() {
        if timer == nil {
            createTimer()
        }
    }
    
    public func pause() {
        self.timeToResume = timer?.fireDate.timeIntervalSinceNow ?? 0.0
        timer?.invalidate()
        timer = nil
    }
    
    public func resume() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timeToResume, target: self, selector: #selector(Timer.performCallback), userInfo: userInfo, repeats: repeats)
    }
    
    public func stop() {
        timer?.invalidate()
    }
    
    internal func performCallback(timer: NSTimer) {
        callback()
        if invalidateAfter != nil && NSDate() > invalidateAfter! {
            timer.invalidate()
        }
    }
}

private func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs == lhs.laterDate(rhs)
}