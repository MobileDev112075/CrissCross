//
//  CalendarSectionCell.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/27/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit

class HowSectionCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet var allHowIcons: [UIButton]!
    
    func selectionMade(how:UIButton){
        MainSection.howType.swap(how.tag)
        _=allHowIcons.map{$0.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        }
        let lightUP = allHowIcons.filter { (bt:UIButton) -> Bool in
            bt.tag == how.tag
        }
        lightUP.first?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    @IBAction func fly(sender: UIButton) {
        selectionMade(sender)
    }
    @IBAction func car(sender: UIButton) {
        selectionMade(sender)
    }
    @IBAction func train(sender: UIButton) {
        selectionMade(sender)
    }
    @IBAction func bus(sender: UIButton) {
        selectionMade(sender)
    }
    
    
}
