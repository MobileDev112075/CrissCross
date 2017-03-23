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

class SuggCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bkgroundImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconView: IconView!
    
    var viewModel: SuggCellViewModel? {
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
        self.iconView.iconLabel.text = self.viewModel?.categoryType
        self.iconView.iconImageView.image = self.viewModel?.categoryImage
        self.avatarImageView.image = nil
        self.avatarImageView.clipsToBounds = true
        
        self.viewModel?.backImage
            .takeUntil(self.prepareForReuseSignal()) //stop fetching if cell gets reused
            .observeOn(UIScheduler())
            .startWithResult({[weak self] in
                switch $0 {
                case let .Success(image):
                        self?.bkgroundImageView.image = image
                case .Failure(_):
                        self?.bkgroundImageView.image = nil
                }})
       
        self.viewModel?.avatar
            .takeUntil(self.prepareForReuseSignal()) //stop fetching if cell gets reused
            .observeOn(UIScheduler())
            .startWithResult({[weak self] in
                switch $0 {
                case let .Success(image,name):
                    self?.avatarImageView.image = image
                    self?.actionLabel.text = name
                case .Failure(_):
                    self?.avatarImageView.image = nil
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
