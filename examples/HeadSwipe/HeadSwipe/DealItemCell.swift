// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class DealItemCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPriceDeal: UILabel!
    @IBOutlet weak var labelPriceOriginal: UILabel!
    private var indicatorView: UIActivityIndicatorView! //Show spinning widget as image loading progress
    private var valueObservation: NSKeyValueObservation! // notify when to turn off progress indicator
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.contentView.layer.cornerRadius  = 5//self.frame.size.width/20
        self.contentView.layer.borderWidth   = 1.0
        self.contentView.layer.borderColor   = UIColor.clear.cgColor //UIColor.red.cgColor //debug
        self.contentView.layer.masksToBounds = true
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.shadowColor   = UIColor.black.cgColor
        self.layer.shadowOffset  = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius  = 0//self.contentView.layer.cornerRadius
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        //self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }

    func initialize(item: DealItemInfo) {
        /* debug
        let imageData:NSData = NSData(contentsOf: URL(string:item.urlImage)!)!
        imageView.image = UIImage(data: imageData as Data)!
        */
        
        self.backgroundColor = UIColor.white // brown //debug
        self.backgroundView?.backgroundColor = .white
        
        indicatorView = UIActivityIndicatorView()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.startAnimating()
        addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])

        //imageView.image         = UIImage(named:"Garmin.jpg")!
        labelTitle.text         = item.title
        labelPriceDeal.text     = String(format:"$%.2f", item.priceDeal)
        let first               = String(format:"$%.02f", item.priceOriginal)
        let original            = String(format:"%@ | %.02f%% OFF", first, (item.priceOriginal - item.priceDeal) / item.priceOriginal * 100)
        labelPriceOriginal.text = original
        
        let originalAtrr = NSMutableAttributedString(string: original)
        originalAtrr.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, first.count))
        originalAtrr.addAttribute(NSAttributedStringKey.foregroundColor, value:UIColor.gray, range: NSMakeRange(0, first.count))
        labelPriceOriginal.attributedText = originalAtrr
        //attributedString.addAttributes(firstAttributes, range: NSRange(location: 0, length: 8))
        
        //stop progress bar whenever the thumbnail image get updated
        /* debug
        */
        valueObservation = imageView.observe(\.image, options: [.new], changeHandler: { [unowned self] observed, change in
            if change.newValue is UIImage {
                self.indicatorView.stopAnimating()
            }
        })
        // Post message to Utilities.swift to download thumbnail image.
        NotificationCenter.default.post(name: .downloadImage, object: self, userInfo: ["dealItemCellView": imageView, "thumbnailUrl": item.urlImage])
        self.imageView.image = Utilities.httpDownloadImage(item.urlImage)
    }
    
    public func getImageView() -> UIImage? {
        return self.imageView.image
    }
    public func getItemTitle() -> String {
        return self.labelTitle.text!
    }
    public func getItemDealPrice() -> String {
        return self.labelPriceDeal.text!
    }
    public func getItemPriceOriginal()-> String {
        return self.labelPriceOriginal.text!
    }
    
    override public var description: String{
        return self.debugDescription
    }
    
    override public var debugDescription: String{
        return """
        -------- DealItemCell ------
        title: \(labelTitle.text)
        deal price: \(labelPriceDeal.text)
        original price: \(labelPriceOriginal.text)
        ----------------------------
        """
    }
}

extension Notification.Name {
    static let downloadImage = Notification.Name("downloadImageNotification")
}
