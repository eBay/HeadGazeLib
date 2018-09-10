// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class DealItemInfo: NSObject {
    let urlImage      : String
    let title         : String
    let priceOriginal : Float
    let priceDeal     : Float
    
    init(title: String, priceOriginal: Float, priceDeal: Float, urlImage: String) {
        self.title         = title
        self.priceOriginal = priceOriginal
        self.priceDeal     = priceDeal
        self.urlImage      = urlImage
        super.init()
    }
    
    override public var description: String {
        return self.debugDescription
    }
    
    override public var debugDescription: String {
        return """
        title: \(title)\n
        priceOriginal: \(priceOriginal)\n
        priceDeal: \(priceDeal)\n
        """
    }
}
