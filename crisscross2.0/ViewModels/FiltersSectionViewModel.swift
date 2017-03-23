//
//  FiltersSectionViewModel.swift
//  crisscross2.0
//
//  Created by tycoon on 11/19/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import Argo
import Result
import Alamofire
import AlamofireImage
import ReactiveCocoa

class FiltersSectionViewModel {
    
    // Inputs
    let filterViewModelArray:[FilterModel]
    let indexSection:Int
    var filterHistory = MutableProperty<[(Int,Int)]>([])
    var selectedRow:Bool
    
    init(filterViewModelArray:[FilterModel], indexSection:Int, filterHistory:MutableProperty<[(Int,Int)]>) {
        self.filterViewModelArray           = filterViewModelArray
        self.indexSection                   = indexSection
        self.filterHistory                  = filterHistory
        let n = filterHistory.value.count
        if indexSection<n {
            self.selectedRow = true
        }else{
            self.selectedRow = false
        }
    }

    func numberOfFiltersSection() -> Int {
        return 1
    }
    
    func numberOfFiltersInSection(section: Int) -> Int {
        return filterViewModelArray.count
    }
    
    func filterAtIndexPath(indexPath: NSIndexPath) -> FilterModel {
        return filterViewModelArray[indexPath.row]
    }
    
    func selectedIndexPath(indexPath: NSIndexPath) -> Bool {
        let n = filterHistory.value.count
        let ix = indexSection
        if ix<n {
            let e = filterHistory.value[ix]
            return e.0 == self.indexSection && e.1 == indexPath.row
        }
        return false
    }
}
