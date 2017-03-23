//
//  CalendarSectionCell.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/27/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import Result
import ReactiveCocoa

class DatesSectionCell: UITableViewCell {
    
    @IBOutlet weak var startDateBT: UIButton!
    @IBOutlet weak var endDateBT: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        startDateBT.layer.cornerRadius = 10
        startDateBT.layer.borderWidth = 2
        startDateBT.layer.borderColor = UIColor.whiteColor().CGColor
        
        endDateBT.layer.cornerRadius = 10
        endDateBT.layer.borderWidth = 2
        endDateBT.layer.borderColor = UIColor.whiteColor().CGColor
        
        MainSection.endDateTitle.producer
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (str) in
                self?.endDateBT.setTitle(str, forState: .Normal)
                self?.endDateBT.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        MainSection.startDateTitle.producer
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (str) in
                self?.startDateBT.setTitle(str, forState: .Normal)
        }
    }
    
    
    @IBAction func depart(sender: AnyObject) {
        if (!MainSection.end.value){
            MainSection.showCal.1.sendNext()
        }
        MainSection.end.swap(false)
        startDateBT.layer.borderColor = Color.ccGreen.CGColor
        endDateBT.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    @IBAction func rtrn(sender: AnyObject) {
        MainSection.end.swap(true)
        endDateBT.layer.borderColor = Color.ccGreen.CGColor
        startDateBT.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
}
