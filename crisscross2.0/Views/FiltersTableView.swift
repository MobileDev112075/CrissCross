//
//  FilterTableView.swift
//  crisscross2.0
//
//  Created by tycoon on 11/24/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import ReactiveCocoa
import Result

class FiltersTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    
    private let filterSectionCellIdentifier = "FilterSectionCell"
    let viewModel: FiltersViewModel
    
    required init?(coder aDecoder: NSCoder) {
 
        self.viewModel = FiltersViewModel()
        super.init(coder:aDecoder)
        self.delegate = self
        self.dataSource = self
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfFilterSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfFilterRows(section)
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(filterSectionCellIdentifier, forIndexPath: indexPath) as! FiltersSectionCell
        cell.viewModel = self.viewModelForFilterSection(indexPath)
        return cell
    }
    
    private func viewModelForFilterSection(indexPath: NSIndexPath) -> FiltersSectionViewModel {
        let filters: [FilterModel] = viewModel.filtersAtIndexPath(indexPath)
        
        return FiltersSectionViewModel(filterViewModelArray:filters,indexSection:indexPath.row,filterHistory:viewModel.filterTreeHistory)
    }
    
}
