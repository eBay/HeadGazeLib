// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit
    
protocol KeyboardSequenceDelegate  {
    func correctKeyPressed(_ tag: Int)
    func sequenceCompleted(data: DataSequence)
}

class KeyboardSequence: NSObject {
    
    @IBOutlet weak var sequenceLabel : UILabel?
    
    var delegate : KeyboardSequenceDelegate?
    
    let rootView : UIView?
    let view     : UIView
    let sequence : String
    let numKeys  : Int

    private var hits     = Int(0)
    private var maxHits  = Int(0)
    private var nextTag  = Int(0)
    private var offset   = Int(10) // Offset in tag to map button content from their tags
    
    private var char2tag    : [String : Int] = [:]
    private var tagSequence : [Int] = []
    
    var start    : Date?
    var samples : [Sample] = []

    // Goal is to select buttons from the keyboard in the order as defined in a given sequence.
    // Incorect characters are skipped.
    // If sequenceLabel is provided, the characters change color in the sequenceLabel, as they are typed
    init(rootView: UIView?=nil, view: UIView, numKeys: Int, sequence: String = "", sequenceLabel : UILabel? = nil, offset: Int = 10) {
        self.rootView      = rootView
        self.view          = view
        self.numKeys       = numKeys
        self.sequence      = sequence
        self.sequenceLabel = sequenceLabel
        
        super.init()
        
        // Do any additional setup.
        for tag in offset..<offset+numKeys {
            setupButton(tag)
        }
        self.offset = offset
        maxHits     = sequence.count
        if maxHits < 1 {
            maxHits = 1000
        }
        createTagSequence()
        
        // Highlight the first button.
        if tagSequence.count>0 {
            self.nextTag = tagSequence[hits]
            highlightButton(self.nextTag)
            grayButton()
            
            updateSequenceLabel()
        }
    }

    //**********************************************************************************************
    // Callbacks
    //**********************************************************************************************
    
    // Triggered on Touch down event inside up button
    @IBAction func buttonSelected(_ button: UITrackButton) {
        print("\(button.currentTitle!)")
        print("***** tracked coordinates: \(button.TrackedCursorCoords.count) samples vs ideal count \(button.maxNumSamples) ******")
        print("start time:\(button.dwellStartTime)")
        print(button.TrackedCursorCoords)
        print("end time:\(button.dwellEndTime)")
        print("********************************")
        
        if isSequenceComplete(button) {
            self.delegate?.sequenceCompleted(data: DataSequence(sequence: sequence, samples: samples))
        }
    }

    //**********************************************************************************************
    // Public methods
    //**********************************************************************************************
    
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
    
    private func createTagSequence() {
        for char in sequence {
            if let tag = char2tag[String(char)] {
                tagSequence.append(tag)
            }
            else {
                print("Warning: \(char) not found in keyboard. Will use default")
                tagSequence.append(offset+1) // Use the first button (accordign to tag) as default
            }
        }
    }
    
    private func highlightButton(_ tag: Int, backgroundColor: UIColor = #colorLiteral(red: 1.0, green: 0.35, blue: 0.1, alpha: 1.0)) {
        if let button = self.view.viewWithTag(tag) as? UITrackButton {
            button.backgroundColor = backgroundColor
        }
    }
    
    private func grayButton(backgroundColor: UIColor = #colorLiteral(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)) {
        if hits+1<tagSequence.count {
            let tag = tagSequence[hits+1]
            highlightButton(tag, backgroundColor: backgroundColor)
        }
    }

    
    private func isSequenceComplete(_ button : UITrackButton) -> Bool {
        var done = false
        if tagSequence.count<1 {
            button.backgroundColor = #colorLiteral(red: 0.51, green: 0.75, blue: 0.15, alpha: 1.0)
            return done
        }
        
        if (button.tag == nextTag) {
            if hits == 0 {
                start = Date()
            }
            let currentFrame = button.convert(button.bounds, to: rootView)
            
            samples.append(Sample(dwellDuration: button.dwellDuration, dwellStartTime: button.dwellStartTime, dwellEndTime: button.dwellEndTime, dwellLocations: button.TrackedCursorCoords, elapsed: -(start?.timeIntervalSinceNow)!, frame: currentFrame))
            
            samples[hits].elapsed -= samples[0].elapsed - Double(button.dwellDuration) // Get elapsed time w.r.t. to the first activation in the sequence
            if samples[hits].elapsed<0 {
                samples[hits].elapsed = 0 // Just in case. This should not happen when hits>0
            }
            self.delegate?.correctKeyPressed(button.tag)
            
            hits  += 1
            button.backgroundColor  = #colorLiteral(red: 0.51, green: 0.75, blue: 0.15, alpha: 1.0)
            updateSequenceLabel()

            done = updateNext()
            if !done {
                highlightButton(nextTag)
                grayButton()
            }
        }
        return done
    }
    
    private func setupButton(_ tag: Int) {
        if let button = self.view.viewWithTag(tag) as? UITrackButton {
            button.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
            button.setTitleColor(.white, for: .normal)
            
            char2tag[button.currentTitle!] = tag
            button.maxNumSamples       = 20
            button.backgroundColor     = #colorLiteral(red: 0.51, green: 0.75, blue: 0.15, alpha: 1.0)
            button.layer.cornerRadius  = button.frame.height / 2
            button.layer.masksToBounds = true
            button.layer.borderWidth   = 5
            button.layer.borderColor   = UIColor.white.cgColor
        }
    }

    private func updateNext() -> Bool {
        var done = true
        if hits < maxHits {
            done    = false
            nextTag = tagSequence[hits]
        }
        return done
    }
    
    private func updateSequenceLabel() {
        if hits>maxHits {
            return
        }
        
        let contentsAtrr = NSMutableAttributedString(string: sequence)
        contentsAtrr.removeAttribute(NSAttributedStringKey.foregroundColor, range: NSMakeRange(0, maxHits))

        if hits>0 {
            contentsAtrr.addAttribute(NSAttributedStringKey.foregroundColor, value: #colorLiteral(red: 0.51, green: 0.75, blue: 0.15, alpha: 1.0), range: NSMakeRange(0, hits))
        }
        
        if hits<maxHits {
            contentsAtrr.addAttribute(NSAttributedStringKey.foregroundColor,    value: #colorLiteral(red: 1.0, green: 0.35, blue: 0.1, alpha: 1.0), range: NSMakeRange(hits, 1))
        }

        sequenceLabel?.attributedText = contentsAtrr
    }
    
}
