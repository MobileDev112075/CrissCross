//
//  DreamViewController.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 1/21/17.
//  Copyright © 2017 tycoon. All rights reserved.
//

import DZNEmptyDataSet
import ReactiveCocoa
import Result

class DreamViewController: UIViewController {

    @IBOutlet var dreamingView: DreamingView!
    
    private let childCellIdentifier = "ChildCell"
    private let filterSectionCellIdentifier = "FilterSectionCell"
    
    @IBAction func dissmisBT(sender: UIButton) {
        self.dissmis()
    }

    private let refreshControl = UIRefreshControl()
    private let viewModel: DreamViewModel
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = DreamViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        self.title = viewModel.title
        viewModel.active <~ isActive()
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext(
                { [weak self] _ in
                guard let dreamingView = self?.dreamingView else { return }
                    dreamingView.dreams = self?.viewModel.dictionary
                    dreamingView.doRefreshTagCloud()
                })
        
    }
    
    @IBAction func editTap(sender: UIButton) {
        self.goEdit()
    }
    
    func goEdit() {
        self.performSegueWithIdentifier("GoEdit", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let edit = segue.destinationViewController as? DreamEditController {
            edit.viewModel = self.viewModel
        }
    }
}
