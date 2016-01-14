//
//  DotView.swift
//  CoverTheDot
//
//  Created by Reid Chatham on 10/13/15.
//  Copyright © 2015 Hermes Messenger LLC. All rights reserved.
//

import UIKit

class DotView: UIView {  // BezierPathsView {
    
//    private var currentSizeRatio: Int = 5
    private func sizeRatio() -> Int {
        return Int.random(5) + 2
    }
    
    private var dotSize: CGSize {
        guard let superWidth = superview?.bounds.size.width else { return CGSizeZero }
        let size = superWidth / CGFloat(sizeRatio())
        return CGSize(width: size, height: size)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = frame.size.width/2
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

extension DotView {
    
    override var frame: CGRect {
        didSet {
            //            self.layer.cornerRadius = self.bounds.size.width/2
            //            self.clipsToBounds = true
            self.backgroundColor = UIColor.random
            //            setPath(dot, named: PathNames.DotPath)
            
            NSTimer.scheduledTimerWithTimeInterval(Double(Int.random(5)+1),
                target: self, selector: Selector("moveDot:"),
                userInfo: nil,
                repeats: false)
        }
    }
    
    func moveDot(timer: NSTimer) {
        print("Move dot")
        let size = dotSize
        guard let superviewFrame = superview?.frame else { return }
        let x = CGFloat.random(Int(superviewFrame.size.width - size.width))
        let y = CGFloat.random(Int(superviewFrame.size.height - size.height))
        //        let newOrigin = CGPoint(x: x, y: y)
        let frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        resizeCircleView(frame: frame, duration: 1.0)
    }
    
    func resizeCircleView(frame frame: CGRect, duration: Double) {
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            [unowned self] in
            self.frame = frame
            }, completion: nil)
        
        let cornerRadius = frame.size.width/2
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)  //(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.layer.cornerRadius
        animation.duration = duration
        self.layer.cornerRadius = cornerRadius
        self.layer.addAnimation(animation, forKey: "cornerRadius")
    }
}

private extension Int {
    static func random(max: Int) -> Int {
        return Int(arc4random() % UInt32(max))
    }
}

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.redColor()
        case 3: return UIColor.yellowColor()
        case 4: return UIColor.magentaColor()
        default: return UIColor.blackColor()
        }
    }
}