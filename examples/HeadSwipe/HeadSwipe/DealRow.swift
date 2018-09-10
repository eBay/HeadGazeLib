// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class DealRow: UITableViewCell {
    
    var items : [DealItemInfo] = []
    var currentItemCell: DealItemCell? = nil
    var row_id: Int = 0

    private var collectionView : UICollectionView?
    private var currentIndexPath = IndexPath(row: 0, section: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //**********************************************************************************************
    // Public methods
    //**********************************************************************************************
    func addCollectionView(frame : CGRect) {
        //NSLog("DealRow: %f, %f", self.frame.size.height, self.frame.size.width)
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset    = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.scrollDirection = .horizontal
        
        /**
         Note that the UITableView reuses existing cell for better performance.
         We need this block to remove existing collection view, if there is any,
         to avoid adding duplicated collection view to the same DealRow instance
         */
        if let oldCollectionView = collectionView {
            oldCollectionView.removeFromSuperview()
        }
        let collectionViewFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView?.register(UINib(nibName: "DealItemCell", bundle: nil), forCellWithReuseIdentifier: "cellGalleryItem")
        collectionView?.isPagingEnabled = true
        collectionView?.dataSource      = self
        collectionView?.delegate        = self
        collectionView?.backgroundColor = .clear //.purple
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator   = false
        collectionView?.isDirectionalLockEnabled       = true
        self.addSubview(collectionView!)
    }
    
    func getCurrentItemIndex() -> Int{
        return self.currentIndexPath.row
    }
    
    func getCurrentItemCell() -> DealItemCell?{
        return self.currentItemCell
    }
    
    func showPreviousItem(currentIndexPath: IndexPath, k: Int = 1) -> IndexPath {
        let index     = max(currentIndexPath.row-k,0)
        let nextIndexPath = IndexPath(row: index, section: 0)
        return self.showItem(currentIndexPath: currentIndexPath, nextIndexPath: nextIndexPath)
    }
    
    func showNextItem(currentIndexPath: IndexPath, k: Int = 1) -> IndexPath {
        let index     = min(currentIndexPath.row+k, self.items.count - 1)
        let nextIndexPath = IndexPath(row: index, section: 0)
        return self.showItem(currentIndexPath: currentIndexPath, nextIndexPath: nextIndexPath)
    }
    
    func showItem(currentIndexPath: IndexPath, nextIndexPath: IndexPath) -> IndexPath {
        self.currentIndexPath =  nextIndexPath
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at: nextIndexPath, at: [.centeredHorizontally], animated: true)
        }
        return IndexPath(row: nextIndexPath.row, section: currentIndexPath.section) // return updated indexPath
    }
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************

}

extension DealRow: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentItemCell = cell as? DealItemCell
    }
}

extension DealRow : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellGalleryItem", for: indexPath) as! DealItemCell
        cell.frame = CGRect(origin: cell.frame.origin, size: CGSize(width: cell.frame.size.width, height: self.frame.size.height))
        cell.initialize(item: items[indexPath.row])
        return cell
    }
}

extension DealRow : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsToShow : CGFloat = 1
        let padding     : CGFloat = 5
        let width  = (self.bounds.width / itemsToShow) - padding
        let height = self.bounds.height - (3 * padding)
        return CGSize(width: width, height: height)
    }
    
}
