// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit
import SpriteKit

/**
 This is a user custom view inherent from UIHeadGazeView.
 It renders a virtual cursor/crosshair on top of the screen
 using SpriteKit to indicate where the head is pointing at
 on the device screen.
 Override gazeMoved() to handle the UIHeadGazeEvent, or
 add UIHeadGazeRecognizer to monitor UIHeadGazeEvent
 see usage in ViewController.swift
 */
class UIVirtualCursorView: UIHeadGazeView{
    var spritekitScence: SKScene?
    var cursorNode: SKSpriteNode!
    var circleNode: SKShapeNode!
    var spriteNode: SKNode!
    
    private enum Config{
        static let cursorSize: Int = 40
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeHeadGazeView()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        initializeHeadGazeView()
    }
    
    private func initializeHeadGazeView(){
        let boundSize = self.bounds.size
        self.spritekitScence = SKScene(size: boundSize)
        self.spritekitScence?.scaleMode = .resizeFill
        self.allowsTransparency = true
        self.spritekitScence?.backgroundColor = .clear
        self.presentScene(self.spritekitScence)
        //createCursorIcon(imageNamed: "crosshair")
        createCursor()
    }
    
    func createCursor(){
        if spriteNode != nil { spriteNode.removeFromParent() }
        
        let scale = 1.5
        let ring   = SKShapeNode(ellipseOf: CGSize(width: 6*scale, height: 6*scale))
        ring.position = CGPoint(x: 0, y: 0)
        ring.name = "dot"
        ring.strokeColor = SKColor.cyan
        ring.fillColor = SKColor.white
        
        let circle = SKShapeNode(ellipseOf: CGSize(width: 30*scale, height: 30*scale))
        circle.position = CGPoint(x: 0, y: 0)
        circle.name = "crosshair-circle"
        circle.strokeColor = SKColor.cyan
        circle.glowWidth = 1.0
        circle.fillColor = SKColor.clear
        
        let node = SKNode()
        node.position = CGPoint(x: frame.midX, y: frame.midY)
        node.addChild(ring)
        node.addChild(circle)
        spriteNode = node
        spritekitScence?.addChild(spriteNode)
    }
    
    func createCursorIcon(imageNamed cursorName: String = "crosshair"){
        if spriteNode != nil { spriteNode.removeFromParent() }
        
        let boundSize = self.bounds.size
        cursorNode = SKSpriteNode(imageNamed: cursorName)
        cursorNode.size = CGSize(width: Config.cursorSize, height: Config.cursorSize)
        cursorNode.position = CGPoint(x: boundSize.width/2, y: boundSize.height/2)
        cursorNode.name = cursorName
        spriteNode = cursorNode
        spritekitScence?.addChild(spriteNode)
    }
    
    override func gazeMoved(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?) {
        let gaze = gazes.first
        //print("UIHeadGazeView: gaze NDC position=\(gaze?.location(in: nil))")
        //print("UIHeadGazeView: gaze UIView position=\(gaze?.location(in: self))")
        //print("UIHeadGazeView: gaze SKScene position=\(gaze?.location(in: spritekitScence))")
        spriteNode.position = (gaze?.location(in: spritekitScence!))!
        
        let viewController = self.getParentViewController()
        var yOffset = CGFloat(0)
        if let navBar = viewController?.navigationController?.navigationBar {
            if !navBar.isHidden {
                yOffset = navBar.frame.height * 2
            }
        }
        spriteNode.position.y += yOffset
    }
}

/**
 Helper function to trace the UI hierachy all the way up until it reaches the top view controller
 */
extension UIResponder {
    func getParentViewController() -> UIViewController? {
        if self.next is UIViewController {
            return self.next as? UIViewController
        } else {
            if self.next != nil {
                return (self.next!).getParentViewController()
            }
            else {return nil}
        }
    }
}

extension UIHeadGaze {
    /**
     Returns the current location of the receiver in the coordinate system of the given SKScene.
     Note that the virtual cursor is using the SpriteKit default coordinate system whose origin in the lower left corner of the screen
     */
    func location(in skScene: SKScene) -> CGPoint {
        let boundSize = skScene.frame.size
        let posNDC = self.location(in: nil)
        return CGPoint(x: boundSize.width  * (posNDC.x+0.5),
                       y: boundSize.height * (posNDC.y+0.5))
    }
    
    func previousLocation(in skScene: SKScene) -> CGPoint {
        let boundSize = skScene.frame.size
        let posNDC = self.previousLocation(in: nil)
        return CGPoint(x: boundSize.width  * (posNDC.x+0.5),
                       y: boundSize.height * (posNDC.y+0.5))
    }
    
}
