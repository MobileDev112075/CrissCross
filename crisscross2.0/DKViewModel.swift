//
//  DKViewModel.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 1/26/17.
//  Copyright © 2017 tycoon. All rights reserved.
//


import ReactiveCocoa
import Result

class DKViewModel  {
    
    var myStore: StoreType
    
    let alertMessageObserver: Observer<String, NoError>


    // Inputs
    
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>

    // Outputs
    
    var title: String
    let refreshSignal: Signal<Void, NoError>
    let alertMessageSignal: Signal<String, NoError>
    let isLoading: MutableProperty<Bool>
    
    // MARK: - Lifecycle
    
    init(store: StoreType) {
        
        myStore = store
        title = ""
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshSignal = refreshSignal
        self.refreshObserver = refreshObserver
        
    
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        // Trigger refresh when view becomes active
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
    }
}
