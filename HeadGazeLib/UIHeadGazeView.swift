// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ARKit

protocol UIHeadGazeViewDelegate : class {
    //Update the calling delegate with new head cursor position
    func update(_ uiHeadGazeView: UIHeadGazeView, didUpdate headGazes: Set<UIHeadGaze>)
}

protocol UIHeadGazeViewDataSource: class {
    //delegate is responsible for returning an instance of the ARFaceAnchor that
    //will be used to calculate the head pointing position projected on the phone screen
    //If no such delegate is specified, the head cursor will not update
    func getARFaceAnchor() -> ARFaceAnchor?
}

protocol UIHeadGazeCallback where Self: UIView{
    var previousGaze: UIHeadGaze? {get set}
    func gazeBegan(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?)
    func gazeMoved(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?)
    func gazeEnded(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?)
    func gazeCancelled(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?)
}

class UIHeadGazeView: SKView, UIHeadGazeCallback{
    var previousGaze: UIHeadGaze? //inherent from UIHeadGazeCallback
    
    weak var delegateHeadGaze: UIHeadGazeViewDelegate?
    weak var dataSourceHeadGaze: UIHeadGazeViewDataSource? //delegate to how to update
    private var headGazeRecognizer: UIHeadGazeRecognizer?
    
    private var previousHeadGazePos = CGPoint(x: 0, y: 0) // HeadGazePos at t-1
    private var twoStepPrevHeadGazePos = CGPoint(x: 0, y: 0) // HeadGazePos at t-2
    
    var moThresholdX = CGFloat(0.01) // Ignore horizontal HeadGaze movement until threshold
    var moThresholdY = CGFloat(0.01) // Ignore vertical HeadGaze movement until threshold
    var moSpeedX = CGFloat(1) // adjust the amount of horizontal HeadGaze movement
    var moSpeedY = CGFloat(1) // adjust the amount of vertical HeadGaze movement
    var xStop = true // HeadGazePos.x did not change at t-1
    var yStop = true // HeadGazePos.y did not change at t-1
    var preXStop = true // HeadGazePos.x did not change at t-2
    var preYStop = true // HeadGazePos.y did not change at t-2
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer?) {
        if let recog = gestureRecognizer as? UIHeadGazeRecognizer{
            headGazeRecognizer = recog
        }else{
            fatalError("recog is not UIHeadGazeRecognizer")
        }
    }
    /**
     Call this method in the ARSession loop to update the gaze location on the screen.
     @param frame: An ARFrame object whose world transformation matrix would be used to derive the gaze location on the screen.
     */
    func update(frame: ARFrame){
        let cursorPosNDC = updateGazeNDCLocationByARFaceAnchor(frame: frame)
        if let window = UIApplication.shared.keyWindow {
            //Generate head gaze event and invoke event callback methods
            var allGazes = Set<UIHeadGaze>()
            var curGaze = UIHeadGaze(type: UIHeadGazeType.glance, position: cursorPosNDC,  view: self, win: window)
            if let lastGaze = previousGaze{
                curGaze = UIHeadGaze(type: UIHeadGazeType.glance, curPosition: cursorPosNDC, prevPosition: lastGaze.location(in: nil),  view: self, win: window)
            }
            //TODO: apply low pass filter on curGaze
            
            allGazes.insert(curGaze)
            previousGaze = curGaze
            
            //TODO: use throttler here to control how frequent we'd like to call event handler/recognizer.
            let event = UIHeadGazeEvent(allGazes: allGazes)
            self.gazeMoved(allGazes, with: event)
            
            headGazeRecognizer?.gazeMoved(allGazes, with: event)
            delegateHeadGaze?.update(self, didUpdate: allGazes)
        }
    }

    public var enableDeviceControl: Bool = false {// whether the device orientation can be used to control the cursor
        didSet{
            if enableDeviceControl{
                reset()
            }
        }
    }
    
    private var frameCount: Int = 0
    private var waitIMUwarmup: Bool = true
    private var initalCameraPitch: Float = 0 // angle (radian) between y-axis and camera lookup vector
    
    func reset(){
        self.frameCount = 0
        self.waitIMUwarmup = true
        self.initalCameraPitch = 0
    }
    
    /**
     return head gaze projection in 2D NDC coordinate system
     where the origin is at the center of the screen
     */
    internal func updateGazeNDCLocationByARFaceAnchor(frame: ARFrame) -> CGPoint{
        let viewMtx = frame.camera.viewMatrix(for: .portrait)
        var rotCamMtx = matrix_float4x4.identity
        if enableDeviceControl {
            rotCamMtx = viewMtx.transpose
            let a = viewMtx[1][1] //viewMtx.columns.1.y
            let b = viewMtx[2][1] //viewMtx.columns.2.y
            if waitIMUwarmup{
                if frameCount < 10 {
                    frameCount += 1 //wait for the IMU to reset
                }else{
                    initalCameraPitch = .pi/2.0 - atan2f(a, b)
                    waitIMUwarmup = false
                }
            }
        }else{
            initalCameraPitch = 0.0
        }
        
        let worldTransMtx = getFaceTransformationMatrix()
        
        let o_headCenter = simd_float4(0,0,0,1)
        let o_headLookAtDir  = simd_float4(0,0,1,0)

        //create rotation matrix to adjust the nose pointing direction about x-axis
        
        let rotMtx = simd_float4x4(SCNMatrix4MakeRotation(Float(10).degreesToRadians-initalCameraPitch, 1, 0, 0))
        
        var tranfMtx = matrix_float4x4.identity
        if !self.enableDeviceControl {
            tranfMtx = viewMtx * worldTransMtx * rotMtx
        }else{
            tranfMtx = worldTransMtx * rotCamMtx * rotMtx
        }
        
        let c_headCenter = tranfMtx * o_headCenter
        var c_lookAtDir  = tranfMtx * o_headLookAtDir
        let t = (0.0 - c_headCenter[2]) / c_lookAtDir[2]
        let hitPos = c_headCenter + c_lookAtDir * t
        
        let hitPosNDC = float2( [Float(hitPos[0]), Float(hitPos[1])] )
        let filteredPos = smoothen(pos: hitPosNDC)
        
        let worldToSKSceneScale = Float(4.0)
        //let hitPosSKScene = hitPos * worldToSKSceneScale
        let hitPosSKScene = filteredPos * worldToSKSceneScale
        return CGPoint(x: CGFloat(hitPosSKScene[0]), y: CGFloat(hitPosSKScene[1]) )
       // return calibratedHeadGaze(hitPosSKScene: hitPosSKScene)
    }
    
    private var cumulativeCount: Int = 0
    private var avgNDCPos2D: float2 = float2([0,0])
    private var previousNDCPos2D: float2 = float2([0,0])
    private var _smoothness : Float = 9.0 // between [0, maxCumulativeCount]
    
    /**
     Determine how many previous gaze locations would be considered to calculate the smoothing function to stablize the cusor.
     The higher the value the more smoothness.
    */
    public let maxCumulativeCount: Int = 10 //increase the value would increase the stableness but also increase the lag
    /**
     Controls the smoothness and stableness of the cursor. The higher the value the more smoothly the cursor moves.
     The value would be clamped to [0, maxCumulativeCount] after assignment.
    */
    public var smoothness: Float {
        get { return _smoothness}
        set {
            _smoothness = max(min(newValue, Float(maxCumulativeCount)), 0)
            cumulativeCount = 0
        }
    }
    
    private func smoothen(pos: float2) -> float2{
        if cumulativeCount <= maxCumulativeCount {
            avgNDCPos2D = (avgNDCPos2D * Float(cumulativeCount) + pos) / Float(cumulativeCount+1)
            cumulativeCount += 1
        }else{
            let maxCount = Float(maxCumulativeCount)
            avgNDCPos2D = ((smoothness) * avgNDCPos2D + (maxCount - smoothness) * pos) / maxCount
            
        }
        previousNDCPos2D = avgNDCPos2D //pos
        return avgNDCPos2D
    }

    
    // Calibrating HeadGaze for smooth pointing
    private func calibratedHeadGaze(hitPosSKScene: float4) -> CGPoint {
        // TODO: scale hard coded values which are only for debugging
        var HeadGaze = CGPoint(x: CGFloat(hitPosSKScene[0]), y: CGFloat(hitPosSKScene[1]))
        
        if HeadGaze.x < -0.43 { HeadGaze.x = -0.43 } // set left edge boundary
        if HeadGaze.x > 0.43 { HeadGaze.x = 0.43 } // set right edge boundary
        if HeadGaze.y < -0.37 { HeadGaze.y = -0.37 } // set bottom edge boundary
        if HeadGaze.y > 0.36 { HeadGaze.y = 0.36 } // set top edge boundary
        
        // if three consecutive HeadGaze.x values are too close, between the range of threshold, don't update  HeadGaze.x
        xStop = abs(HeadGaze.x - twoStepPrevHeadGazePos.x) < moThresholdX && abs(previousHeadGazePos.x - twoStepPrevHeadGazePos.x) < moThresholdX && abs(HeadGaze.x - previousHeadGazePos.x) < moThresholdX
        // if three consecutive HeadGaze.x values are too close, between the range of threshold, don't update  HeadGaze.y
        yStop = abs(HeadGaze.y - twoStepPrevHeadGazePos.y) < moThresholdY && abs(previousHeadGazePos.y - twoStepPrevHeadGazePos.y) < moThresholdY && abs(HeadGaze.y - previousHeadGazePos.y) < moThresholdY
        if  xStop {
            HeadGaze.x = previousHeadGazePos.x // keep HeadGaze.x same
            moThresholdX = CGFloat(0.03) // keep threshold high to avoid shaking
        } else {
            moThresholdX = CGFloat(0.005) // if movement begins, reduce threshold to avoid big jumps
        }
        if yStop {
            HeadGaze.y = previousHeadGazePos.y // same tricks
            moThresholdY = CGFloat(0.03)
        } else {
            moThresholdY = CGFloat(0.005)
        }
        // accelerate HeadGaze's horizontal movement if 3 consecutive HeadGaze linear, otherwise slow down
        if (twoStepPrevHeadGazePos.x > HeadGaze.x && previousHeadGazePos.x > HeadGaze.x && twoStepPrevHeadGazePos.x > previousHeadGazePos.x) ||
            (twoStepPrevHeadGazePos.x < HeadGaze.x && twoStepPrevHeadGazePos.x < previousHeadGazePos.x && previousHeadGazePos.x < HeadGaze.x) {
            if moSpeedX < CGFloat(2) { moSpeedX += 0.1 }
        }
        else {
            if moSpeedX > CGFloat(0.5) { moSpeedX -= 0.1 }
        }
        // accelerate HeadGaze's vertical movement if 3 consecutive HeadGaze linear, otherwise slow down
        if (twoStepPrevHeadGazePos.y > HeadGaze.y && previousHeadGazePos.y > HeadGaze.y && twoStepPrevHeadGazePos.y > previousHeadGazePos.y) ||
            (twoStepPrevHeadGazePos.y < HeadGaze.y && twoStepPrevHeadGazePos.y < previousHeadGazePos.y && previousHeadGazePos.y < HeadGaze.y) {
            if moSpeedY < CGFloat(2) { moSpeedY += 0.1 }
        }
        else {
            if moSpeedY > CGFloat(0.5) { moSpeedY -= 0.1 }
        }
        
        // dim first step to avoid jumps if HeadGaze is waiting, otherwise apply acceleration
        if preXStop {
            HeadGaze.x = previousHeadGazePos.x + (HeadGaze.x - previousHeadGazePos.x) * 0.1
        } else {
            HeadGaze.x = previousHeadGazePos.x + (HeadGaze.x - previousHeadGazePos.x) * moSpeedX
        }
        if preYStop {
            HeadGaze.y = previousHeadGazePos.y + (HeadGaze.y - previousHeadGazePos.y) * 0.1
            
        } else {
            HeadGaze.y = previousHeadGazePos.y + (HeadGaze.y - previousHeadGazePos.y) * moSpeedY
        }
        // update variables
        twoStepPrevHeadGazePos = previousHeadGazePos
        previousHeadGazePos = HeadGaze
        preXStop = xStop
        preYStop = yStop
        return HeadGaze
    }
    
    /**
     Returns the world transformation matrix of the ARFaceAnchor node
     */
    private func getFaceTransformationMatrix() -> simd_float4x4 {
        guard let dataSource = dataSourceHeadGaze else { return simd_float4x4.identity}
        guard let faceAnchor = dataSource.getARFaceAnchor() else { return simd_float4x4.identity }
        return faceAnchor.transform
    }
    
    /**
     Extract the translation components of the ARFaceAnchor node
     */
    func getFaceTranslation() -> simd_float3 {
        let M = getFaceTransformationMatrix()
        return simd_float3([M[3][0], M[3][1], M[3][2]])
    }
    
    /**
     Extract the scale components of the ARFaceAnchor node
    */
    func getFaceScale() -> simd_float3{
        let M = getFaceTransformationMatrix()
        let sx = simd_float3([M[0][0], M[0][1], M[0][2]])
        let sy = simd_float3([M[1][0], M[1][1], M[1][2]])
        let sz = simd_float3([M[2][0], M[2][1], M[2][2]])
        let s = simd_float3([simd_length(sx), simd_length(sy), simd_length(sz)])
        return s //simd_float4x3([sx, sy, sx, s])
    }
    
    /**
     Extract the rotation components of the ARFaceAnchor node
     */
    func getFaceRotationMatrix() -> simd_float4x4 {
        let scale = getFaceScale()
        let mtx = getFaceTransformationMatrix()
        var (c0,c1,c2,c3) = mtx.columns
        c3 = simd_float4(0,0,0,1) //zero out translation components
        c0 = c0 / scale[0]
        c1 = c1 / scale[1]
        c2 = c2 / scale[2]
        return simd_float4x4(c0,c1,c2,c3)
    }
    
    //UIHeadGaze protocol stubs. Expect the subclass of UIHeadGazeView to implement
    func gazeBegan(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?) {
        fatalError("the gazeBegan is never implemented!")
    }
    
    func gazeMoved(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?) {
        fatalError("the gazeMoved is never implemented!")
    }
    
    func gazeEnded(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?) {
        fatalError("the gazeEnd is never implemented!")
    }
    
    func gazeCancelled(_ gazes: Set<UIHeadGaze>, with event: UIHeadGazeEvent?) {
        fatalError("the gazeCancelled is never implemented!")
    }
    
}
