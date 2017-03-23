//
//  SuggSectionSortCell.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/29/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import Argo
import Result
import Alamofire
import AlamofireImage
import ReactiveCocoa

class SuggSectionSortCell: UITableViewCell {
    
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    @IBOutlet weak var filterTableView: FiltersTableView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
