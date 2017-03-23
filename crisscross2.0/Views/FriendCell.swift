//
//  FriendCell.swift
//  RacCriss
//
//  Created by tycoon on 11/7/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import UIKit
import Argo
import Result
import Alamofire
import AlamofireImage
import ReactiveCocoa

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var homeTown: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var viewModel: FriendCellViewModel? {
        didSet {
            self.configureFromViewModel()
        }
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    private func configureFromViewModel() {
        self.actionLabel.text = self.viewModel?.first
        self.titleLabel.text = self.viewModel?.last
        self.avatarImageView.image = nil
        self.avatarImageView.clipsToBounds = true
        
        
        self.viewModel?.fetchImageSignal()
            .takeUntil(self.prepareForReuseSignal()) //stop fetching if cell gets reused
            .observeOn(UIScheduler())
            .startWithResult({[weak self] in
                switch $0 {
                case let .Success(image):
                    self?.avatarImageView.image = image
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

