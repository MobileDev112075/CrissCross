//
//  CreateSectionSortCellModel.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 2/6/17.
//  Copyright © 2017 tycoon. All rights reserved.
//

import Argo
import Result
import ReactiveCocoa

class SuggSectionSortCellModel {
    
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    
    var filterSections      = MutableProperty<[[FilterModel]]>([])
    var filterTreeHistory   = MutableProperty<[(Int,Int)]>([])
    
    init() {
        
       
        
           }
}


