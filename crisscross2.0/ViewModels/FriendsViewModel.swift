//
//  FriendsViewModel.swift
//  RacCriss
//
//  Created by tycoon on 11/7/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import ReactiveCocoa
import Result

import ReactiveCocoa
import Result

class FriendsViewModel {
    
    
    private let friendCellIdentifier = "FriendCell"
    // Inputs
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>
    
    // Outputs
    let title: String
    let isLoading: MutableProperty<Bool>
    let alertMessageSignal: Signal<String, NoError>
    let refreshSignal: Signal<Void, NoError>
    // Actions
    
    private let store: StoreType
    private let alertMessageObserver: Observer<String, NoError>
    private var friends:[Friend] = []
    
    // MARK: - Lifecycle
    
    init(store: StoreType) {
        self.title = "Friends"
        self.store = store
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshSignal = refreshSignal
        self.refreshObserver = refreshObserver
    
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        Shared.MyInfo.showUserFriends.producer.startWithNext { [weak self] (friends) in
            self?.friends = friends
            self?.refreshObserver.sendNext()
        }
        
        // Trigger refresh when view becomes active
    }
    
    //
    // MARK: - Data Source
    
    func showFriendProfile(indexPath:NSIndexPath) {
        let friend = friends[indexPath.row]
        Shared.MyInfo.showFriendsTree.value.append(friend)
    }
    
    
    func cellIdentifier(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell    = tableView.dequeueReusableCellWithIdentifier(friendCellIdentifier, forIndexPath: indexPath) as! FriendCell
        let friend  = friendAtIndexPath(indexPath)
        cell.viewModel = FriendCellViewModel(friend: friend)
        return cell
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfTimelinesInSection(section: Int) -> Int {
        return friends.count
    }
    
    func friendAtIndexPath(indexPath: NSIndexPath) -> Friend {
        return friends[indexPath.row]
    }
    
}

