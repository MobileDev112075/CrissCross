//
//  ProfileViewController.swift
//  RacCriss
//
//  Created by tycoon on 11/6/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SnapKit
import Popover


class ProfileViewController: UIViewController {
    
    @IBOutlet var menuView: UIView!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var menuBT:              UIButton!
    @IBOutlet weak var nameLable:           UILabel!
    @IBOutlet weak var locationLabel:       UILabel!
    @IBOutlet weak var friendsBT:           UIButton!
    @IBOutlet weak var timelineBT:          UIButton!
    
    private let viewModel: ProfileViewModel
    private var popover:Popover?
    private var listen = true
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = ProfileViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.active <~ isActive()
        
        self.viewModel
            .friendsIsValid.producer
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (gotFriends) in
                self?.friendsBT.hidden = !gotFriends
            }
        
        self.viewModel
            .timeIsValid.producer
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (gotActiv) in
                self?.timelineBT.hidden = !gotActiv
        }
        
        self.viewModel
            .refreshSignal
            .filter { self.listen }
            .observeOn(UIScheduler())
            .observeNext {[weak self] _ in
                self?.title =                self?.viewModel.title
                self?.nameLable.text =       self?.viewModel.profileName
                self?.locationLabel.text =   self?.viewModel.profileLocation
                self?.userAvatarImageView.image = self?.viewModel.profileAvatar
                
        }        
    }
    
    @IBAction func dissmisTP(sender:UIButton) {
        self.listen = false
        self.viewModel.dismiss()
        self.dissmis()  
    }
    
    @IBAction func menuTP(sender:UIButton) {
        let options = [
            .Type(.Down),
            .AnimationIn(0.3),
            .OverlayBlur(.Dark),
            .ArrowSize(CGSizeZero),
            .Color(UIColor.darkTextColor())
            ] as [PopoverOption]
        
        popover = Popover(options: options,
                          showHandler:nil,
                          dismissHandler: nil)
        
        popover!.show(self.menuView , fromView: self.menuBT)
    }
    
    @IBAction func friendsTap(sender:UIButton) {
        self.performSegueWithIdentifier("GoFriends", sender: nil)
    }
    @IBAction func addToFav(sender:UIButton) {
        popover!.dismiss()
    }
    @IBAction func addToGroup(sender:UIButton) {
        popover!.dismiss()
    }
    @IBAction func removeF(sender:UIButton) {
        popover!.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
