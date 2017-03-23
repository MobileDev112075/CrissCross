//
//  ProfileViewModel.swift
//  RacCriss
//
//  Created by tycoon on 11/7/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import ReactiveCocoa
import Result

class GroupViewModel  {
    
    // Inputs
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>
    
    // Outputs

    let profileName: String
    let profileLocation: String
    
    let myGroups = MutableProperty<[Group]>([])
    let alertMessageSignal: Signal<String, NoError>
    
    private let store: StoreType
//    private let uid: String
    private let alertMessageObserver: Observer<String, NoError>
    
    init(store: StoreType) {
        
        self.store  = store
//        self.uid    = userid

        self.profileName = (Shared.MyInfo.myLoginUser.value?.name)!
        self.profileLocation = (Shared.MyInfo.myLoginUser.value?.home_town)!

        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        SignalProducer(signal: refreshSignal)
            .on(next: { _ in Shared.MyInfo.userLoader.value = true })
            .flatMap(.Latest, transform: { _ in
                return store.fetchGroups()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])
                }
            })
            .on(next: { _ in Shared.MyInfo.userLoader.value = false })
            .startWithNext({(groups) in
                self.myGroups.swap(groups)
                })
    }
    
    
    // MARK: - Data Source
    
    func cellIdentifier(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath)
        if let label = cell.viewWithTag(10) as? UILabel {
            let group = myGroups.value[indexPath.row]
            label.text = group.title
        }
        return cell
    }
    

    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfChildrenInSection(section: Int) -> Int {
        return myGroups.value.count
    }
    
        
}
