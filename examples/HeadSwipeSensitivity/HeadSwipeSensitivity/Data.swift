// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit


enum ModeDistance: Int {
    case Near      = 0
    case Mid       = 1
    case Far       = 2
    
    static var count: Int { return ModeDistance.Far.rawValue + 1}
}


func nameModeDistance(_ mode: ModeDistance) -> String {
    var name = ""
    switch mode {
        case .Near:
            name = "Near"
            break
        
        case .Mid:
            name = "Mid"
            break
        
        case .Far:
            name = "Far"
            break
    }
    return name
}


struct FittsLaw {
    let amplitude         : Double
    let width             : Double
    let indexOfDifficulty : Double
    let throughput        : Double
    let elapsed           : Double
    
    init(frame1: CGRect = CGRect.zero, frame2: CGRect = CGRect.zero, elapsed: Double = -1) {
        // Use geometric mean as effective radius
        let r1 = sqrt(frame1.size.height * frame1.size.width)
        let r2 = sqrt(frame2.size.height * frame2.size.width)
        width = Double(r1 + r2) / 2
        
        let dx = (frame1.origin.x + frame1.size.width/2)  - (frame2.origin.x + frame2.size.width/2)
        let dy = (frame1.origin.y + frame1.size.height/2) - (frame2.origin.y + frame2.size.height/2)
        amplitude = sqrt(Double(dx*dx + dy*dy))
        
        self.elapsed      = elapsed
        
        // Note: The following formula will be modified during offline analysis.
        indexOfDifficulty = width>0 ? log2(amplitude/width + 1) : -1
        throughput        = indexOfDifficulty>=0 ? indexOfDifficulty / elapsed : -1
    }
}


struct Sample {
    let dwellDuration  : Float
    let dwellStartTime : Date
    let dwellEndTime   : Date
    var dwellX         : [Float]
    var dwellY         : [Float]
    var elapsed        : TimeInterval
    let frame          : CGRect
    var fitts          = FittsLaw()
    
    init(dwellDuration: Float, dwellStartTime: Date, dwellEndTime: Date, dwellLocations: [CGPoint], elapsed: TimeInterval, frame: CGRect) {
        self.dwellDuration  = dwellDuration
        self.dwellStartTime = dwellStartTime
        self.dwellEndTime   = dwellEndTime
        self.elapsed        = elapsed
        self.frame          = frame
        
        self.dwellX = []
        self.dwellY = []
        for location in dwellLocations {
            self.dwellX.append(Float(location.x))
            self.dwellY.append(Float(location.y))
        }
    }
}


struct DataSequence {
    let sequence : String
    var samples  : [Sample]
    
    init(sequence: String, samples: [Sample]) {
        self.sequence = sequence
        self.samples  = samples
        calculateFitts()
    }
    
    private mutating func calculateFitts() {
        for j in 1..<samples.count {
            samples[j].fitts =  FittsLaw(frame1  : samples[j-1].frame,
                                         frame2  : samples[j].frame,
                                         elapsed : samples[j].elapsed - samples[j-1].elapsed)
        }
    }
}


class Data: NSObject {

    var numbers : [ModeDistance : DataSequence?] = [ModeDistance.Near : nil,
                                                    ModeDistance.Mid  : nil,
                                                    ModeDistance.Far  : nil]

    var traverse : [ModeDistance : DataSequence?] = [ModeDistance.Near : nil,
                                                     ModeDistance.Mid  : nil,
                                                     ModeDistance.Far  : nil]
    
    
    //**********************************************************************************************
    // Public methods
    //**********************************************************************************************

    func clearData(testID : Int) {
        if testID == 0 {
            numbers = [ModeDistance.Near : nil,
                       ModeDistance.Mid  : nil,
                       ModeDistance.Far  : nil]
        }
        else {
            traverse = [ModeDistance.Near : nil,
                        ModeDistance.Mid  : nil,
                        ModeDistance.Far  : nil]
        }
    }
    
    
    func calculateAverageThroughputForMode(testID: Int, mode: ModeDistance) -> Double {
        var average : Double = 0
        let dict = (testID == 0) ? self.numbers : self.traverse
        
        if let data = dict[mode] as? DataSequence {
            let n = data.samples.count
            
            // Need to ignore the first element
            for i in 1..<n {
                average += data.samples[i].fitts.throughput
            }
            if n>1 {
                average /= Double(n-1)
            }
        }

        return average
    }
    
    
    func saveData() -> Bool {
        var success  = true
        let paths    = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let rootDir  = paths[0]
        let filename = rootDir.appendingPathComponent("\(UUID().uuidString).json")
        
        print(filename)
        
        if let data = try?  JSONSerialization.data(
            withJSONObject: prepareDictSummaryAllModes(),
            options: .prettyPrinted
            ),
            let str = String(data: data, encoding: String.Encoding.ascii) {
            print("\(str)")
            
            do {
                try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            }
            catch let error as NSError {
                success = false
                print("Failed to save summary: \(error.localizedDescription)")
            }
        }
        else {
            success = false
        }
        
        return success
    }
    
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
    
    private func prepareDictSummaryAllModes() -> [String: [Any]] {
        var array : [[String:Any]] = []
        array.append(["Numbers":   prepareDictSummarySingleTest(testID: 0)])
        array.append(["Alphabets": prepareDictSummarySingleTest(testID: 1)])

        return ["results": array]
    }
    
    
    private func prepareDictSummarySingleTest(testID : Int) -> NSMutableDictionary {
        let summary : NSMutableDictionary = [:]
        let dict = (testID == 0) ? self.numbers : self.traverse
        
        for i in 0..<ModeDistance.count {
            let mode = ModeDistance(rawValue: i)!
            let name = nameModeDistance(mode)
            
            if let data = dict[mode] as? DataSequence {
                var array   : [[String: Any]] = []
                
                for sample in data.samples {
                    let h = sample.frame.size.height
                    let w = sample.frame.size.width
                    var x : [NSNumber] = []
                    var y : [NSNumber] = []
                    for i in 0 ..< sample.dwellX.count {
                        x.append(NSNumber(value: sample.dwellX[i]))
                        y.append(NSNumber(value: sample.dwellY[i]))
                    }
                    let current : [String : Any] = [
                        "elapsed"  : NSNumber(value: Float(sample.fitts.elapsed)),
                        "center_x" : NSNumber(value: Float(sample.frame.origin.x+w/2)),
                        "center_y" : NSNumber(value: Float(sample.frame.origin.y+h/2)),
                        "width"    : NSNumber(value: Float(w)),
                        "height"   : NSNumber(value: Float(h)),
                        "fitts_A"  : NSNumber(value: Float(sample.fitts.amplitude)),
                        "fitts_W"  : NSNumber(value: Float(sample.fitts.width)),
                        "fitts_ID" : NSNumber(value: Float(sample.fitts.indexOfDifficulty)),
                        "fitts_Throughput": NSNumber(value: Float(sample.fitts.throughput)),
                        "dwell_duration":   NSNumber(value: Float(sample.dwellDuration)),
                        "dwell_x": x,
                        "dwell_y": y
                        ]
                    array.append(current)
                    
                }
                summary[name] = array
            }
            else {
                //summary[name] = []
                continue
            }
        }
        return summary
    }
}
