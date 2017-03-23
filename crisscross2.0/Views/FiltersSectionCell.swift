//
//  FiltersSectionCell.swift
//  crisscross2.0
//
//  Created by tycoon on 11/19/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import Argo
import ReactiveCocoa
import Result

class FiltersSectionCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource  {
    
    @IBOutlet weak var filterView:UICollectionView!
    private let filterCellIdentifier = "FilterCell"
    
    var viewModel: FiltersSectionViewModel? {
        didSet {
            self.configureFromViewModel()
        }
    }

    private func configureFromViewModel() {
        self.filterView.reloadData()
    }
    
    private func prepareForReuseSignal() -> Signal<(), NoError> {
        return Signal { observer in
            self.rac_prepareForReuseSignal // reactivecocoa builtin function
                .toSignalProducer() // obj-c RACSignal -> swift SignalProducer
                .map { _ in () } // AnyObject? -> Void
                .flatMapError { _ in .empty } // NSError -> NoError
                .start(observer)
        }
    }
    
    // MARK: UITableViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.numberOfFiltersInSection(section)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel!.numberOfFiltersSection()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(filterCellIdentifier, forIndexPath:indexPath) as! MainFilterCell
        var filterModel =  self.viewModel!.filterAtIndexPath(indexPath)
      
        cell.filterButton.setTitle(filterModel.type, forState: .Selected)
        cell.filterButton.setTitle(filterModel.type, forState: .Normal)
        cell.filterButton.selected = viewModel!.selectedIndexPath(indexPath)
        
        if let defOn = filterModel.defOn{
            cell.filterButton.selected = (defOn && !self.viewModel!.selectedRow) || viewModel!.selectedIndexPath(indexPath)
        }

        filterModel.defOn = false

        if cell.filterButton.selected {
            self.filterView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Right, animated: true)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.filterView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Right, animated: true)
        var fh =  viewModel!.filterHistory.value
        let n = fh.count //3 0,1,2
        let x = viewModel!.indexSection
        if x <= n {
            fh = Array(fh[0..<x])
        }
        if fh.count>0 {
            if fh.last!.0 == viewModel!.indexSection {
                fh.removeLast()
            }
        }
        fh.append(viewModel!.indexSection,indexPath.row)
        viewModel!.filterHistory.swap(fh)
    }
}
