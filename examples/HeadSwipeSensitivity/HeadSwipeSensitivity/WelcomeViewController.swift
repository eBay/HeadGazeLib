// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var nextPage: UIButton!
    //@IBOutlet weak var nextPage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTitleImage()
        setupMessage()
        setupNextPageButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //**********************************************************************************************
    // Callbacks
    //**********************************************************************************************

    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
    private func setupMessage() {
        
        let sentences = [
            "There are 2 tests under 3 modes each",
            "Finish each test in the shortest amount of time",
            "Move your head to select buttons",
            "Imagine touching the screen with your nose",
            "Modes are defined by distance between face and screen:"
        ]
        
        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        let indentation = CGFloat(50)
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        paragraphStyle.lineSpacing        = CGFloat(1.2)
        paragraphStyle.paragraphSpacing   = CGFloat(10)
        paragraphStyle.headIndent         = indentation
        
        let bullet     = "○"
        let bulletList = NSMutableAttributedString()
        for string in sentences {
            let formatted = "\(bullet)\t\(string)\n"
            let line      = NSMutableAttributedString(string: formatted)
            line.addAttributes(
                [NSAttributedStringKey.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, line.length))
            
            //line.addAttributes(textAttributes, range: NSMakeRange(0, line.length))
            //let string:NSString = NSString(string: formatted)
            //let rangeForBullet:NSRange = string.range(of: bullet)
            //line.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(line)
        }
        
        message.attributedText = bulletList
    }

    private func setupNextPageButton() {
        nextPage.layer.cornerRadius  = nextPage.frame.height / 3
        nextPage.layer.masksToBounds = false
        nextPage.backgroundColor     = UIColor(red: 0.0, green: 0.43, blue: 0.99, alpha: 1.0)
    }
    
    private func setupTitleImage() {
        let titleImage         = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        titleImage.image       = #imageLiteral(resourceName: "logo_dark")
        titleImage.contentMode = .scaleAspectFit
        self.navigationItem.titleView = titleImage
    }
}

