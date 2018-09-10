// Copyright 2018 eBay Inc.
// Architect/Developer: Robinson Piramuthu, Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit

class DealGallery: UITableView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    private var currentIndexPath = IndexPath(row: 0, section: 0)
    private var dealRowCells:[DealRow] = []
    private var currentRowCell: DealRow? = nil
    private var isRightButtionClickedOnce: Bool = false
    private var isDownButtionClickedOnce: Bool = false
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //**********************************************************************************************
    // Public methods
    //**********************************************************************************************
    var dealsAll : [DealList] = []
    
    func showPreviousItem(k: Int = 1) {
        self.currentIndexPath = self.currentRowCell!.showPreviousItem(currentIndexPath: self.currentIndexPath, k: k) // let RowCell update currentIndexPath
    }
    
    func showNextItem(k: Int = 1) {
        if !(isRightButtionClickedOnce || isDownButtionClickedOnce) {
            self.currentRowCell = self.dealRowCells[self.currentIndexPath.section]
            isRightButtionClickedOnce = true
        }
        self.currentIndexPath = self.currentRowCell!.showNextItem(currentIndexPath: self.currentIndexPath, k: k)  // let RowCell update currentIndexPath
    }
    
    func showPreviousCategory() {
        let irow = max(self.currentIndexPath.section-1, 0)
        self.showCategory(at: irow)
    }
    
    func showNextCategory() {
        isDownButtionClickedOnce = true
        let irow = min(min(self.currentIndexPath.section+1, DealCategory.count-1), self.dealsAll.count-1)
        self.showCategory(at: irow)
    }
    
    func showCategory(at index: Int){
        let irow = min(min(max(index, 0), DealCategory.count-1), self.dealsAll.count-1)
        let indexPath = IndexPath(row: 0, section: irow) // The row id is actually specified by IndexPath.section
        self.showCategory(at: indexPath)
    }
    
    private func showCategory(at indexpath: IndexPath){
        DispatchQueue.main.async {
            self.currentIndexPath = indexpath
            self.scrollToRow(at: indexpath, at: .top, animated: true)
//             self.selectRow(at: indexpath, animated: true, scrollPosition: UITableViewScrollPosition.top)
        }
    }
    
    func getCurrentRowId() -> Int {
        return currentIndexPath.section
    }
    
    func getCurrentColumnId() -> Int {
        return currentRowCell!.getCurrentItemIndex()
    }
    
    func getCurrentRow() -> DealRow?{
        return currentRowCell
    }
    
    func getCurrentItem() -> DealItemInfo?{
        if self.currentIndexPath.section < self.dealsAll.count{
            if !(isRightButtionClickedOnce || isDownButtionClickedOnce) {
                 self.currentIndexPath.section  = 0
            }
            let irow = self.currentIndexPath.section
            let deals = self.dealsAll[irow]
            if let curRowCell = self.currentRowCell{
                let icol = curRowCell.getCurrentItemIndex()
                if icol < deals.items.count {
                    return deals.items[icol]
                }
            }
        }
        return nil
    }
    
    func getCurrentItemCell() -> DealItemCell? {
        if !(isRightButtionClickedOnce || isDownButtionClickedOnce) {
            self.currentRowCell = self.dealRowCells[0]
        }
        let curRowCell = self.currentRowCell
        return curRowCell?.getCurrentItemCell()
    }
    
    //**********************************************************************************************
    // Private methods - setup and initializations
    //**********************************************************************************************
    
    private func setup() {
        self.isPagingEnabled = true
//        loadDealLists()
        loadDealListsAsynchronously()
        self.rowHeight  = self.frame.size.height //UITableViewAutomaticDimension
        self.dataSource = self
        self.delegate   = self
    }
    
    private func loadDealLists() {
//        for i in 0..<DealCategory.count {
            //MARK: For quick debug
        for i in 0..<2{
            dealsAll.append(DealList(category: DealCategory(rawValue: i)!))
        }
    }
    
    private func loadDealListsAsynchronously() {
        //load first row
        self.dealsAll.append(DealList(category: DealCategory(rawValue: 0)!))
        //asyncronously load the subsequent rows
        let queue = DispatchQueue.global(qos: .background)
        for i in 1..<DealCategory.count{
            queue.async { [unowned self] in
                self.dealsAll.append(DealList(category: DealCategory(rawValue: i)!))
                if self.dealsAll.count == DealCategory.count {
                    self.reorderDealsAll()
                }
                DispatchQueue.main.async {
                    self.reloadData()
                    self.showCategory(at: self.currentIndexPath.section)
                    self.currentIndexPath.section = 0
                }
            }
        }
    }
    
    /**
     reorder the deal rows in the order of enum DealCategory
     */
    private func reorderDealsAll(){
        var newDealAll: [DealList]  = []
        let count = min(DealCategory.count, self.dealsAll.count)
        for i in 0..<count{
            for j in 0..<dealsAll.count{
                if dealsAll[j].categId.rawValue == i{
                    newDealAll.append(dealsAll[j])
                }
            }
        }
        dealsAll = newDealAll
    }
}

extension DealGallery: UITableViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // TODO
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndexPath = indexPath
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        currentIndexPath = indexPath
        self.currentRowCell = cell as? DealRow
        if indexPath.section >= dealRowCells.count {
            dealRowCells.append((cell as! DealRow))
        }
    }
}

extension DealGallery: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dealsAll.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dealsAll[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellDealRow") as! DealRow
        cell.backgroundColor = .clear
        cell.row_id = indexPath.section
        cell.items = dealsAll[indexPath.section].items
        cell.addCollectionView(frame:cell.frame)
        return cell
    }
}
