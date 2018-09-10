// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit

final class Utilities {
    
    static let shared = Utilities()
    
    private init(){
        NotificationCenter.default.addObserver(self, selector: #selector(downloadImage(with:)), name: .downloadImage, object: nil)
    }
    
    @objc func downloadImage(with notification: Notification){
        guard let userInfo = notification.userInfo,
            let imageView = userInfo["dealItemCellView"] as? UIImageView,
            let imageUrl = userInfo["thumbnailUrl"] as? String else { return }
        
        DispatchQueue.global().async {
            let downloadedImage = Utilities.httpDownloadImage(imageUrl) ?? UIImage()
            DispatchQueue.main.async {
                imageView.image = downloadedImage
            }
        }
    }
    
    static public func httpDownloadImage(_ url: String) -> UIImage?{
//        sleep(3)//use this line if you want to see how progress indicator works by slowing down the speed of download.
        guard let data = try? Data(contentsOf: URL(string: url)!),
            let image = UIImage(data: data) else {
                return nil
        }
        return image
    }
}

final class eBayColors {
    static let red    = UIColor(red: 197.0/255.0, green:  71.0/255.0, blue:  60.0/255.0, alpha: 1.0)
    static let blue   = UIColor(red:  72.0/255.0, green: 114.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    static let yellow = UIColor(red: 234.0/255.0, green: 184.0/255.0, blue:  54.0/255.0, alpha: 1.0)
    static let green  = UIColor(red: 155.0/255.0, green: 188.0/255.0, blue:  53.0/255.0, alpha: 1.0)
}
