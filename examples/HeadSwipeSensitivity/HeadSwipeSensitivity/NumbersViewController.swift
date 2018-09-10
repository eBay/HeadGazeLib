// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class NumbersViewController: BaseSequenceViewController {
/*
    @IBOutlet weak var keyboard     : UIView!
    @IBOutlet weak var instructions : UILabel!
    @IBOutlet weak var reference    : UILabel!
    @IBOutlet weak var nextPage     : UIButton!
*/

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rootView          = self.view
        sequence          = "12345678901928376405"
        instructions.text = "Select buttons in the desired sequence below"
        nextPageTitle     = "Go to Test 2"
        //
        super.initializeHeadGazeRecognizer(tagOffset: 10, numkeys: 10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.data.clearData(testID: 0)
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
        keyboardSequence = KeyboardSequence(view: keyboard, numKeys: 15, sequence: sequence, sequenceLabel: reference)
        keyboardSequence?.delegate = self
    }
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************

    override func sequenceCompleted(data: DataSequence) {
        AppDelegate.data.numbers[modeCurrent] = data
        super.sequenceCompleted(data: data)
    }
}
