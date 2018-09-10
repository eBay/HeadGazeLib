// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

class UIHeadGazeRecognizer: UIGestureRecognizer{
    
    var move: ((UIHeadGaze) -> Void)?
    
    func gazeMoved(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?) {
        state = .changed
        move?(gazes.first!)
    }
    
    /*
     var began: ((UIHeadGaze) -> Void)?
     var ended: (() -> Void)?
     
    func gazeBegan(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?) {
        state = .began
        began?(gazes.first!)
    }
    
    func gazeEnded(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?) {
        state = .ended
        ended?()
    }
    */
}
