//
//  FilterViewCell.swift
//  RacCriss
//
//  Created by tycoon on 11/12/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import UIKit
import ReactiveCocoa

class FilterViewCell: UICollectionViewCell {
    @IBOutlet weak var filterButton: UIButton!
    
    var selectedRow = MutableProperty<Int?>(nil) {
        didSet {
//            self.configureSelectedRow()
        }
    }
    
}
