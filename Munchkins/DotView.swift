//
//  DotView.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 10/13/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

class DotView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = frame.size.width/2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            self.backgroundColor = UIColor.random
            
            Foundation.Timer.scheduledTimer(timeInterval: Double(Int.random(5)+1),
                target: self, selector: #selector(DotView.moveDot(_:)),
                userInfo: nil, repeats: false)
        }
    }
    
    func moveDot(_ timer: Foundation.Timer) {
        print("Move dot")
        let size = dotSize
        guard let superviewFrame = superview?.frame else { return }
        let x = CGFloat.random(Int(superviewFrame.size.width - size.width))
        let y = CGFloat.random(Int(superviewFrame.size.height - size.height))
        let frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        resizeCircleView(frame: frame, duration: 1.0)
    }
    
    // MARK: - Private
    
    fileprivate func sizeRatio() -> Int {
        return Int.random(5) + 2
    }
    
    fileprivate var dotSize: CGSize {
        guard let superWidth = superview?.bounds.size.width else { return CGSize.zero }
        let size = superWidth / CGFloat(sizeRatio())
        return CGSize(width: size, height: size)
    }
    
    fileprivate func resizeCircleView(frame: CGRect, duration: Double) {
        
        // TODO: - Make work with spring animations - Was getting wierd behavior
        
        var options = UIViewAnimationOptions()
        options.insert(UIViewAnimationOptions())
        options.insert(.beginFromCurrentState)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                [unowned self] in
                self.frame = frame
            }, completion: nil)
        
        let cornerRadius = frame.size.width/2
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)  //(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.layer.cornerRadius
        animation.toValue = cornerRadius
        animation.duration = duration
        self.layer.cornerRadius = cornerRadius
        self.layer.add(animation, forKey: "cornerRadius")
    }
}
