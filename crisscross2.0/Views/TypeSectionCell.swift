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

class TypeSectionCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource  {
    
    @IBOutlet weak var filterView:UICollectionView!
    private let filterCellIdentifier = "FilterCell"
    

    
    // MARK: UITableViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MainSection.planTypes.value.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(filterCellIdentifier, forIndexPath:indexPath) as! MainFilterCell
        let filterModel =  MainSection.planTypes.value[indexPath.row]
        
        cell.filterButton.setTitle(filterModel.type, forState: .Selected)
        cell.filterButton.setTitle(filterModel.type, forState: .Normal)
        
        if cell.filterButton.selected {
            self.filterView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Right, animated: true)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MainFilterCell
         cell.filterButton.selected = true
        MainSection.planType.swap(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MainFilterCell
        cell.filterButton.selected = false
    }

}
