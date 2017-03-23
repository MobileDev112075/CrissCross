//
//  CalendarSectionCell.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/27/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SnapKit

class DaysSectionCell: UITableViewCell {

    @IBOutlet weak var daysView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MainSection.monthTitle.producer
        .observeOn(UIScheduler())
        .startWithNext { [weak self] (str) in
            self?.monthLabel.text = str
        }
        
    }
    
    
    @IBAction func next(sender: UIButton) {
        MainSection.cal_next.1.sendNext()
    }
    @IBAction func previous(sender: UIButton) {
        MainSection.cal_prev.1.sendNext()
    }

}
