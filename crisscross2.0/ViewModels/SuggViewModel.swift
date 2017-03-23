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

enum FilterType {
    case Nearby
    case Mine
    case Freinds
    case Activity
}


class Filter {

    let name:String = ""
    let filerType:FilterType
    
    init(filerType:FilterType) {
        self.filerType = filerType
    }
}

class SuggViewModel {
    
    // Inputs
//    let allFiltersArray = [FilterNearby(),FilterMine(),FilterFriends(),FilterActivity()]
    let active = MutableProperty(false)
    let refreshObserver: Observer<Void, NoError>
    
    // Outputs
    let title: String
    let suggsParent: MutableProperty<[Beenthere]>
    let suggsChild: MutableProperty<[Children]>
    let filtersAct: MutableProperty<[Filter]>
    
    let isLoading: MutableProperty<Bool>
    let alertMessageSignal: Signal<String, NoError>
    
    private let store: StoreType
    private let alertMessageObserver: Observer<String, NoError>
    
    
    // MARK: - Lifecycle
    
    init(store: StoreType) {
        self.title = "Suggestions"
        self.store = store
     
        
        
        self.suggsChild = MutableProperty([])
        self.suggsParent = MutableProperty([])
        self.filtersAct = MutableProperty([])
        
        let (_, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        // Trigger refresh when view becomes active
        
        SignalProducer(signal: Shared.MyInfo.user.signal)
            .startWithNext{[weak self] (user) in
                if  let duser = user,
                    let suggs = duser.beenTheres
                {
//                    self?.suggsParent.value = suggs
//                    let allBeenWithChildren = suggs.filter{$0.children != nil}
//                    let allChildren = allBeenWithChildren.map{$0.children}.flatMap{$0}.sort{$0.created > $1.created}
//                    self?.suggsChild.value = allChildren
                }
        }
        
        
     }
    
    //    lazy var nearbyAction: Action<Void, Bool, NSError> = { [unowned self] in
    //        return Action(enabledIf: self.inputIsValid, { _ in
    //            let parameters = LoginParameters(
    //                email: self.loginEmail.value,
    //                pass: self.loginPass.value
    //            )
    //            return self.store.loginUser(parameters)
    //                .map{ data, response in
    //                    if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []){
    //                        if  let statusJson = json["status"]{
    //                            if statusJson == 2 {
    //                                self.alertMessageObserver.sendNext(json)
    //                                return false
    //                            }
    //                            if statusJson == 1,
    //                                let ujson = json["user"]
    //                            {
    //                                let user:User? = decode(ujson)
    //                                self.myUser.value = user
    //                                LocalStore().saveToken(user!.token!)
    //                                return true
    //                            }
    //                        }
    //                    }
    //                    return false
    //            }
    //        })
    //        }()
    
    
    //    lazy var nearbyAction: Action<Void, Bool, NSError> = { [unowned self] in
    //        let allBeenWithChildren = self.suggsParent.value.filter{$0.children != nil}
    //        let allChildren = allBeenWithChildren.map{$0.children!}.flatMap{$0}.sort{$0.created > $1.created}
    //        self.suggsChild.value = allChildren
    //        return true
    //        }()
    
    
    
    func filterAct(filter:Filter)  {
//        let allBeenWithChildren = self.suggsParent.value.filter{$0.children != nil}
//        var allChildren : [Children] = []
//        switch filter.filerType {
//            case .Nearby: break
//            case .Mine: break
//            case .Freinds:
////                let friendsArray:[fr] =
//            break
//            case .Activity:
//                allChildren = allBeenWithChildren.map{$0.children!}.flatMap{$0}.sort{$0.created > $1.created}
//            break
//        }
//        
//        self.suggsChild.value = allChildren
    }
    

    // MARK: - Data Source
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfSuggsInSection(section: Int) -> Int {
        return suggsChild.value.count
    }
    
    func titleAtIndexPath(indexPath: NSIndexPath) -> String {
        let sugg = suggsAtIndexPath(indexPath)
//        if let title = sugg.title {
//            return title
//        }
        return ""
    }
    
    func whereAtIndexPath(indexPath: NSIndexPath) -> String {
        let sugg = suggsAtIndexPath(indexPath)
//        if let wherelocation = sugg.title {
//            return wherelocation
//        }
        return sugg.title
    }
    
    
    
    // MARK: Internal Helpers
    
    private func suggsAtIndexPath(indexPath: NSIndexPath) -> Children {
        return suggsChild.value[indexPath.row]
    }
    
    private func separatedNamesForPlayers(players: [Player]) -> String {
        let playerNames = players.map { player in player.name }
        return playerNames.joinWithSeparator(", ")
    }
}

