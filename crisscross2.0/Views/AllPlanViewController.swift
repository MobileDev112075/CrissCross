//
//  AllPlanViewController
//  RacCriss
//
//  Created by tycoon on 11/13/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import DZNEmptyDataSet
import ReactiveCocoa
import Result



class AllPlanViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private let childCellIdentifier = "ChildCell"
    private let filterSectionCellIdentifier = "FilterSectionCell"
    
    @IBAction func dissmisBT(sender: UIButton) {
        self.dissmis()
    }
        
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var filterTableView:FiltersTableView!
    
    
    private let refreshControl = UIRefreshControl()
    private let viewModel: AllPlanViewModel
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = AllPlanViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    // MARK: - View Lifecycle
    
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        tableView.addSubview(refreshControl)
        self.refreshControl.addTarget(self,action:#selector(refreshControlTriggered),forControlEvents:.ValueChanged)
        bindViewModel()
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        self.title = viewModel.title
        viewModel.active <~ isActive()
        
        viewModel.filterSections.signal
            .filter({ _ in self.filterTableView != nil })
            .observeOn(UIScheduler())
            .observeNext { [weak self](models) in
                self?.filterTableView.reloadData()
                if models.count>2{
                    let path = NSIndexPath(forRow: models.count-1, inSection: 0)
                    self?.filterTableView.scrollToRowAtIndexPath(path, atScrollPosition: .Top, animated: true)
                }
        }

        

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
        
        
        viewModel.oneSelectionSignal
            .observeOn(UIScheduler())
            .observeNext { (child) in
                self.performSegueWithIdentifier("ShowOne", sender:LocationChild(child: child))
        }
        
    }
    
    func refreshControlTriggered() {
        viewModel.refreshObserver.sendNext(())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    
    // MARK: - UITableViewDataSource
    
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
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 154
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfChildrenInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(childCellIdentifier, forIndexPath: indexPath) as! PlanCell
            cell.viewModel = self.viewModelForIndexPath(indexPath)
            return cell
    }
    
    private func viewModelForFilterSection(indexPath: NSIndexPath) -> FiltersSectionViewModel {
        return FiltersSectionViewModel(filterViewModelArray:[],indexSection:indexPath.row,filterHistory:viewModel.filterTreeHistory)
    }
    
    private func viewModelForIndexPath(indexPath: NSIndexPath) -> PlanCellViewModel {
        let plan: Plan = viewModel.childAtIndexPath(indexPath)
        let image =  Shared.MyInfo.plansImages[plan.planId]
        return PlanCellViewModel(plan: plan, image: image)
    }
}
