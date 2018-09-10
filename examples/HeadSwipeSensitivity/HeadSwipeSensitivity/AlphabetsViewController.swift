// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class AlphabetsViewController: BaseSequenceViewController {
/*
    @IBOutlet weak var instructions : UILabel!
    @IBOutlet weak var keyboard     : UIView!
    @IBOutlet weak var nextPage     : UIButton!
*/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        rootView          = self.view
        sequence          = "ABCDEFGHIJKLMNO"
        instructions.text = "Select buttons alphabetically"
        super.initializeHeadGazeRecognizer(tagOffset: 10, numkeys: 15)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.data.clearData(testID: 1)
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
    
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
    
    override func sequenceCompleted(data: DataSequence) {
        AppDelegate.data.traverse[modeCurrent] = data
        super.sequenceCompleted(data: data)
    }
}

