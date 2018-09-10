// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit

enum UIHeadGazeType: Int {
    case glance //look in short time
    case gaze //TODO: watch for a longer time based on a threshold e.g. 2 secs
}

class UIHeadGaze: UITouch{
    private weak var _window: UIWindow?
    private let _receiver: UIView
    private let _type: UIHeadGazeType
    private let _position: CGPoint //NDC coordinates [0,1] x [0,1], origin is lower left corner of the screen
    private let _previousPosition: CGPoint //NDC coordinates [0,1] x [0,1], origin is lower left corner of the screen
    /**
     The time when the event occurred
     */
    private var _timestamp: TimeInterval
    
    /**
     Returns the time when the event occurred
     */
    public var timeStamp: TimeInterval{
        return _timestamp
    }
    
    /**
     Returns the type of the event.
     */
    public var evenType: UIHeadGazeType{
        return _type
    }
    
    override public var description: String {
            return """
        UIHeadGazeEvent: type: \(_type), position in NDC: \(_position), previous position in NDC \(_previousPosition), receiver: \(_receiver), window: \(_window)
        """
    }
    
    convenience init(type: UIHeadGazeType, position: CGPoint, view uiview: UIView, win window: UIWindow? = nil){
        self.init(type: type, curPosition: position, prevPosition: position, view: uiview, win: window)
    }
    
    init(type: UIHeadGazeType, curPosition: CGPoint, prevPosition: CGPoint, view uiview: UIView, win window: UIWindow? = nil){
        self._type = type
        self._window = window
        self._receiver = uiview
        self._position = curPosition
        self._previousPosition = prevPosition
        self._timestamp = Date().timeIntervalSince1970
    }
    
    /**
     @Returns: 1. Position of gaze projected on the screen measured in the coordinates of given view
              2. or position in NDC coordinates if view is nil
    */
    override func location(in view: UIView?) -> CGPoint {
        if let v = view {
            // The origin of the coordinates system of both UIWindow and UIView is in the upper left corner and y-axis points downwards
            guard let window = UIApplication.shared.keyWindow else {fatalError("UIApplication.shared.keyWindow is nil!")}
            let winPos = CGPoint(x: (self._position.x+0.5) * window.frame.width, y: (1.0-(self._position.y+0.5)) * window.frame.height)
            let viewPos = v.convert(winPos, from: window)
            return viewPos
        }else{
            return self._position//_receiver.convert(_position, to: view)
        }
    }
    
    /**
     @Returns: 1. Previous position of gaze projected on the screen measured in the coordinates of given view
               2. or position in NDC coordinates if view is nil
     */
    override func previousLocation(in view: UIView?) -> CGPoint {
        if let v = view {
            guard let window = UIApplication.shared.keyWindow else {fatalError("UIApplication.shared.keyWindow is nil!")}
            let winPos = CGPoint(x: (self._previousPosition.x+0.5) * window.frame.width, y: (1.0-(self._previousPosition.y+0.5)) * window.frame.height)
            let viewPos = v.convert(winPos, from: window)
            return viewPos
        }else{
            return self._previousPosition
        }
    }
}

class  UIHeadGazeEvent: UIEvent{
    public var allGazes: Set<UIHeadGaze>?
    /**
     The time when the event occurred
     */
    private var _timestamp: TimeInterval
    
    /**
     Returns the time when the event occurred
     */
    public var timeStamp: TimeInterval{
        return _timestamp
    }
    
    init(allGazes: Set<UIHeadGaze>? = nil) {
        self.allGazes = allGazes
        self._timestamp = Date().timeIntervalSince1970
    }
}
