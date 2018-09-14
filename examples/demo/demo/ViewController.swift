// Copyright 2018 eBay Inc.
// Created by Xie,Jinrong on 9/12/18.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit
import SceneKit
import ARKit

class ViewController: UIHeadGazeViewController{

    @IBOutlet weak var uiview: UIView!
    @IBOutlet weak var bubbleButton: UIBubbleButton!
    @IBOutlet weak var hoverButton: UIHoverableButton!
    @IBOutlet weak var longGazeButton: UIMultiFuncButton!
    
    @IBOutlet weak var headCtrSwitch: UISwitch!
    @IBOutlet weak var deviceCtrSwitch: UISwitch!
    @IBOutlet weak var headCtrLabel: UILabel!
    @IBOutlet weak var deviceCtrLabel: UILabel!
    @IBOutlet weak var xyLabel: UILabel!
    
    @IBAction func switchDeviceControl(_ sender: UISwitch) {
        super.virtualCursorView?.enableDeviceControl = sender.isOn
    }
    
    @IBAction func switchHeadControl(_ sender: UISwitch) {
        self.uiview.removeFromSuperview()
        self.deviceCtrSwitch.removeFromSuperview()
        self.headCtrSwitch.removeFromSuperview()
        super.virtualCursorView?.removeFromSuperview()
        if sender.isOn {
            // super.sceneview?.isHidden = false
            self.headCtrLabel.text = "HeadSwipe: on"
            super.view.addSubview(self.uiview)
            self.view.addSubview(super.virtualCursorView!)
            self.view.addSubview(self.deviceCtrSwitch)
            self.view.addSubview(self.headCtrSwitch)
        }else{
            // super.sceneview?.isHidden = true
            self.headCtrLabel.text = "HeadSwipe: off"
            super.view.addSubview(self.uiview)
            self.view.addSubview(self.deviceCtrSwitch)
            self.view.addSubview(self.headCtrSwitch)
        }
    }
    
    //--
    @IBAction func bubbleBtnTouchDown(_ sender: UIBubbleButton) {
        bubbleButton.setTitle("FingerTouched", for: .normal)
    }
    
    @IBAction func bubbleBtnTouchUpInside(_ sender: UIBubbleButton) {
        if headCtrSwitch.isOn{// touch up by head gaze is interpreted as button click
            print("bubble button clicked")
            bubbleButton.setTitle("clicked", for: .normal)
        }else{// touch triggered by finger
            bubbleButton.setTitle("Bubble Button", for: .normal)
        }
    }
    
    @IBAction func bubbleBtnTouchOutside(_ sender: UIBubbleButton) {
        bubbleButton.setTitle("Bubble Button", for: .normal)
    }
    
    //----
    @IBAction func hoverBtnTouchDown(_ sender: UIHoverableButton) {
        hoverButton.setTitle("FingerTouched", for: .normal)
    }
    
    @IBAction func hoverBtnTouchUpInside(_ sender: UIHoverableButton) {
        if headCtrSwitch.isOn{// touch up by head gaze is interpreted as button click
            print("bubble button clicked")
            hoverButton.setTitle("clicked", for: .normal)
        }else{// touch triggered by finger
            hoverButton.setTitle("Hoverable Button", for: .normal)
        }
    }
    
    @IBAction func hoverBtnTouchOutside(_ sender: UIHoverableButton) {
        hoverButton.setTitle("Hoverable Button", for: .normal)
    }
    
    private var clickCount: Int = 0
    @IBAction func longGazeBtnTouchDown(_ sender: UIMultiFuncButton) {
        longGazeButton.setTitle("FingerTouched", for: .normal)
    }
    
    @IBAction func longGazeBtnTouchDownRepeat(_ sender: UIMultiFuncButton) {
        clickCount += 1
        let title = String.init(format: "click count:%d", clickCount)
        longGazeButton.setTitle(title, for: .normal)
    }
    
    @IBAction func longGazeBtnTouchUpInside(_ sender: UIMultiFuncButton) {
        if headCtrSwitch.isOn{// touch up by head gaze is interpreted as button click
            print("long gaze button clicked")
            clickCount += 1
            let title = String.init(format: "click count:%d", clickCount)
            longGazeButton.setTitle(title, for: .normal)
        }else{// touch triggered by finger
            longGazeButton.setTitle("Long Gaze Button", for: .normal)
        }
    }
    
    @IBAction func longGazeBtnTouchUpOutside(_ sender: UIMultiFuncButton) {
        clickCount = 0
        longGazeButton.setTitle("Long Gaze Button", for: .normal)
    }
    
    //--
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.sceneview?.isHidden = false
        bubbleButton.backgroundColor = eBayColors.green
        bubbleButton.dwellDuration = 1 // in second
        hoverButton.dwellDuration = 1
        longGazeButton.dwellDuration = 1
        longGazeButton.longDwellDuration = 2
        
        //add head gesture recognizer to handle head gaze event
        //e.g. how the UI interface respond to the gaze movement, intersection test, etc.
        let headGazeRecognizer = UIHeadGazeRecognizer()
        super.virtualCursorView?.addGestureRecognizer(headGazeRecognizer)
        headGazeRecognizer.move = { [weak self] gaze in
            self?.buttonAction(gaze: gaze)
        }
        
        makecircularWithShadow(button: bubbleButton, name: "Bubble Button")
        makecircularWithShadow(button: hoverButton, name: "Hoverable Button", masksToBounds: false)
        makecircularWithShadow(button: longGazeButton, name: "Long Gaze Button")
        
        blockFingerTouch(toggle: true, asMirror: true)
        
        setupSceneNode()
        
        deviceCtrSwitch.isHidden = true // set it to false if you want to experiment with device control e.g. tilt the device to change the cursor position
        deviceCtrLabel.isHidden = true  // set it to false if you want to experiment with device control e.g. tilt the device to change the cursor position
    }
    
    private func makecircularWithShadow(button: UIButton, name: String="untitled", masksToBounds: Bool = true) {
        button.layer.cornerRadius  = button.frame.height / 2
        button.layer.masksToBounds = masksToBounds
        button.layer.shadowColor   = UIColor.black.cgColor
        button.layer.shadowOffset  = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius  = 1.0
        button.layer.shadowOpacity = 0.5
        
        guard let button = button as? UIHoverableButton else { return }
        button.name = name
    }
    
    private func buttonAction(gaze: UIHeadGaze){
        if headCtrSwitch.isOn {
            self.bubbleButton.hover(gaze: gaze)
            self.hoverButton.hover(gaze: gaze)
            self.longGazeButton.hover(gaze: gaze)
            let localCursorPos = gaze.location(in: self.uiview)
            self.xyLabel.text = String.init(format: "(%.2f, %.2f)", localCursorPos.x, localCursorPos.y)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    /**
     @params toggle: true: enable head tracking and disable finger touch by overlaying virtual cursor view on top of uiview.
                     false: enable both
     @params asMirror: display face on the screen (true) or not (false)
     */
    private func blockFingerTouch(toggle enableHeadCtr: Bool, asMirror showFace: Bool = true){
        
        super.sceneview?.isHidden = !showFace
        self.uiview.removeFromSuperview()
        self.deviceCtrSwitch.removeFromSuperview()
        self.headCtrSwitch.removeFromSuperview()
        super.virtualCursorView?.removeFromSuperview()
        
        //change the z-order of the UI widgets
        if enableHeadCtr {
            super.view.addSubview(self.uiview)
            self.view.addSubview(super.virtualCursorView!)
            self.view.addSubview(self.deviceCtrSwitch)
            self.view.addSubview(self.headCtrSwitch)
        }else{
            self.view.addSubview(super.virtualCursorView!)
            super.view.addSubview(self.uiview)
            self.view.addSubview(self.deviceCtrSwitch)
            self.view.addSubview(self.headCtrSwitch)
        }
    }
    
    private var headNode: SCNNode?
    private var headAnchor: ARFaceAnchor?
    
    private let axesNode = loadModelFromAsset(named: "axes")
    
    private func setupSceneNode(){
        guard let node = headNode else { return }
        
        node.addChildNode(axesNode)
    }
    // MARK: - ARSCNViewDelegate

    /// - Tag: ARNodeTracking
    override func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        self.headNode = node
        setupSceneNode()
    }
    
    /// - Tag: ARFaceGeometryUpdate
    override func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        super.renderer(renderer, didUpdate: node, for: anchor)
//        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
    }

}

func loadModelFromAsset(named assetName: String) -> SCNNode{
    let url = Bundle.main.url(forResource: assetName, withExtension: "scn", subdirectory: "art.scnassets")
    let node = SCNReferenceNode(url: url!)
    node?.load()
    return node!
}
