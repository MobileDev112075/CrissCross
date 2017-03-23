//
//  TimelineViewModel.swift
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

class TimelineViewModel {
    

    
    // Inputs
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>
    
    
    // Outputs
    let title: String
    let timelines: MutableProperty<[Timeline]>
    let isLoading: MutableProperty<Bool>
    let alertMessageSignal: Signal<String, NoError>
    
    // Actions
//    lazy var deleteAction: Action<NSIndexPath, Bool, NSError> = { [unowned self] in
//        return Action({ indexPath in
//            let match = self.matchAtIndexPath(indexPath)
//            return self.store.deleteMatch(match)
//        })
//        }()
    
    private let store: StoreType
    private let alertMessageObserver: Observer<String, NoError>
 
    
    // MARK: - Lifecycle
    
    init(store: StoreType) {
        self.title = "Timeline"
        self.store = store
        
//        if let user =  Shared.MyInfo.showFriendsTree.value.last,
//            let dtimelines = user.timelines {
//            self.timelines = MutableProperty(dtimelines)
//        }else{
            self.timelines = MutableProperty([])
//        }
        
        
        
        let (_, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        // Trigger refresh when view becomes active
      
        
        SignalProducer(signal: Shared.MyInfo.showFriendsTree.signal)
            .startWithNext { [weak self] (users) in
//                if let duser = users.last,
//                let timelines = duser.timelines
//                {
//                    self?.timelines.value = timelines
//                }
        }
    }
    
    private func timelineAtIndexPath(indexPath: NSIndexPath) -> Timeline {
        return timelines.value[indexPath.row]
    }
    
    func actionAtIndexPath(indexPath: NSIndexPath) -> String {
        let timeline = timelineAtIndexPath(indexPath)
        return timeline.time_type
    }
    
    func childAtIndexPath(indexPath: NSIndexPath) -> Children?
    {
        let timeline = timelineAtIndexPath(indexPath)
        return timeline.bt
    }
    
    func timeObjAtIndexPath(indexPath: NSIndexPath) -> Timeline?
    {
        let timeline = timelineAtIndexPath(indexPath)
        return timeline
    }
    

    // MARK: - Data Source
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfTimelinesInSection(section: Int) -> Int {
        return timelines.value.count
    }
    
    func firstLastAtIndexPath(indexPath: NSIndexPath) -> String {
        let timeline = timelineAtIndexPath(indexPath)
        return timeline.time_l1 ?? ""
    }
    
    func actionLocationAtIndexPath(indexPath: NSIndexPath) -> String {
        let timeline = timelineAtIndexPath(indexPath)
        return timeline.time_l2 ?? ""
    }

    func whenAtIndexPath(indexPath: NSIndexPath) -> String {
        let timeline = timelineAtIndexPath(indexPath)
        return timeline.time_l3 ?? ""
    }

}

