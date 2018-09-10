// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit

/**
 By default the hoverable button increases it's size when the cursor is hovering over it, and trigger selection action when it completes its dialation animation. Similarily, it decreases its size, and trigger deselection action when it completes its shrinking animation.
 Subclass of UIHoverableButton can customize the animation of hovering by overriding methods hoverAnimation() and deHoverAnimation()
 Override methods select() and deselect() to define what to do whenever the button completes animation.
 */
class UIHoverableButton: UIButton {
    public var name: String = "untitled"
    public var hoverScale: Float = 1.3 // The scaling factor when the button is hovered over
    public var inAlpha: CGFloat = 1.0 // The button alpha when it is hovered over
    public var outAlpha: CGFloat = 0.5 // The button alpha when it is not hovered over
    public var enableHapticFeedBack: Bool = true // whether to generate haptic feedback when the button is selected
    public var dwellDuration: Float { //in seconds, for how long would you like gaze to dwell on the instance of the button before it triggers touch up event
        set{
            dwellTime = newValue
            throttler = ChargingThrottler(seconds: dwellTime)
        }
        get{
            return dwellTime
        }
    }
    
    internal var dwellTime: Float = 1
    internal var throttler: ChargingThrottler? = ChargingThrottler(seconds: 1)
    internal var isSelect: Bool = false
    
    internal let feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    
    /**
      Overridable. Define the behavior when the button is selected
     */
    public func select(){
    }
    
    internal func _select(){
        if !self.isSelect {
            self.isSelect = true
            DispatchQueue.main.async {
                self.feedbackGenerator.impactOccurred()
                // Trigger any hander listening the touchUpInside event should you defined any in Storyboard for this instance of button
                self.sendActions(for: .touchUpInside)
                self.select()
            }
        }
    }
    
    /**
      Overridable. Define the behavior when the button is deselected
     */
    public func deselect(){
    }
    
    internal func _deselect(){
        if self.isSelect{
            self.isSelect = false
            DispatchQueue.main.async {
                // Trigger any hander listening the touchUpOutside event should you defined any in Storyboard for this instance of button
                self.sendActions(for: .touchUpOutside)
                self.deselect()
            }
        }
    }

    /**
      Overridable. Define the animation when cursor is hovering over the button.
     */
    public func hoverAnimation(){
        self.alpha = self.inAlpha
        self.transform = CGAffineTransform(scaleX: CGFloat(hoverScale),
                                           y: CGFloat(hoverScale) )
    }
    
    /**
      Overridable. Define the animation when cursor leave the button.
     */
    public func deHoverAnimation(){
        self.alpha = self.outAlpha
        self.transform = .identity
    }
    
    /**
      Call the function with gaze object that is used by the button to determine intersection and perform relevant animation for hovering duration.
      @param gaze: a UIHeadGaze object with gaze location.
     */
    public func hover(gaze: UIHeadGaze){
        let headCursorPos = gaze.location(in: self.superview)
        if self.frame.contains(headCursorPos) {
            UIView.animate(withDuration: TimeInterval(dwellTime), animations: {() -> Void in
                self.hoverAnimation()
            }, completion: {(finished: Bool) in
                self.throttler?.throttle(eventtype: EventType(1), block: {
                    self._select()
                })
            })
        }else{
            UIView.animate(withDuration: TimeInterval(dwellTime), animations: {() -> Void in
                self.deHoverAnimation()
            }, completion: {(finished: Bool) in
                //add dehovering throttle to force hovering throttle to wait for seconds before execute
                self.throttler?.throttle(eventtype: EventType(-1), block: {
                    self._deselect()
                })
            })
        }
    }
    
}
