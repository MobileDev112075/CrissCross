//
//  AllPlanViewModel
//  RacCriss
//
//  Created by tycoon on 11/13/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import Result
import ReactiveCocoa
import GooglePlaces
import CoreLocation

class AllPlanViewModel {

    
    static let heightForChildHeaderInSection:CGFloat = 0
    static let heightForChildRowAtIndexPath:CGFloat = 154
    
    static let heightForHeaderInSection:CGFloat = 30
    static let heightForRowAtIndexPath:CGFloat = 126
    
    // Inputs
    let active =            MutableProperty(false)
    let refreshObserver:    Observer<Void, NoError>
    var filterSections      = MutableProperty<[[FilterModel]]>([])
    var filterTreeHistory   = MutableProperty<[(Int,Int)]>([])
    
    // Outputs
    let title: String
    let isLoading:              MutableProperty<Bool>
    let alertMessageSignal:     Signal<String, NoError>
    let contentChangesSignal:   Signal<Void, NoError>
    let oneSelectionSignal:     Signal<Children, NoError>
    
    let plansMP: MutableProperty<[Plan]>
    
    // Actions
    
    private let store: StoreType
    private let localStore: StoreType
    
    private let oneSelectionObserver:   Observer<Children, NoError>
    private let alertMessageObserver:   Observer<String, NoError>
    private let contentChangesObserver: Observer<Void, NoError>
    private var plans:  [Plan]
    
    private let fetchDone = MutableProperty(false)
    
    // MARK: - Lifecycle
    
    init(store: StoreType) {
        
        self.title = "Plans"
        self.store = store
        self.localStore = Shared.MyInfo.localStore
        
        self.plans = []
        self.plansMP = MutableProperty([])

        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        let (contentChangesSignal, contentChangesObserver) = Signal<Void, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        let (oneSelectionSignal, oneSelectionObserver) = Signal<Children, NoError>.pipe()
        self.oneSelectionSignal = oneSelectionSignal
        self.oneSelectionObserver = oneSelectionObserver
        
        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        let isLoading = MutableProperty(true)
        self.isLoading = isLoading
        
        LocationManager.sharedInstance.startUpdatingLocation()
        
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        MainSection.planSavedResult.0
            .observeNext { [weak self] (newPlans) in
                self?.plans = newPlans
                self?.addLocationsMeta()
        }
        
        SignalProducer(signal: refreshSignal)
            .on(next: { _ in isLoading.value = true })
            .flatMap(.Latest) { _ in
                return store.fetchPlans()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])}}
            .on(next: { _ in isLoading.value = false })
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldPlans, newPlans) in
                self?.plans = newPlans
                self?.addLocationsMeta()
                self?.fetchDone.swap(true)
                })
        
        
        fetchDone.producer
            .filter { $0 }
            .map { _ in () }
            .on(next: { _ in isLoading.value = false })
            .startWithNext {
                self.filterSections.swap([Shared.MyInfo.allFilterModels["FilterPlans"]!])
                self.filterTreeHistory.swap([(0,3)])
        }
    }
    
    

    func addLocationsMeta()
    {
        dispatch_async(dispatch_get_main_queue(),{
            self.store.fetchGPlaceImageMeta(self.plans)
                .on(next:
                    { (locations:[LocationImage]) in
                        self.addLocationsImage(locations)
                })
                .start()
        })
    }
    
    func addLocationsImage(locations:[LocationImage])
    {
        dispatch_async(dispatch_get_main_queue(),{
            self.store.fetchGPlaceImageD(locations)
                .on(next:{
                        self.contentChangesObserver.sendNext()
                })
                .start()
        })
    }
    
    


    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfChildrenInSection(section: Int) -> Int {
        return plans.count
    }
    
    func childAtIndexPath(indexPath: NSIndexPath) -> Plan {
        return plans[indexPath.row]
    }

}


