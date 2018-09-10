// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class UIBubbleButton: UIHoverableButton {
    
    internal var darkFillView: UIView? = nil
    internal var button: UIButton? = nil

    /**
     Property function to set and get the background color for the button animation
     */
    public var darkFillColor: UIColor {
        get { return (darkFillView?.backgroundColor)! }
        set { darkFillView?.backgroundColor = newValue }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI(frame: self.frame)
    }
    
    internal func setupUI(frame: CGRect) {
        //add dark fill
        let w = frame.width
        let h = frame.height
        self.clipsToBounds = true
        super.outAlpha = 0.1 //alpha of the button when it's been hovered over
        self.hoverScale = Float(max(w, h))

        self.layer.cornerRadius = min(w,h) / 5.0
        self.setTitleColor(UIColor.black, for: .normal)
        self.backgroundColor = UIColor.white
        self.alpha = 1.0
        
        let dummyFrame = CGRect(x: w/2, y: h/2, width: 1, height: 1)
        darkFillView = UIView(frame: dummyFrame)
        darkFillView?.backgroundColor = eBayColors.blue
        darkFillView?.layer.cornerRadius = 0.5
        addSubview(darkFillView!)
    }

    /**
     Overridable. Define the animation when cursor is hovering over the button
     */
    override func hoverAnimation() {
        self.darkFillView!.alpha = self.inAlpha
        self.darkFillView!.transform = CGAffineTransform(scaleX: CGFloat(hoverScale), y: CGFloat(hoverScale) )
    }
    
    /**
     Overridable. Define the animation when cursor leave the button
     */
    override func deHoverAnimation() {
        self.darkFillView!.alpha = self.outAlpha
        self.darkFillView!.transform = .identity
    }
}
