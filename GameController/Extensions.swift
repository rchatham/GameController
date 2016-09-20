//
//  Extensions.swift
//  GameController
//
//  Created by Reid Chatham on 1/9/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit


extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int, IndexDistance == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0 ..< count-1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

//[1, 2, 3].shuffle()
// [2, 3, 1]

//let fiveStrings = 0.stride(through: 100, by: 5).map(String.init).shuffle()
// ["20", "45", "70", "30", ...]

//var numbers = [1, 2, 3, 4]
//numbers.shuffleInPlace()
// [3, 2, 1, 4]


extension Int {
    static func random(_ max: Int) -> Int {
        return Int(arc4random() % UInt32(max))
    }
}

extension CGFloat {
    static func random(_ max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

extension UIColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return UIColor.green
        case 1: return UIColor.blue
        case 2: return UIColor.red
        case 3: return UIColor.yellow
        case 4: return UIColor.magenta
        default: return UIColor.black
        }
    }
}
