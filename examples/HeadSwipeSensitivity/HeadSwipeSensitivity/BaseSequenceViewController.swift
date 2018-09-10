// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class BaseSequenceViewController: UIHeadGazeViewController, KeyboardSequenceDelegate {
    
    // Note:
    // When deriving from this base class, please connect the variables to storyboard and then comment out in the derived class
    
    @IBOutlet weak var keyboard     : UIView!
    @IBOutlet weak var instructions : UILabel!
    @IBOutlet weak var reference    : UILabel!
    @IBOutlet weak var nextPage     : UIButton!

    var headGazeRecognizer: UIHeadGazeRecognizer? = nil
    
    var rootView : UIView? = nil
    var sequence           = ""
    var instructionsMsg    = "Select buttons"
    var nextPageTitle      = "Done!"
    
    var keyboardSequence : KeyboardSequence?
    var modes            : [ModeDistance] = [.Near, .Mid, .Far] //[.Near]//
    var modeCurrent      = ModeDistance.Near
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if instructions != nil {
            instructions.text = instructionsMsg
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initializeKeyboard()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //**********************************************************************************************
    // Callbacks
    //**********************************************************************************************
    
    //**********************************************************************************************
    // Public methods
    //**********************************************************************************************
    
    func initializeKeyboard() {
        keyboard.isUserInteractionEnabled = true
        keyboard.alpha                    = CGFloat(1.0)
        
        keyboardSequence = KeyboardSequence(view: keyboard, numKeys: 15, sequence: sequence, sequenceLabel: nil, offset: 10)
        keyboardSequence?.delegate = self
        
        setupNextPageButton()
    }
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
    
    private func setupNextPageButton() {
        nextPage.layer.cornerRadius  = nextPage.frame.height / 3
        nextPage.layer.masksToBounds = true
        nextPage.backgroundColor     = UIColor(red: 0.0, green: 0.43, blue: 0.99, alpha: 1.0)
        nextPage.setTitleColor(.white, for: .normal)
        
        nextPage.isEnabled = false
        nextPage.alpha     = CGFloat(0.5)
        
        if let nextPage = nextPage as? UIBubbleButton {
            nextPage.darkFillColor = eBayColors.green
        }
        
        switch modeCurrent {
            case .Near:
                nextPage.setTitle("Near", for: .normal)
                break
            
            case .Mid:
                nextPage.setTitle("Mid", for: .normal)
                break
            
            case .Far:
                nextPage.setTitle("Far", for: .normal)
                break
        }
    }
    
    
    //**********************************************************************************************
    // Delegates of KeyboardSequenceDelegate
    //**********************************************************************************************

    func correctKeyPressed(_ tag: Int) {
        print("Hit!")
    }
    
    func sequenceCompleted(data: DataSequence) {
        print("Done!")
        
        if modeCurrent == modes.last {
            keyboard.isUserInteractionEnabled = false
            keyboard.alpha     = CGFloat(0.5)
            nextPage.isEnabled = true
            nextPage.alpha     = CGFloat(1.0)
            nextPage.setTitle(nextPageTitle, for: .normal)
        }
        else {
            modeCurrent = ModeDistance(rawValue: modeCurrent.rawValue+1)!
            initializeKeyboard()
        }

    }
    
    func initializeHeadGazeRecognizer(tagOffset offset: Int, numkeys numKeys: Int){
        if self.headGazeRecognizer == nil {
            self.nextPage.backgroundColor = eBayColors.green
            //MARK: Usage of UIHeadGazeRecognizer
            //add head gesture recognizer to handle head gaze event
            //e.g. how the UI interface respond to the gaze movement, intersection test, etc.
            self.headGazeRecognizer = UIHeadGazeRecognizer()
            super.virtualCursorView?.addGestureRecognizer(self.headGazeRecognizer)
            super.virtualCursorView?.smoothness = 1//no stablization //9//with stablization
            
            // An example showing how to change the per-button dwell time
            if let nextPage = self.nextPage as? UITrackButton{
                nextPage.dwellDuration = 1.0
            }
            
            // tweak the hoverScale so that the dark fill of the round button is in sync
            // with the dwell time.
            for tag in offset..<offset+numKeys{
                if let button = self.view.viewWithTag(tag) as? UITrackButton {
                    button.hoverScale *= 0.9
                }
            }
            // Call back function triggered whenever the cursor position updates.
            self.headGazeRecognizer?.move = { [weak self] gaze in
                for tag in offset..<offset+numKeys{
                    if let button = self?.view.viewWithTag(tag) as? UITrackButton {
                        self?.buttonAction(button: button, gaze: gaze)
                    }
                }
                self?.buttonAction(button: (self?.nextPage)!, gaze: gaze)
            }
        }
    }
    
   func buttonAction(button: UIButton, gaze: UIHeadGaze){
        guard let button = button as? UITrackButton else { return }
        let viewCtr = getParentViewController()
        button.hover(gaze: gaze, in: viewCtr?.view)
    }
}

