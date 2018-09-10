// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class PracticeViewController: BaseSequenceViewController {
/*
     @IBOutlet weak var keyboard     : UIView!
     @IBOutlet weak var nextPage     : UIButton!
*/
    @IBOutlet weak var topView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        modes = [.Mid] // Pick any one of the modes
        
        super.initializeHeadGazeRecognizer(tagOffset: 10, numkeys: 5)
        
        //Example showing how to setup the different per-button sampling rates of the cursor location during hovering.
        let offset = 10, numKeys = 5
        for tag in offset..<offset+numKeys{
            if let button = self.view.viewWithTag(tag) as? UITrackButton {
                button.maxNumSamples = tag
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextPage.isHidden = false
        
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
    override func initializeKeyboard() {
        super.initializeKeyboard()
        keyboardSequence = KeyboardSequence(view: keyboard, numKeys: 5)
        keyboardSequence?.delegate = self
        nextPage.isEnabled = true
        nextPage.alpha     = CGFloat(1.0)
        nextPage.setTitle("Go to Test 1", for: .normal)
    }
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
}
