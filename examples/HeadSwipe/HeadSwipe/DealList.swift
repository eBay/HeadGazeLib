// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit
import SwiftSoup

enum DealCategory:Int {
    case Featured      = 0
    case Tech          = 1
    case Fashion       = 2
    case HomeAndGarden = 3
    case SportingGoods = 4
    case Automotive    = 5
    case Other         = 6
    
    static var count: Int { return DealCategory.Other.rawValue + 1}
}

class DealList: NSObject {
    let categId: DealCategory
    let name  : String
    var items : [DealItemInfo] = []
    
    init(category: DealCategory = .Featured) {
        self.categId = category
        var urlString = ""
        switch category {
            case .Featured:
                name = "Featured"
                urlString = "https://www.ebay.com/deals"
                break
            
            case .Tech:
                name = "Tech"
                urlString = "https://www.ebay.com/deals/tech"
                break
            
            case .Fashion:
                name = "Fashion"
                urlString = "https://www.ebay.com/deals/fashion"
            break
            
        case .HomeAndGarden:
            name = "Home & Garden"
            urlString = "https://www.ebay.com/deals/home-garden"
            break
            
        case .SportingGoods:
            name = "Sporting Goods"
            urlString = "https://www.ebay.com/deals/sporting-goods"
            break
            
        case .Automotive:
            name = "Automotive"
            urlString = "https://www.ebay.com/deals/automotive"
            break
            
        case .Other:
            name = "Other Deals"
            urlString = "https://www.ebay.com/deals/other-deals"
        }
        
        if let url = URL(string: urlString) {
            do {
                let html = try String(contentsOf: url)
                let doc: Document = try SwiftSoup.parse(html)
                let deals: Elements = try doc.select("div[itemtype=https://schema.org/Product][class^=dne-item]")
                for deal: Element in deals.array() {
                    var dealTitle = "Untitled"
                    var urlImage:String = ""
                    var priceDeal:Float = -1
                    var priceOriginal:Float = -2 // TODO: nil values must be handled
                    
                    if let title = try deal.select("span[itemprop=name]").first()?.text() {
                        dealTitle = title
                    }
                    
                    if let urlImageFromHtml = try deal.select("img[src$=.jpg]").first()?.attr("src") ??  deal.select("img[data-config-src$=.jpg]").first()?.attr("data-config-src") {
                        urlImage = urlImageFromHtml.replacingOccurrences(of: "s-l140", with: "s-l500")
                        urlImage = urlImage.replacingOccurrences(of: "s-l200", with: "s-l500")
                    }
                    if var priceDealFromHtml = try deal.select("span[itemprop=price]").first()?.text() ?? deal.select("span[class=itemtile-price-strikethrough").first()?.text() {
                        priceDealFromHtml.removeFirst()
                        priceDeal = (priceDealFromHtml as NSString).floatValue
                        if priceDealFromHtml.count > 6 {
                            priceDeal = ((priceDealFromHtml as NSString).replacingOccurrences(of: ",", with: "") as NSString).floatValue
                        }
                    }
                    if var priceOriginalFromHtml = try deal.select("span[class=dne-itemtile-original-price").first()?.text() ?? deal.select("span[class=itemtile-price-strikethrough").first()?.text() {
                        priceOriginalFromHtml.removeFirst()
                        priceOriginal = (priceOriginalFromHtml as NSString).floatValue
                        if priceOriginalFromHtml.count > 6 {
                            priceOriginal = ((priceOriginalFromHtml as NSString).replacingOccurrences(of: ",", with: "") as NSString).floatValue
                        }
                    }
                    if priceOriginal == -1 || priceOriginal < priceDeal {
                        priceOriginal = priceDeal
                    }
                    
                    let item = DealItemInfo(title: dealTitle, priceOriginal: priceOriginal, priceDeal: priceDeal, urlImage: urlImage)
                    items.append(item)
                }

            } catch {
                print("Failed to load contents")
            }
        } else {
            print("Incorrect URL")
        }
        super.init()
    }
    
}
