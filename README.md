# HeadGazeLib

![Platform iOS](https://img.shields.io/badge/platform-iOS-orange.svg)
![license MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)
## What is the Project
`HeadGazeLib` is a pure Swift library to empower iOS app control through head gaze without a finger touch.  
See the story behind it [here](https://www.ebayinc.com/stories/news/ebay-open-sources-technology-that-uses-head-motion-to-navigate-user-interface-on-iphone-x/)

![](https://github.com/ebay/HeadGazeLib/blob/master/examples/demo/demo/video/teaser.gif)  
The above teaser is available at [example/demo](https://github.com/ebay/HeadGazeLib/tree/master/examples/demo).

## Who May Wish to Use the Project
Any iOS developer who would like to introduce head-based control to their app. Ideal for accessibility and game control.

## Dependencies
iPhone X, iOS 11, Swift 4

## How to use the library
1. Simply copy and paste the entire folder `HeadGazeLib` to your xcode project.
2. Extend your ViewController from `UIHeadGazeViewController` and change the button outlet reference class from `UIButton` to `UIHoverableButton` or `UIBubbleButton`
```swift
class MyViewController: UIHeadGazeViewController{
    @IBOutlet weak var myButton: UIBubbleButton! // UIButton!
}
```
3. Similarily, change the button class from `UIButton` to `UIHoverableButton` or `UIBubbleButton` in the identity inspector of storyboard

4. Define head gaze event handler through `UIHeadGazeRecognizer` instance in `MyViewController` class
```swift
class MyViewController: UIHeadGazeViewController{
//.....
  private var headGazeRecognizer: UIHeadGazeRecognizer? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    setupGestureRecognizer()
  }
  private func setupGestureRecognizer() {
    // set button dwell duration
    self.myButton.dwellDuration = 1 // in second
    
    // add head gaze recognizer to handle head gaze event
    self.headGazeRecognizer = UIHeadGazeRecognizer()
    
    //Between [0,9]. Stablize the cursor reducing the wiggling noise.
    //The higher the value the more smoothly the cursor moves.
    super.virtualCursorView?.smoothness = 9
    
    super.virtualCursorView?.addGestureRecognizer(headGazeRecognizer)
    self.headGazeRecognizer?.move = { [weak self] gaze in

        self?.buttonAction(button: (self?.myButton)!, gaze: gaze)

    }
  }
  private func buttonAction(button: UIButton, gaze: UIHeadGaze){
    guard let button = button as? UIHoverableButton else { return }
    // The button instance would trigger TouchUpInside event after user specified seconds
    button.hover(gaze: gaze) 
  }
  
  @IBAction func myBtnTouchUpInside(_ sender: UIBubbleButton) {
     print("Button clicked by head gaze.")
  }
//....
}
```

For working demo, we have prepared three examples:
1. demo: A simple jump start example showing how to empower a regular iOS app with head control with minimum code change.  
2. HeadSwipe: A more serious example - swipe daily deal on eBay with head control  
3. Sensitivity: An example on how to use `UIMultiFuncButton` to track the location and timestamp of the cursor as user is "clicking" the button. Useful for sensitivity analysis.  

## Citation

If you find this work useful in your research, please consider citing:

Cicek, Muratcan, Jinrong Xie, Qiaosong Wang, and Robinson Piramuthu. "Mobile Head Tracking for eCommerce and Beyond." arXiv preprint [arXiv:1812.07143 (2018)](http://arxiv.org/abs/1812.07143).

BibTeX entry:
```
@article{cicek2018mobile,
  title={Mobile Head Tracking for eCommerce and Beyond},
  author={Cicek, Muratcan and Xie, Jinrong and Wang, Qiaosong and Piramuthu, Robinson},
  journal={arXiv preprint arXiv:1812.07143},
  year={2018}
}
```

## License
Copyright 2018 eBay Inc.  
HeadGazeLib is available under the MIT license. See the LICENSE file for more info.

## Developers
[Jinrong Xie](http://jinrongxie.net/), [Muratcan Cicek](https://users.soe.ucsc.edu/~cicekm/), Robinson Piramuthu
