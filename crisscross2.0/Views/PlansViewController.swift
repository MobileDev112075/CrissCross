//
//  PlansViewController
//  RacCriss
//
//  Created by tycoon on 11/13/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import DZNEmptyDataSet
import ReactiveCocoa
import Result

class PlansViewController: UIViewController , DZNEmptyDataSetDelegate, DZNEmptyDataSetSource,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBAction func dissmisBT(sender: UIButton) {
        self.dissmis()
    }
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var filterView:UICollectionView!
    
    private let refreshControl = UIRefreshControl()
    private let planCellIdentifier = "PlanCell"
    private let filterCellIdentifier = "FilterCell"
    private let viewModel: PlansViewModel
//    private weak var selectedFilterViewModel:FilterCellViewModel?
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = PlansViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.addSubview(refreshControl)
        
        self.refreshControl.addTarget(self,action:#selector(refreshControlTriggered),forControlEvents: .ValueChanged)
        
        bindViewModel()
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        self.title = viewModel.title
        
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
        
        viewModel.isLoading.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
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
    
    func refreshControlTriggered() {
        viewModel.refreshObserver.sendNext(())
    }
    
    // MARK: DZNEmptyDataSetDelegate
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(settingsURL)
        }
    }
    
    // MARK: DZNEmptyDataSetSource
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No matches yet!"
        let attributes = [
            NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 30)!
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Check your storage settings, then tap the “+” button to get started."
        let attributes = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 20)!,
            NSForegroundColorAttributeName: UIColor.lightGrayColor()
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let text = "Open App Settings"
        let attributes = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 20)!,
            NSForegroundColorAttributeName: (state == .Normal
                ? Color.primaryColor
                : Color.lighterPrimaryColor)
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfPlansInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(planCellIdentifier, forIndexPath: indexPath) as! PlanCell
        
        cell.viewModel = self.viewModelForIndexPath(indexPath)
        return cell
    }
    
    private func viewModelForIndexPath(indexPath: NSIndexPath) -> PlanCellViewModel {
        let plan: Plan = viewModel.planAtIndexPath(indexPath)
        return PlanCellViewModel(plan: plan, image:nil)
    }
    
    // MARK: UITableViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfFiltersInSection(section)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel.numberOfFiltersSection()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(filterCellIdentifier, forIndexPath:indexPath) as! MainFilterCell
//        cell.viewModel = self.viewModelForFilterIndexPath(indexPath)
        return cell
    }
    
    
//    private func viewModelForFilterIndexPath(indexPath: NSIndexPath) -> FilterCellViewModel {
//        let planFilter: PlanFilterType = viewModel.filterAtIndexPath(indexPath)
//        return FilterCellViewModel(mainFilter: planFilter)
//    }
//    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MainFilterCell
        
//        if let prev = selectedFilterViewModel{
//            prev.isSelected.value = false
//        }
//        
//        if let mFilterViewModel:FilterCellViewModel = cell.viewModel {
//            mFilterViewModel.isSelected.value = true
//            selectedFilterViewModel = mFilterViewModel
//        }
    }
    
}

