//
//  GroupViewController.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 1/16/17.
//  Copyright © 2017 tycoon. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SnapKit

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let viewModel: GroupViewModel
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBAction func dissmisTP(sender: UIButton){
        self.dissmis()  
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = GroupViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.tableFooterView = UIView()
        bindViewModel()
    }
        
    private func bindViewModel() {
        viewModel.active <~ isActive()
        viewModel.myGroups.signal
        .observeOn(UIScheduler())
        .observeNext { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
//        viewModel.didSelectRowAtIndexPath(indexPath)
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
