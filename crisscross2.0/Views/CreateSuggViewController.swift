//
//  CreateSuggViewController.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 12/3/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SnapKit

class CreateSuggViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    

    @IBOutlet weak var titleLabel:      UILabel!
    
    @IBOutlet weak var searchField:     UITextField!
    @IBOutlet weak var answerTableView: UITableView!
    @IBOutlet weak var cityImageView:   UIImageView!
    @IBOutlet weak var sectionsView:    UIView!
    
    private let viewModel: CreateSuggModel
    
    // MARK: - Lifecycle
    
    @IBAction func backTap(sender: UIButton) {
        if viewModel.goback(){
            self.dissmis() 
        }else{
            searchField.text = ""
            searchField.attributedPlaceholder =
                NSAttributedString(string: "Enter City Name", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()])
            sectionsView.hidden = true
            searchField.userInteractionEnabled = true
        }
    }
    

    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = CreateSuggModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        answerTableView.tableFooterView = UIView() // Prevent empty rows at bottom
        self.searchField.becomeFirstResponder()
        self.searchField.attributedPlaceholder =
            NSAttributedString(string: "Enter City Name", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()])
        self.sectionsView.hidden = true
        bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    private func bindViewModel() {
        viewModel.active <~ isActive()
        viewModel.seacrhCity <~ searchField.signalProducer()
        
        MainSuggSection.placeReady.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self] ready in
                if (ready != nil){
                    self?.searchField.resignFirstResponder()
                    self?.sectionsView.hidden = false
                }else{
                    self?.searchField.becomeFirstResponder()
                    self?.sectionsView.hidden = true
                }
        })

        MainSuggSection.updateFeedback.signal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] _ in
                self?.dissmis()
            })
        
        viewModel.titleSignal.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self] title in
                guard let titleLabel = self?.titleLabel else { return }
                titleLabel.text = title
                })
        
        viewModel.searchTitle.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self] title in
                guard let searchField = self?.searchField else { return }
                searchField.text = title
                })
        
        viewModel.selectedCitySignal.signal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] _ in
                if (self?.viewModel.gfilter.type == .City){
                guard let searchField = self?.searchField else { return }
                searchField.text = ""
                searchField.attributedPlaceholder =
                    NSAttributedString(string: "Enter Suggestion Name", attributes:[NSForegroundColorAttributeName : UIColor.grayColor()])
                }
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
