//
//  DreamEditController.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 1/24/17.
//  Copyright © 2017 tycoon. All rights reserved.
//

import DZNEmptyDataSet
import ReactiveCocoa
import Result

class DreamEditController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    private let dreamCellIdentifier = "DreamCell"
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cityField: UITextField!
    
    var viewModel: DreamViewModel?
    
    @IBAction func dissmisBT(sender: UIButton) {
        self.dissmis()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    // MARK: - Bindings
    
    private func bindViewModel() {

        if let viewModel = viewModel {
            viewModel.editActive <~ isActive()
            viewModel.seacrhCity <~ cityField.signalProducer()
            viewModel.contentChangesSignal
                .observeOn(UIScheduler())
                .observeNext(
                    { [weak self] _ in
                        //                   guard let dreamingView = self?.dreamingView else { return }
                        //                    dreamingView.dreams = self?.viewModel.dictionary
                        //                    dreamingView.doRefreshTagCloud()
                    })

        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(dreamCellIdentifier, forIndexPath: indexPath)
        
        if let label = cell.viewWithTag(200) as? UILabel {
            label.text = viewModel!.dreamTitleAtIndex(indexPath)
        }
        
        return cell
    }
}
