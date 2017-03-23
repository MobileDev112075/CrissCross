//
//  DashboardTableViewController.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/21/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//


import UIKit
import ReactiveCocoa
import SnapKit

class WelcomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var citylb: UILabel!
    @IBOutlet weak var placelb: UILabel!
    @IBOutlet weak var navBar: UIView!
    
    @IBOutlet weak var caret: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private let viewModel: WelcomeViewModel
    
    private let profileCellIdentifier   = "Profile"
    private let welcomeCellIdentifier   = "Welcome"
    private let friendsCellIdentifier   = "Friends"
    private let notifyCellIdentifier    = "Notify"
    private let plansCellIdentifier     = "Plans"
    private let suggCellIdentifier      = "Sugg"
   
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = WelcomeViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    @IBAction func tapDown(sender: UIButton) {
        if sender.selected{
            sender.selected = false
            let a = NSIndexPath(forRow:0 , inSection:0 )
            self.tableView.scrollToRowAtIndexPath(a, atScrollPosition: .Top, animated: true)
            return
        }
        sender.selected = true
        let sec = viewModel.numberSection()-1
        let row = viewModel.numberOfRowsInSection(sec)-1
        let a = NSIndexPath(forRow:row , inSection:sec )
        self.tableView.scrollToRowAtIndexPath(a, atScrollPosition: .Bottom, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func bindViewModel() {
        self.title = viewModel.title
        
        viewModel.active <~ isActive()
        
    
        viewModel.showRefresh.signal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] changeset in
                guard let tableView = self?.tableView else { return }
                guard let changeset = changeset else { return }
                self?.loader.stopAnimating()
                self?.placelb.text = (self?.viewModel.itinNu())!+" "+(self?.viewModel.itinText())!
                self?.citylb.text = LocationManager.sharedInstance.currentCity
                if changeset.count > 0 {
                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(changeset, withRowAnimation: .Fade)
                tableView.endUpdates()
                }})
        
        Shared.MyInfo.myAvatar.producer
            .observeOn(UIScheduler())
            .startWithResult {[weak self] (result) in
                guard let tableView = self?.tableView else { return }
                let indx =  NSIndexPath(forRow:0, inSection:6)
                tableView.beginUpdates()
                tableView.reloadRowsAtIndexPaths([indx], withRowAnimation: .Fade)
                tableView.endUpdates()
        }

        viewModel.oneSelectionSignal
            .observeOn(UIScheduler())
            .observeNext { (child) in
                self.performSegueWithIdentifier("ShowOne", sender:LocationChild(child: child))
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return viewModel.numberSection()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell!
        switch indexPath.section
        {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(welcomeCellIdentifier,   forIndexPath: indexPath)
            viewModel.welcomeCell(cell)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(friendsCellIdentifier,   forIndexPath: indexPath)
            
            let fnlbl =     cell.contentView.viewWithTag(1) as! UILabel
            let ftlbl =     cell.contentView.viewWithTag(2) as! UILabel
            let itnlbl =    cell.contentView.viewWithTag(3) as! UILabel
            let ittlbl =    cell.contentView.viewWithTag(4) as! UILabel
            
            fnlbl.text  = viewModel.friendsNu()
            ftlbl.text  = viewModel.friendsText()
            itnlbl.text = viewModel.itinNu()
            ittlbl.text = viewModel.itinText()
            
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(notifyCellIdentifier, forIndexPath: indexPath)
        case 3:
            let cell = viewModel.welcomeInfoCell(tableView,cellForRowAtIndexPath:indexPath)
            return cell
        case 4: cell = tableView.dequeueReusableCellWithIdentifier(plansCellIdentifier,     forIndexPath: indexPath)
        case 5: cell = tableView.dequeueReusableCellWithIdentifier(suggCellIdentifier,      forIndexPath: indexPath)
        case 6: cell = tableView.dequeueReusableCellWithIdentifier(profileCellIdentifier,   forIndexPath: indexPath)
            let bkimg = cell.contentView.viewWithTag(1) as! UIImageView
            if let img = Shared.MyInfo.myAvatar.value {
                bkimg.image = img
            }
        default: cell = tableView.dequeueReusableCellWithIdentifier(welcomeCellIdentifier,  forIndexPath: indexPath)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section
        {
        case 0: return 75
        case 1: return 50
        case 2: return 50
        case 3: return 70
        case 4: return self.view.frame.height/3
        case 5: return self.view.frame.height/3
        case 6: return self.view.frame.height/3
        default: return 75
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 3 {
            viewModel.goShowOneSugg(indexPath)
        }
        if indexPath.section == 4 {
            self.performSegueWithIdentifier("GoPlan", sender: nil)
        }
        if indexPath.section == 5 {
            self.performSegueWithIdentifier("GoSugg", sender: nil)
        }
        if indexPath.section == 6 {
            self.performSegueWithIdentifier("GoProfile", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let str = segue.identifier{
            if str == "GoFriends" {
                viewModel.showCloseFriends()
            }
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y<50){
             self.caret.selected = false
        UIView.animateWithDuration(0.4, animations: {
            self.navBar.alpha = 0
            self.citylb.alpha = 0
            self.placelb.alpha = 0
        })
        }else{
            self.caret.selected = true
            UIView.animateWithDuration(0.4, animations: {
                self.navBar.alpha = 0.55
                self.citylb.alpha = 1
                self.placelb.alpha = 1
            })
        }
    }
    
}
