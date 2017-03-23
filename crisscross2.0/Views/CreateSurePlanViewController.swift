//
//  CreateSurePlanViewController.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/26/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SnapKit

class CreateSurePlanViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var searchField:     UITextField!
    @IBOutlet weak var answerTableView: UITableView!
    @IBOutlet weak var cityImageView:   UIImageView!
    @IBOutlet weak var calendarView:    UIView!
    
    private let viewModel:              CreateSurePlanModel
    
    // MARK: - Lifecycle
    
    @IBAction func backTap(sender: UIButton) {
        if viewModel.goback(){
            self.dismissViewControllerAnimated(true, completion: {})
        }else{
            searchField.text = ""
            calendarView.hidden = true
            searchField.userInteractionEnabled = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = CreateSurePlanModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        answerTableView.tableFooterView = UIView() // Prevent empty rows at bottom
        self.searchField.becomeFirstResponder()
        self.calendarView.hidden = true
        bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    private func bindViewModel() {
        viewModel.active <~ isActive()
        viewModel.seacrhCity <~ searchField.signalProducer()
        
        viewModel.titleSignal.signal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] title in
                guard let searchField = self?.searchField else { return }
                searchField.text = title
                guard let calendarView = self?.calendarView else { return }
         
                calendarView.hidden = false
                guard let tableView = self?.answerTableView else { return }
                tableView.reloadData()
                })
        
        viewModel.selectedPlaceSignal.signal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] _ in
                guard let searchField = self?.searchField else { return }
                searchField.userInteractionEnabled = false
                })
        
        viewModel.searchFetchResults.signal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] _ in
                guard let tableView = self?.answerTableView else { return }
                tableView.reloadData()
                })
        
        viewModel.cityImage.signal
            .observeOn(UIScheduler())
            .observeNext {  [weak self] (image) in
                guard let cityImageView = self?.cityImageView else { return }
                guard let image = image else {return}
                cityImageView.image = image
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return viewModel.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSectionsInTableView(tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableView(tableView, numberOfRowsInSection: section)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }

}
