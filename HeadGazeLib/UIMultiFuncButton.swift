// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

import UIKit

class UIMultiFuncButton: UIBubbleButton {

    private var clickCount = 0
    internal var darkFillView2: UIView? = nil
    internal var longDwellTime: Float = 2
    internal var throttler2: ChargingThrottler? = ChargingThrottler(seconds: 2)
    public var longDwellDuration: Float { //in seconds, for how long would you like gaze to dwell on the instance of the button before it triggers touchDownRepeat event
        set{
            longDwellTime = newValue
            throttler2 = ChargingThrottler(seconds: longDwellTime)
        }
        get{
            return longDwellTime
        }
    }
    
    override internal func setupUI(frame: CGRect) {
        //add dark fill
        let w = frame.width
        let h = frame.height
        self.clipsToBounds = true
        super.outAlpha = 0.1 //alpha of the button when it's been hovered over
        self.hoverScale = Float(max(w, h)) //*0.9
        
        self.layer.cornerRadius = min(w,h) / 5.0
        self.setTitleColor(UIColor.black, for: .normal)
        self.backgroundColor = UIColor.white
        self.alpha = 1.0
        
        let dummyFrame = CGRect(x: w/2, y: h/2, width: 1, height: 1)
        darkFillView = UIView(frame: dummyFrame)
        darkFillView?.backgroundColor = eBayColors.blue
        darkFillView?.layer.cornerRadius = 0.5
        addSubview(darkFillView!)
        
        darkFillView2 = UIView(frame: dummyFrame)
        darkFillView2?.backgroundColor = eBayColors.green
        darkFillView2?.layer.cornerRadius = 0.5
        addSubview(darkFillView2!)
    }
    
    /**
     Overridable. Define the animation when cursor is long hovering over the button
     */
    func hoverAnimation2() {
            self.darkFillView2!.alpha = self.inAlpha
            self.darkFillView2!.transform = CGAffineTransform(scaleX: CGFloat(hoverScale), y: CGFloat(hoverScale) )
    }
    
    
    /**
     Overridable. Define the animation when cursor leave the button after long hovering.
     */
    public func deHoverAnimation2() {
        DispatchQueue.main.async {
            self.darkFillView2!.alpha = self.outAlpha
            self.darkFillView2!.transform = .identity
        }
    }
    
    private func _secondSelect(){
        if self.clickCount == 1 {
            self.isSelect = true
            DispatchQueue.main.async {
                self.feedbackGenerator.impactOccurred()
            // Trigger any hander listening the touchUpInside event should you defined any in Storyboard for this instance of button
             //   self.sendActions(for: .touchUpInside)
                self.sendActions(for: .touchDownRepeat)
                self.select()
            }
        }
    }
    
    /**
     Call the function with gaze object that is used by the button to determine intersection and perform relevant animation for hovering duration.
     @param gaze: a UIHeadGaze object with gaze location.
     */
    override public func hover(gaze: UIHeadGaze){
        let headCursorPos = gaze.location(in: self.superview)
        if self.frame.contains(headCursorPos) {
                UIView.animateKeyframes(withDuration: TimeInterval(longDwellTime), delay: 0, options: [.calculationModeCubic], animations: {
                // Add animations
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: Double(self.dwellTime / self.longDwellTime), animations: {
                    self.hoverAnimation()
                })
                UIView.addKeyframe(withRelativeStartTime: Double(self.dwellTime / self.longDwellTime), relativeDuration: Double((self.longDwellTime - self.dwellTime) / self.longDwellTime), animations: {
                    self.hoverAnimation2()
                })
            }, completion:{ _ in
                self.throttler?.throttle(eventtype: EventType(1), block: {
                    self._select()
                    self.clickCount = 1
                })
                self.throttler2?.throttle(eventtype: EventType(1), block: {
                    self._secondSelect()
                    self.deHoverAnimation2()
                })
            })
        } else {
            UIView.animate(withDuration: TimeInterval(dwellTime), animations: {() -> Void in
                self.deHoverAnimation()
                self.deHoverAnimation2()
            }, completion: {(finished: Bool) in
                //add dehovering throttle to force hovering throttle to wait for seconds before execute
                self.throttler?.throttle(eventtype: EventType(0), block: {
                    self._deselect()
                    self.clickCount = 0
                })
                self.throttler2?.throttle(eventtype: EventType(0), block: {  })
            })
        }
    }

}
