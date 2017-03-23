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

class SuggViewController: UIViewController , DZNEmptyDataSetDelegate, DZNEmptyDataSetSource,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var filterView:UICollectionView!
    
    
    private let suggCellIdentifier = "SuggCell"
    private let filterCellIdentifier = "FilterCell"
    private let viewModel: SuggViewModel
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = SuggViewModel(store:Shared.MyInfo.localStore)
        super.init(coder:aDecoder)
    }
    

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.allowsSelection = false
        tableView.allowsSelectionDuringEditing = true
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        
        bindViewModel()
    }
    
    // MARK: - Bindings
    
    func dissmis()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func bindViewModel() {

        
        self.title = viewModel.title
        
        viewModel.suggsChild.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self]  _ in
                guard let tableView = self?.tableView else { return }
                tableView.reloadData()
                })
        
//        viewModel.filtersAct.producer
//            .observeOn(UIScheduler())
//            .startWithNext({ [weak self]  _ in
//                guard let tableView = self?.tableView else { return }
//                tableView.reloadData()
//                })
        

//        viewModel.alertMessageSignal
//            .observeOn(UIScheduler())
//            .observeNext({ [weak self] alertMessage in
//                let alertController = UIAlertController(
//                    title: "Oops!",
//                    message: alertMessage,
//                    preferredStyle: .Alert
//                )
//                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
//                self?.presentViewController(alertController, animated: true, completion: nil)
//                })
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
        return viewModel.numberOfSuggsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(suggCellIdentifier, forIndexPath: indexPath) as! SuggCell
        
//        cell.actionLabel.text = viewModel.titleAtIndexPath(indexPath)
        cell.whereLabel.text = viewModel.whereAtIndexPath(indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(filterCellIdentifier, forIndexPath:indexPath)
        return cell
        //dequeueReusableCellWithIdentifier(suggCellIdentifier, forIndexPath: indexPath) as! SuggCell
        }
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        
//    }
}
