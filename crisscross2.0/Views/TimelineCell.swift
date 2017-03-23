//
//  TimelineCell.swift
//  RacCriss
//
//  Created by tycoon on 11/7/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import DZNEmptyDataSet
import ReactiveCocoa
import Result


class TimelineCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bkgroundImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var viewModel: TimelineCellViewModel? {
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
        
        self.actionLabel.text = self.viewModel?.item_title
        self.titleLabel.text = self.viewModel?.title
        self.whereLabel.text = self.viewModel?.timeC

        self.avatarImageView.image = nil
        self.avatarImageView.clipsToBounds = true
        
        self.viewModel?.fetchImageSignal()
            .takeUntil(self.prepareForReuseSignal()) //stop fetching if cell gets reused
            .observeOn(UIScheduler())
            .startWithResult({[weak self] in
                switch $0 {
                case let .Success(image):
                    self?.bkgroundImageView.image = image
                case .Failure(_):
                    self?.bkgroundImageView.image = nil
                }})
        
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
