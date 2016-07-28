//
//  Timer.swift
//  GameController
//
//  Created by Reid Chatham on 7/26/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

public class Timer<T>: NSObject {
    
    private let timeInterval: NSTimeInterval
    private let userInfo: AnyObject?
    private let callback: Void->T
    private let repeats: Bool
    private let invalidateAfter: NSDate
    private var timer: NSTimer?
    
    init(timeInterval: NSTimeInterval,
         userInfo: AnyObject?,
         repeats: Bool,
         invalidateAfter: NSTimeInterval,
         startOnCreation: Bool,
         callback: Void->T) {
        
        self.timeInterval = timeInterval
        self.userInfo = userInfo
        self.repeats = repeats
        self.invalidateAfter = NSDate(timeIntervalSinceNow: invalidateAfter)
        self.callback = callback
        super.init()
        if startOnCreation {
            timer = {
                NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(Timer<T>.performCallback), userInfo: userInfo, repeats: repeats)
            }()
        }
    }
    
    init(timeInterval: NSTimeInterval,
         userInfo: AnyObject?,
         repeats: Bool,
         startAfter: NSTimeInterval,
         invalidateAfter: NSTimeInterval,
         callback: Void->T) {
        
        self.timeInterval = timeInterval
        self.userInfo = userInfo
        self.repeats = repeats
        self.invalidateAfter = NSDate(timeIntervalSinceNow: invalidateAfter)
        self.callback = callback
        super.init()
        NSTimer.scheduledTimerWithTimeInterval(startAfter, target: self, selector: #selector(Timer<T>.createTimer), userInfo: nil, repeats: false)
    }
    
    internal func createTimer() {
        timer = {
            NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(Timer<T>.performCallback), userInfo: userInfo, repeats: repeats)
        }()
    }
    
    public func start() {
        if timer == nil {
            createTimer()
        }
    }
    
    internal func performCallback() {
        callback()
        if NSDate() > invalidateAfter {
            timer?.invalidate()
        }
    }
}

func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs == lhs.laterDate(rhs)
}