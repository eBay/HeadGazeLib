// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class SummaryViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        populate(testID: 0, dict: AppDelegate.data.numbers)
        populate(testID: 1, dict: AppDelegate.data.traverse)
        
        setupSaveButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        saveButton.isEnabled = true
        saveButton.alpha     = CGFloat(1.0)
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
    
    // Triggered on Touch down event inside up button
    @IBAction func saveData(_ button: UIButton) {
        print("Save")
        let success = AppDelegate.data.saveData()
        if success {
            button.setTitle("Saved", for: .normal)
        }
        else {
            button.setTitle("Failed", for: .normal)
        }
        button.isEnabled = false
        button.alpha     = CGFloat(0.5)
    }
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
    
    private func populate(testID: Int, dict: [ModeDistance : DataSequence?]) {
        let offset = testID == 0 ? 10 : 20
        for i in 0..<ModeDistance.count {
            let mode    = ModeDistance(rawValue: i)!
            
            var elapsed : TimeInterval     = -1
            var averageThroughput : Double = 0
            
            if let data = dict[mode] as? DataSequence {
                let values = data.samples
                if (values.count)>0 {
                    elapsed           = values.last!.elapsed
                    averageThroughput = AppDelegate.data.calculateAverageThroughputForMode(testID: testID, mode: mode)
                }
            }
            
            setValue(offset: offset, mode: mode, elapsed: elapsed, averageThroughput: averageThroughput)
        }
    }
    
    private func setupSaveButton() {
        saveButton.addTarget(self, action: #selector(saveData), for: .touchUpInside)
        saveButton.layer.cornerRadius  = saveButton.frame.height / 3
        saveButton.layer.masksToBounds = false
        saveButton.backgroundColor     = UIColor(red: 0.0, green: 0.43, blue: 0.99, alpha: 1.0)
    }
        
    private func setValue(offset: Int, mode: ModeDistance, elapsed: TimeInterval, averageThroughput: Double) {
        let tag = offset + mode.rawValue
        if let label = self.view.viewWithTag(tag) as? UILabel {
            if elapsed<0 {
                label.text = "-"
            }
            else {
                label.text = String(format: "%.1f sec (%.2f bps)", elapsed, averageThroughput)
            }
        }
    }
    
}
