// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class MainViewController: UIHeadGazeViewController{
    @IBOutlet weak var buyButton:   UIHoverableButton!
    @IBOutlet weak var shareButton: UIHoverableButton!
    @IBOutlet weak var saveButton:  UIHoverableButton!
    
    @IBOutlet weak var upButton: UIBubbleButton!
    @IBOutlet weak var downButton: UIBubbleButton!
    @IBOutlet weak var leftButton: UIBubbleButton!
    @IBOutlet weak var rightButton: UIMultiFuncButton! // for debug
    
    @IBOutlet weak var gallery:     DealGallery!
    @IBOutlet weak var actionButtonGroupView: UIView!
    
    private let utilities: Utilities = Utilities.shared
    
    private var headGazeRecognizer: UIHeadGazeRecognizer? = nil
    
    var curRowIdx: Int = 0 //keep tracking current row index, used to restore current visible deal item cell view after unwinding from segue
    var curColIdx: Int = 0 //keep tracking current oolumn index, used to restore current visible deal item cell view after unwinding from segue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupActionButtons()
        setupGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        recoverCurrentRow()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        curRowIdx = gallery.getCurrentRowId()
        curColIdx = gallery.getCurrentColumnId()
    }
    
    /**
     recover current active row of the gallery after unwind from segue
     */
    private func recoverCurrentRow(){
        gallery.showCategory(at: curRowIdx)
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

    
    //triggered on Touch down event inside left button
    @IBAction func highlightLeftButton(_ button: UIButton) {
        button.backgroundColor = UIColor(red:0.00, green:0.43, blue:0.99, alpha:1.0)
    }
    
    //triggered on Touch up event inside left button
    @IBAction func showPreviousItem(_ button: UIButton) {
        button.backgroundColor = .clear
        gallery.showPreviousItem()
    }
    
    //triggered on Touch down repeat event inside left button
    @IBAction func showKthPreviousItem(_ sender: UIMultiFuncButton) {
        gallery.showPreviousItem(k: 1)
    }
    
    
    //triggered on Touch down event inside right button
    @IBAction func highlightRightButton(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red:0.00, green:0.43, blue:0.99, alpha:1.0)
    }
    
    //triggered on Touch up event inside right button
    @IBAction func showNextItem(_ button: UIButton) {
        button.backgroundColor = .clear
        gallery.showNextItem()
    }
    
    //triggered on Touch down repeat event inside right button
    
    @IBAction func showKthNextItem(_ sender: UIMultiFuncButton) {
        gallery.showNextItem(k: 1)
    }
    
    //triggered on Touch down event inside up button
    @IBAction func highlightUpButton(_ button: UIButton) {
        button.backgroundColor = UIColor(red:0.00, green:0.43, blue:0.99, alpha:1.0)
    }
    
    //triggered on Touch up event inside up button
    @IBAction func showPreviousCategory(_ button: UIButton) {
        button.backgroundColor = .clear
        gallery.showPreviousCategory()
    }
    
    //triggered on Touch down event inside down button
    @IBAction func highlightDownButton(_ button: UIButton) {
        button.backgroundColor = UIColor(red:0.00, green:0.43, blue:0.99, alpha:1.0)
    }
    
    //triggered on Touch up event inside down button
    @IBAction func showNextCategory(_ button: UIButton) {
        button.backgroundColor = .clear
        gallery.showNextCategory()
    }
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
    
    private func makecircularWithShadow(button: UIButton, name: String="untitled") {
        button.layer.cornerRadius  = button.frame.height / 2
        button.layer.masksToBounds = false
        button.layer.shadowColor   = UIColor.black.cgColor
        button.layer.shadowOffset  = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowRadius  = 1.0
        button.layer.shadowOpacity = 0.5
        
        guard let button = button as? UIHoverableButton else { return }
        button.name = name
    }
    
    private func setupActionButtons() {
        makecircularWithShadow(button: buyButton, name: "buyButton")
        makecircularWithShadow(button: shareButton, name: "shareButton")
        makecircularWithShadow(button: saveButton, name: "saveButton")
    }
    
    private func setupGestureRecognizer() {
        //MARK: Usage of UIHeadGazeRecognizer
        //add head gesture recognizer to handle head gaze event
        //e.g. how the UI interface respond to the gaze movement, intersection test, etc.
        self.headGazeRecognizer = UIHeadGazeRecognizer()
        super.virtualCursorView?.smoothness = 9
        super.virtualCursorView?.addGestureRecognizer(headGazeRecognizer)
        self.headGazeRecognizer?.move = { [weak self] gaze in
            
            self?.buttonAction(button: (self?.buyButton)!, gaze: gaze)
            self?.buttonAction(button: (self?.shareButton)!, gaze: gaze)
            self?.buttonAction(button: (self?.saveButton)!, gaze: gaze)
            
            self?.buttonAction(button: (self?.upButton)!, gaze: gaze)
            self?.buttonAction(button: (self?.downButton)!, gaze: gaze)
            self?.buttonAction(button: (self?.leftButton)!, gaze: gaze)
            self?.buttonAction(button: (self?.rightButton)!, gaze: gaze)
        }
    }

    private func buttonAction(button: UIButton, gaze: UIHeadGaze){
        guard let button = button as? UIHoverableButton else { return }
        button.hover(gaze: gaze)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bv = segue.destination as? BuyViewController{
            bv.selectedDealItemCell = gallery.getCurrentItemCell()
        }
        if let cv = segue.destination as? CartViewController{
            cv.selectedDealItemCell = gallery.getCurrentItemCell()
        }
    }
    
}

/**
 Beside using UIHeadGazeRecognizer to handle head gaze event
 e.g. how the UI interface respond to the gaze movement, intersection test, etc.
 , you can also use delegate UIHeadGazeView.delegateHeadGaze to listen the
 change of gaze location
 */
extension MainViewController: UIHeadGazeViewDelegate {
    func update(_ uiHeadGazeView: UIHeadGazeView, didUpdate headGazes: Set<UIHeadGaze>) {
    }
}




