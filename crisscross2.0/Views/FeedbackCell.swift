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

class FeedbackCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage:     UIImageView!
    @IBOutlet weak var actionLabel:     UILabel!
    @IBOutlet weak var titleLabel:      UILabel!
    @IBOutlet weak var categoryButton:  UIButton!
    
    @IBAction func profileTap(sender: AnyObject) {
       self.viewModel?.goProfile()
        
    }
    
    var viewModel: FeedbackCellModel? {
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
        self.actionLabel.text   = self.viewModel?.comment
        self.titleLabel.text    = self.viewModel?.name
        
        self.categoryButton.setTitle(self.viewModel?.types, forState: .Normal)
        self.viewModel?.avatar
            .takeUntil(self.prepareForReuseSignal()) //stop fetching if cell gets reused
            .observeOn(UIScheduler())
            .startWithResult({[weak self] in
                switch $0 {
                case let .Success(image):
                    self?.avatarImage.image = image.0
                case .Failure(_):
                    self?.avatarImage.image = nil
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
