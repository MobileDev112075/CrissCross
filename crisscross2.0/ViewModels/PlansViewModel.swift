//
//  PlansViewModel.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import ReactiveCocoa
import Result

//protocol FiltersType {
//    func theName() -> String
//}

enum PlanFilterType:String {
    case Activity = "Activity", Upcoming = "Upcoming", MyPlans = "My Plans", RecentAdds = "Recent Adds"
}

class PlansViewModel {
    
    typealias PlanChangeset = Changeset<Plan>
    
    // Inputs
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>
    
    // Outputs
    let title: String
    let contentChangesSignal: Signal<PlanChangeset, NoError>
    
    let isLoading: MutableProperty<Bool>
    let alertMessageSignal: Signal<String, NoError>

    private let store: StoreType
    private let contentChangesObserver: Observer<PlanChangeset, NoError>
    private let alertMessageObserver: Observer<String, NoError>
    private var plans: [Plan]
    private let plansFiltersArray:[PlanFilterType]
    
    // MARK: - Lifecycle
    
    init(store: StoreType) {
        self.title = "Plans"
        self.store = store
        self.plans = []
        
        self.plansFiltersArray = [
                PlanFilterType.Activity,
                PlanFilterType.Upcoming,
                PlanFilterType.MyPlans,
               PlanFilterType.RecentAdds]
        
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        let (contentChangesSignal, contentChangesObserver) = Signal<PlanChangeset, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
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
        
        
        SignalProducer(signal: refreshSignal)
            .on(next: { _ in isLoading.value = true })
            .flatMap(.Latest) { _ in
                return store.fetchPlans()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])
                }
            }
            .on(next: { _ in isLoading.value = false })
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldPlans, newPlans) in
                self?.plans = newPlans
                if let observer = self?.contentChangesObserver {
                    let changeset = Changeset(
                        oldItems: oldPlans,
                        newItems: newPlans,
                        contentMatches: Plan.contentPlans
                    )
                    observer.sendNext(changeset)
                }
                })
        
    }
    
    // MARK: - Data Source
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func planAtIndexPath(indexPath: NSIndexPath) -> Plan {
        return plans[indexPath.row]
    }
    
    
    func numberOfPlansInSection(section: Int) -> Int {
        return plans.count
    }
    
    // MARK: - Collection data Source
    
    func numberOfFiltersSection() -> Int {
        return 1
    }
    
    func numberOfFiltersInSection(section: Int) -> Int {
        return plansFiltersArray.count
    }
    
    
    func filterAtIndexPath(indexPath: NSIndexPath) -> PlanFilterType {
        return plansFiltersArray[indexPath.row]
    }

    

    
}
