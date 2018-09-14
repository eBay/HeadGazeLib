![](https://github.com/eBay/HeadGazeLib/blob/master/examples/demo/demo/video/teaser.gif)  


This simple demo gives you a jump start on how to use "HeadGazeLib" classes in your project.  
It illustrates three types of UI buttons that can switch between sensing head motion and being a regular touchable button.
"Clicking" using head motion on these buttons trigger `TouchUpInside` event that can be captured by the same `@IBAction func` handler you might have defined earlier for regular UIButton, while moving the cursor away from the button triggers `TouchUpOutside` event. 
Currently, we have implemented three types of gazeable buttons plus a special button for statistic analysis:  
* UIHoverableButton: Expands its size upon cursor hovering, and triggers button click after a user specified hovering threshold in second. The cursor is required to leave the button before next click.  
* UIBubbleButton: Fills the background of the button in different colors to indicate the elapsed hovering time before click. The cursor is required to leave the button before next click
* UIMultiFuncButton: Supports long gaze meaning that the cursor can keep hovering over the button to periodically click it without leaving the button. It triggers `TouchUpInside` event for the first click, and `TouchDownRepeat` event for subsequent clicks. For usage see example [HeadSwipe](https://github.com/eBay/HeadGazeLib/tree/master/examples/HeadSwipe).
* UITrackButton: Hoverable button that can track cursor's time and location while it is inside the button. Designed for sensitivity analysis. For usage see example [HeadSwipeSensitivity](https://github.com/eBay/HeadGazeLib/tree/master/examples/HeadSwipeSensitivity).


