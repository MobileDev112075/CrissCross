//
//  CalendarViewController.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/26/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import Result
import ReactiveCocoa

class CreatePSectionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private let viewModel:CreatePSectionModel
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = CreatePSectionModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom
        tableView.reloadData()
        bindViewModel()
    }
    
    
    private func bindViewModel() {
        viewModel.active <~ isActive()
        
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] changeset in
                guard let tableView = self?.tableView else { return }
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(changeset.deletions, withRowAnimation: .Automatic)
                tableView.reloadRowsAtIndexPaths(changeset.modifications, withRowAnimation: .Automatic)
                tableView.insertRowsAtIndexPaths(changeset.insertions, withRowAnimation: .Automatic)
                tableView.endUpdates()
                })
        
        
        MainSection.showFriends.0
        .observeOn(UIScheduler())
        .observeNext { () in
            self.performSegueWithIdentifier("GoFriends", sender: nil)
        }
        
        MainSection.planSavedResult.0
            .observeOn(UIScheduler())
            .observeNext { _ in
                MainSection.showSections.swap([])
                self.dismissViewControllerAnimated(false, completion: {
                })
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.viewModel.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
}
