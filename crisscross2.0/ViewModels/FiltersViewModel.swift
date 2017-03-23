//
//  FiltersViewModel.swift
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

class FiltersViewModel {
    
    var filterSections = MutableProperty<[[FilterModel]]>([])
    var filterTreeHistory = MutableProperty<[(Int,Int)]>([])

    
    func numberOfFilterSections() -> Int {
        return 1
    }
    
    func numberOfFilterRows(section: Int) -> Int {
            return filterSections.value.count
    }
    
    func filtersAtIndexPath(indexPath: NSIndexPath) -> [FilterModel] {
        if  filterSections.value.count > indexPath.row {
            return filterSections.value[indexPath.row]
        }else{
            return []
        }
    }
}
