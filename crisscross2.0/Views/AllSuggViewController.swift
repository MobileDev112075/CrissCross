//
//  AllSuggViewController.swift
//  RacCriss
//
//  Created by tycoon on 11/13/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import DZNEmptyDataSet
import ReactiveCocoa
import Result

class AllSuggViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var filterTableView:FiltersTableView!
    @IBOutlet weak var filterTableViewHeight: NSLayoutConstraint!
    
    @IBAction func dissmisBT(sender: UIButton) {
        self.dissmis()
    }
    @IBAction func newSuggTap(sender: AnyObject) {
        MainSuggSection.editChildrenLocation.swap(nil)
        self.performSegueWithIdentifier("AddSugg", sender: nil)
    }
    
    private let refreshControl = UIRefreshControl()
    private let viewModel: AllSuggViewModel
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = AllSuggViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    // MARK: - View Lifecycle
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelectionDuringEditing = true
//        tableView.addSubview(refreshControl)
//        self.refreshControl.addTarget(self,action:#selector(refreshControlTriggered),forControlEvents:.ValueChanged)
        
        bindViewModel()
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        self.title = viewModel.title
        
        filterTableView.viewModel.filterSections = viewModel.filterSections
        filterTableView.viewModel.filterTreeHistory = viewModel.filterTreeHistory
        
        viewModel.active <~ isActive()
    
        viewModel.filterSections.signal
            .filter({ [weak self] _ in self?.filterTableView != nil })
            .observeOn(UIScheduler())
            .observeNext { [weak self](models) in
                var height:CGFloat = 90.0
                if models.count>1 { height = 140 }
                self?.filterTableViewHeight.constant = height
                self?.filterTableView.reloadData()
                if models.count>2{
                let path = NSIndexPath(forRow: models.count-1, inSection: 0)
                self?.filterTableView.scrollToRowAtIndexPath(path, atScrollPosition: .Top, animated: true)
                }
        }
        
        Shared.MyInfo.selectedChild.signal
            .ignoreNil()
            .observeOn(UIScheduler())
            .observeNext {[weak self] (child) in
                self?.performSegueWithIdentifier("ShowOne", sender:nil)
        }
        
        viewModel.alertMessageSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] alertMessage in
                let alertController = UIAlertController(
                    title: "Oops!",
                    message: alertMessage,
                    preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self?.presentViewController(alertController, animated: true, completion: nil)
                })
        
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] _ in
                guard let tableView = self?.tableView else { return }
                tableView.reloadData()
                tableView.scrollRectToVisible(CGRectMake(0, 0, 10, 10), animated: true)
                })
        
        viewModel.isLoading.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }})
    }

    func refreshControlTriggered() {
        viewModel.refreshObserver.sendNext(())
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if tableView != filterTableView
        {
            viewModel.didSelectRowAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let title = UILabel()
        title.font = UIFont(name: "Brown-Regular", size: 12)!
        title.textColor = UIColor.whiteColor()
        
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView?.backgroundColor = Color.cox
        header.textLabel?.font=title.font
        header.textLabel?.textColor=title.textColor
        header.textLabel?.opaque = true
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "  \(viewModel.headerForLocation(section))"
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return viewModel.heightForRow()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeader()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfChildrenInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = viewModel.cellIdentifier(tableView,cellForRowAtIndexPath:indexPath)
        return cell
    }
    
}

