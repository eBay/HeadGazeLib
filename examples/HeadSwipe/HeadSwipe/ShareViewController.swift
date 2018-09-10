// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class ShareViewController: UIHeadGazeViewController {

    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    private var headGazeRecognizer: UIHeadGazeRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Share"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "MarketSans-SemiBold", size: 20)!]
        setupGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupGestureRecognizer() {
        confirmBtn.backgroundColor = eBayColors.green
        //MARK: Usage of UIHeadGazeRecognizer
        //add head gesture recognizer to handle head gaze event
        //e.g. how the UI interface respond to the gaze movement, intersection test, etc.
        self.headGazeRecognizer = UIHeadGazeRecognizer()
        super.virtualCursorView?.addGestureRecognizer(self.headGazeRecognizer)
        self.headGazeRecognizer?.move = { [weak self] gaze in
            self?.buttonAction(button: (self?.confirmBtn)!, gaze: gaze)
            self?.buttonAction(button: (self?.backBtn)!, gaze: gaze)
        }
    }
    
    private func buttonAction(button: UIButton, gaze: UIHeadGaze){
        guard let button = button as? UIHoverableButton else { return }
        button.hover(gaze: gaze)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    // Private methods - setup and initializations
    //**********************************************************************************************

}


