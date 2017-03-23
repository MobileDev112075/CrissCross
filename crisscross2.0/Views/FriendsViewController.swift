//
//  FriendsViewController.swift
//  RacCriss
//
//  Created by tycoon on 11/7/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import DZNEmptyDataSet
import ReactiveCocoa
import Result

class FriendsViewController: UIViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    @IBOutlet weak var tableView:UITableView!
    private let viewModel: FriendsViewModel
    
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = FriendsViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        bindViewModel()
    }
    
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        
        viewModel.refreshSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] changeset in
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
    
    
    
    @IBAction func dissmisBT(sender: UIButton) {
        self.dissmis()
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let str = segue.identifier {
            if str == "GoProfile" {
           
            }
        }
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if MainSection.FScreenStatus.value == 0 {
            viewModel.showFriendProfile(indexPath)
            self.performSegueWithIdentifier("GoProfile", sender: nil)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTimelinesInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = viewModel.cellIdentifier(tableView,cellForRowAtIndexPath:indexPath)
        return cell
    }
        
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }

}
