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

class LocationCell: UITableViewCell {
    

    @IBOutlet weak var bkgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
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

        self.titleLabel.text = self.viewModel?.item_title
        self.iconView.iconLabel.text = self.viewModel?.categoryType
        self.iconView.iconImageView.image = self.viewModel?.categoryImage
        
        self.bkgroundImageView.image = nil
        
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
