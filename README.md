# HeadGazeLib

![Platform iOS](https://img.shields.io/badge/platform-iOS-orange.svg)
![license MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)
## What is the Project
`HeadGazeLib` is a pure Swift library to empower iOS app control through head gaze without a finger touch.

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

4. Define head gaze even handler through `UIHeadGazeRecognizer` instance in `MyViewController` class
```swift
class MyViewController: UIHeadGazeViewController{
//.....
  private var headGazeRecognizer: UIHeadGazeRecognizer? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    setupGestureRecognizer()
  }
  private func setupGestureRecognizer() {
    // add head gaze recognizer to handle head gaze event
    self.headGazeRecognizer = UIHeadGazeRecognizer()
    super.virtualCursorView?.smoothness = 9
    super.virtualCursorView?.addGestureRecognizer(headGazeRecognizer)
    self.headGazeRecognizer?.move = { [weak self] gaze in

        self?.buttonAction(button: (self?.myButton)!, gaze: gaze)

    }
  }
  private func buttonAction(button: UIButton, gaze: UIHeadGaze){
    guard let button = button as? UIHoverableButton else { return }
    button.hover(gaze: gaze)
  }
//....
}
```

For working demo, we have prepared two examples:
1. HeadSwipe: Swipe daily deal on eBay with head control  
2. Sensitivity: Head control sensitivity analysis app is used to track the location and timestamp of the cursor as user is "clicking" the button. Useful for user study.  

## License
Copyright 2018 eBay Inc.  
HeadGazeLib is available under the MIT license. See the LICENSE file for more info.

## Developers
[Jinrong Xie](http://jinrongxie.net/), [Muratcan Cicek](https://users.soe.ucsc.edu/~cicekm/), Robinson Piramuthu
