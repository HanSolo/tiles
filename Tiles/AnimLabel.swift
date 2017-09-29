//
//  EFCountingLabel.swift
//  Tiles
//
//  Created by Gerrit Grunwald on 29.09.17.
//  Copyright © 2017 Gerrit Grunwald. All rights reserved.
//

import UIKit

public enum AnimLabelCountingMethod: Int {
    case linear    = 0
    case easeIn    = 1
    case easeOut   = 2
    case easeInOut = 3
}

//MARK: - UILabelCounter
let kUILabelCounterRate = Float(3.0)

public protocol UILabelCounter {
    func update(_ t: CGFloat) -> CGFloat
}

public class UILabelCounterLinear: UILabelCounter {
    public func update(_ t: CGFloat) -> CGFloat {
        return t
    }
}

public class UILabelCounterEaseIn: UILabelCounter {
    public func update(_ t: CGFloat) -> CGFloat {
        return CGFloat(powf(Float(t), kUILabelCounterRate))
    }
}

public class UILabelCounterEaseOut: UILabelCounter {
    public func update(_ t: CGFloat) -> CGFloat {
        return CGFloat(1.0 - powf(Float(1.0 - t), kUILabelCounterRate))
    }
}

public class UILabelCounterEaseInOut: UILabelCounter {
    public func update(_ t: CGFloat) -> CGFloat {
        let newt: CGFloat = 2 * t
        if newt < 1 {
            return CGFloat(0.5 * powf (Float(newt), kUILabelCounterRate))
        } else {
            return CGFloat(0.5 * (2.0 - powf(Float(2.0 - newt), kUILabelCounterRate)))
        }
    }
}

//MARK: - AnimLabel
public class AnimLabel: UILabel {
    public var format            = "%f"
    public var method            = AnimLabelCountingMethod.linear
    public var animationDuration = TimeInterval(2)
    public var formatBlock          : ((CGFloat) -> String)?
    public var attributedFormatBlock: ((CGFloat) -> NSAttributedString)?
    public var completionBlock      : (() -> Void)?
    
    private var startingValue       : CGFloat!
    private var destinationValue    : CGFloat!
    private var progress            : TimeInterval = 0
    private var lastUpdate          : TimeInterval!
    private var totalTime           : TimeInterval!
    private var easingRate          : CGFloat!
    
    private var timer               : CADisplayLink?
    private var counter             : UILabelCounter = UILabelCounterLinear()
    
    public func countFrom(_ startValue: CGFloat, to endValue: CGFloat) {
        self.countFrom(startValue, to: endValue, withDuration: self.animationDuration)
    }
    
    public func countFrom(_ startValue: CGFloat, to endValue: CGFloat, withDuration duration: TimeInterval) {
        self.startingValue    = startValue
        self.destinationValue = endValue
        
        // remove any (possible) old timers
        self.timer?.invalidate()
        self.timer = nil
        
        if duration == 0.0 {
            // No animation
            self.setTextValue(endValue)
            self.runCompletionBlock()
            return
        }
        
        self.easingRate = 3.0
        self.progress   = 0
        self.totalTime  = duration
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        switch self.method {
        case .linear:
            self.counter = UILabelCounterLinear()
            break
        case .easeIn:
            self.counter = UILabelCounterEaseIn()
            break
        case .easeOut:
            self.counter = UILabelCounterEaseOut()
            break
        case .easeInOut:
            self.counter = UILabelCounterEaseInOut()
            break
        }
        
        let timer = CADisplayLink(target: self, selector: #selector(AnimLabel.updateValue(_:)))
        if #available(iOS 10.0, *) {
            timer.preferredFramesPerSecond = 30
        } else {
            timer.frameInterval = 2
        }
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        timer.add(to: RunLoop.main, forMode: RunLoopMode.UITrackingRunLoopMode)
        self.timer = timer
    }
    
    public func countFromCurrentValueTo(_ endValue: CGFloat) {
        self.countFrom(self.currentValue(), to: endValue)
    }
    
    public func countFromCurrentValueTo(_ endValue: CGFloat, withDuration duration: TimeInterval) {
        self.countFrom(self.currentValue(), to: endValue, withDuration: duration)
    }
    
    public func countFromZeroTo(_ endValue: CGFloat) {
        self.countFrom(0, to: endValue)
    }
    
    public func countFromZeroTo(_ endValue: CGFloat, withDuration duration: TimeInterval) {
        self.countFrom(0, to: endValue, withDuration: duration)
    }
    
    public func currentValue() -> CGFloat {
        if self.progress == 0 {
            return 0
        } else if self.progress >= self.totalTime {
            return self.destinationValue
        }
        
        let percent   = self.progress / self.totalTime
        let updateVal = self.counter.update(CGFloat(percent))
        
        return self.startingValue + updateVal * (self.destinationValue - self.startingValue)
    }
    
    @objc public func updateValue(_ timer: Timer) {
        // update progress
        let now         = Date.timeIntervalSinceReferenceDate
        self.progress   = self.progress + now - self.lastUpdate
        self.lastUpdate = now
        
        if self.progress >= self.totalTime {
            self.timer?.invalidate()
            self.timer    = nil
            self.progress = self.totalTime
        }
        
        self.setTextValue(self.currentValue())
        
        if self.progress == self.totalTime {
            self.runCompletionBlock()
        }
    }
    
    private func setTextValue(_ value: CGFloat) {
        if let tryAttributedFormatBlock = self.attributedFormatBlock {
            self.attributedText = tryAttributedFormatBlock(value)
        } else if let tryFormatBlock = self.formatBlock {
            self.text = tryFormatBlock(value)
        } else {
            // check if counting with ints - cast to int
            if (nil != self.format.range(of: "%(.*)d", options: String.CompareOptions.regularExpression, range: nil)
                || nil != self.format.range(of: "%(.*)i")) {
                self.text = String(format: self.format, Int(value))
            } else {
                self.text = String(format: self.format, value)
            }
        }
    }
    
    private func setFormat(_ format: String) {
        self.format = format
        self.setTextValue(self.currentValue())
    }
    
    private func runCompletionBlock() {
        if let tryCompletionBlock = self.completionBlock {
            tryCompletionBlock()
            self.completionBlock = nil
        }
    }
}
