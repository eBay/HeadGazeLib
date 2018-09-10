// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit
import ARKit

/**
 A ViewController that capture the updates of ARFaceAnchor and serve as delegate for
 UIHeadGazeView to query face anchor and update virtual cursor on the screen accordingly.
 */
class UIHeadGazeViewControllerBase: UIViewController, ARSCNViewDelegate, UIHeadGazeViewDataSource{
    
    func getARFaceAnchor() -> ARFaceAnchor? {
        return self.faceAnchor
    }

    private var faceAnchor: ARFaceAnchor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    /// - Tag: ARNodeTracking
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    }
    
    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        self.faceAnchor = faceAnchor
    }
    
}

