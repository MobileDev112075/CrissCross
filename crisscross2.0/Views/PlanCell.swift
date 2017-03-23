//
//  TimelineCell.swift
//  RacCriss
//
//  Created by tycoon on 11/7/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import ReactiveCocoa
import Result

class PlanCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bkgroundImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var fromtillLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    
    var viewModel: PlanCellViewModel? {
        didSet {
            self.configureFromViewModel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func configureFromViewModel() {
        self.actionLabel.text = ""
        self.titleLabel.text = self.viewModel?.title
        self.whereLabel.text = self.viewModel?.item_title
        self.timeLabel.text = self.viewModel?.timeC
        self.bkgroundImageView.image = self.viewModel?.image
        self.avatarImageView.image = nil
        self.avatarImageView.layer.cornerRadius = 18
        self.avatarImageView.clipsToBounds = true
        
    }
    
    private func prepareForReuseSignal() -> Signal<(), NoError> {
        return Signal { observer in
            self.rac_prepareForReuseSignal // reactivecocoa builtin function
                .toSignalProducer() // obj-c RACSignal -> swift SignalProducer
                .map { _ in () } // AnyObject? -> Void
                .flatMapError { _ in .empty } // NSError -> NoError
                .start(observer)
        }
    }
}
