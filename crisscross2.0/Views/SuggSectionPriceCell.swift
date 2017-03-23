//
//  SuggSectionSortCell.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/29/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit

class SuggSectionPriceCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet var dolla: [UIButton]!
    @IBAction func dollaTP(sender: AnyObject) {
        let a = sender.tag
        MainSuggSection.priceReady.swap(a)
            _ = dolla.map { (bt) in
            if (bt.tag <= sender.tag)
            {
                bt.selected = true
            }
            else {
                bt.selected = false
            }
        }
        
    }
}
