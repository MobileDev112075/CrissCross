//
//  TimelineViewController.swift
//  RacCriss
//
//  Created by tycoon on 11/7/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import DZNEmptyDataSet
import ReactiveCocoa
import Result

class TimelineViewController: UIViewController {
    
    @IBAction func dissmisBT(sender: UIButton) {
        self.dissmis()
    }

    @IBOutlet weak var tableView:UITableView!
    
    private let timelineCellIdentifier = "TimelineCell"
    private let childCellIdentifier = "ChildCell"
    private let viewModel: TimelineViewModel
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = TimelineViewModel(store:Shared.MyInfo.localStore)
        super.init(coder:aDecoder)
    }
    

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom
        
        bindViewModel()
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        
        self.title = viewModel.title
        
        viewModel.timelines.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self]  _ in
                guard let tableView = self?.tableView else { return }
                tableView.reloadData()
                })
        
        viewModel.alertMessageSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] alertMessage in
                let alertController = UIAlertController(
                    title: "Oops!",
                    message: alertMessage,
                    preferredStyle: .Alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self?.presentViewController(alertController, animated: true, completion: nil)
                })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTimelinesInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let action = viewModel.actionAtIndexPath(indexPath)
        if action == "BTDT" {
            let cell = tableView.dequeueReusableCellWithIdentifier(childCellIdentifier, forIndexPath: indexPath) as! SuggCell
            cell.viewModel = SuggCellViewModel(child: viewModel.childAtIndexPath(indexPath)!)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(timelineCellIdentifier, forIndexPath: indexPath) as! TimelineCell
            cell.viewModel = TimelineCellViewModel(timeline: viewModel.timeObjAtIndexPath(indexPath)!)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let action = viewModel.actionAtIndexPath(indexPath)
        if action == "BTDT" {
            return 147
        }else{
            return 125
        }
    }


}
