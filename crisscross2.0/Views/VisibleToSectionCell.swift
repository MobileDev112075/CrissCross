//
//  CalendarSectionCell.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/27/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result


class VisibleToSectionCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource  {
    
    @IBOutlet weak var filterView:UICollectionView!
    private let filterCellIdentifier = "FilterCell"
    
    
    
    // MARK: UITableViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MainSection.visiTypes.value.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(filterCellIdentifier, forIndexPath:indexPath) as! MainFilterCell
        let filterModel =  MainSection.visiTypes.value[indexPath.row]
        cell.filterButton.setTitle(filterModel.type, forState: .Selected)
        cell.filterButton.setTitle(filterModel.type, forState: .Normal)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MainFilterCell
        cell.filterButton.selected = true
        MainSection.planVisible.swap(indexPath.row)
        if indexPath.row > 0 {
            MainSection.FScreenStatus.swap(indexPath.row)
            MainSection.showFriends.1.sendNext()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MainFilterCell
        cell.filterButton.selected = false
    }
}
