//
//  WelcomeSuggCell.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/14/16.
//  Copyright © 2016 tycoon. All rights reserved.
//
import Argo
import ReactiveCocoa
import Result

class WelcomeSuggCell: UITableViewCell {
    
    @IBOutlet weak var bkgroundImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel: WelcomeSuggModel? {
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
        self.actionLabel.text = self.viewModel?.action
        self.titleLabel.text = self.viewModel?.title

        
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
