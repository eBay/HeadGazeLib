// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit

/**
 Hoverable button that can track cursor's time and location inside the button. Created for sensitivity analysis.
 */
class UITrackButton: UIBubbleButton {
    // track (x,y) cursor position during hovering
    public var TrackedCursorCoords: [CGPoint] = []
    public var dwellStartTime: Date = Date()
    public var dwellEndTime: Date = Date()
    private var isStartTimeUpdated: Bool = false
    private var isEndTimeUpdated: Bool = false
    private var canTrackCoords: Bool = false
    private var _maxNumSamples: Int = 5 // Number of samples tracked during the hovering duration
    public var maxNumSamples: Int {
        get { return _maxNumSamples }
        set {
            _maxNumSamples = newValue
            if _maxNumSamples > 0 {
                trackThrottler = ChargingThrottler(seconds: dwellDuration/Float(_maxNumSamples+1))
            }else{
                trackThrottler = nil
            }
        }
    }
    internal var trackThrottler: ChargingThrottler? = ChargingThrottler(seconds: 1.0/(5.0+1.0))
    
    /**
     Use current gaze object to update the button hovering status
     
     Parameters
     1. gaze:UIHeadGaze. The gaze object used by the button instance to get cursor location for instersection test.
     2. view:UIView. The view instance, usually the parent of the button. The tracked cursor location is calculated w.r.t the coordinate system of the view. You can pass in it a window instance to track the global coordinates w.r.t the entire device screen. If nil, the default coordinate system is inferred from the parent of the button.
     */
    public func hover(gaze: UIHeadGaze, in view: UIView? = nil){
        let cursorPos = gaze.location(in: self.superview)
        if self.frame.contains(cursorPos) {
            UIView.animate(withDuration: TimeInterval(super.dwellTime), animations: {() -> Void in
                self.hoverAnimation()
                
                // log time stamp. we don't want to repeatly update the start time while
                // the button is hovered over
                if !self.isStartTimeUpdated {//Guaranteed that the start time only updates once since the moment when the cursor enters the button region
                    self.isStartTimeUpdated = true // no need to update starttime until cursor leave the button
                    self.isEndTimeUpdated = false // endtime can be updated from now on
                    self.canTrackCoords = true
                    self.dwellStartTime = Date()
                }
                // track coordinates
                if self.canTrackCoords {//only start tracking coordinates when starttime is updated
                    self.trackThrottler?.throttle(eventtype: EventType(0), block: {
                        var trackPos = CGPoint()
                        DispatchQueue.main.sync {
                            if let inView = view {
                                trackPos = gaze.location(in: inView)
                            }else{
                                trackPos = gaze.location(in: self.superview)
                            }
                        }
                        self.TrackedCursorCoords.append(trackPos)
                    })
                }
            }, completion: {(finished: Bool) in
                self.throttler?.throttle(eventtype: EventType(1), block: {
                    if !self.isEndTimeUpdated {
                        self.isEndTimeUpdated = true
                        self.canTrackCoords = false //stop tracking coords
                        self.dwellEndTime = Date()
                    }
                    
                    DispatchQueue.main.async {
                        super._select()
                    }
                })
            })
        }else{
            UIView.animate(withDuration: TimeInterval(super.dwellTime), animations: {() -> Void in
                self.isStartTimeUpdated = false // now the start time can be updated next time the cursor enter the button
                //clean up the coordinates cache
                self.TrackedCursorCoords.removeAll()
                
                self.deHoverAnimation()
            }, completion: {(finished: Bool) in
                //add dehovering throttle to force hovering throttle to wait for seconds before execute
                self.throttler?.throttle(eventtype: EventType(-1), block: {
                    DispatchQueue.main.async {
                        super._deselect()
                    }
                })
            })
        }
    }
}
