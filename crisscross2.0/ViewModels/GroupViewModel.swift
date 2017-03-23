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

class ProfileViewModel  {
    
    // Inputs
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>
    
    // Outputs
    let title: String
    let profileName: String
    let profileLocation: String
    let myUser = MutableProperty<User?>(nil)
    let alertMessageSignal: Signal<String, NoError>
    
    private let store: StoreType
    private let uid: String
    private let alertMessageObserver: Observer<String, NoError>
    
    init(store: StoreType, userid: String) {
        
        self.store  = store
        self.uid    = userid
        self.title  = "My Profile"
        self.profileName = (Shared.MyInfo.loginUser.value?.name)!
        self.profileLocation = (Shared.MyInfo.loginUser.value?.home_town)!

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
                return store.fetchUser(self.uid)
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: nil)
                }
            })
            .on(next: { _ in Shared.MyInfo.userLoader.value = false })
            .startWithNext({(tuser) in
                if let user = tuser
                {
//                    Shared.MyInfo.user.value = user
                }
                })
        
    
    }
}
