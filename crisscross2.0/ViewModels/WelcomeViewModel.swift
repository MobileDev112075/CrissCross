//
//  DashboardViewModel.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/31/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import ReactiveCocoa
import Result
import GooglePlaces

class WelcomeViewModel:DKViewModel {
    
    
    // Outputs
    let showRefresh = MutableProperty<[NSIndexPath]?>(nil)
    let myUser = MutableProperty<User?>(nil)
    
    let oneSelectionSignal: Signal<Children, NoError>
    let showOneSugg = MutableProperty<Children?>(nil)

    var showItin:Itin?
    
    private let cityID = MutableProperty<String>("")
    private let infoCellIdentifier = "Info"
    private var callWeather:Bool = true

    private let oneSelectionObserver:Observer<Children, NoError>
    
    override init(store: StoreType) {
        let (oneSelectionSignal, oneSelectionObserver) = Signal<Children, NoError>.pipe()
        self.oneSelectionSignal = oneSelectionSignal
        self.oneSelectionObserver = oneSelectionObserver
   
        super.init(store: store)
        
        LocationManager.sharedInstance.startUpdatingLocation()
        
        self.title = "Dashboard"

        let userid = Shared.MyInfo.myIdentifier
 
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        SignalProducer(signal: refreshSignal)
            .on(next: { _ in self.isLoading.value = true})
            .flatMap(.Latest, transform: { _ in
                return store.fetchUser(userid)
                    .flatMapError { error in
                        return SignalProducer(value: nil)
                }
            })
            .on(next: { _ in self.isLoading.value = false})
            .startWithNext({(tuser) in
                
                if let user = tuser {
                    Shared.MyInfo.myLoginUser.value = user
                }})

        cityID.producer
            .filter { $0.characters.count > 4 }
            .startWithNext { (lid) in
                store.fetchSuggByLocation(lid).on(next: { (nearmes) in
                Shared.MyInfo.myNears = nearmes
            }).start()
        }
        
        Shared.MyInfo.myLocation.producer
            .filter { $0 != nil }
            .filter { _ in self.callWeather }
            .map { _ in (self.callWeather = false) }
            .on(next: { _ in
                self.isLoading.value = false
            })
            .startWithNext {
                self.myStore
                    .fetchWelcome(self.getWeather())
                    .on(next: {[weak self] (itins, close) in
                        var nitins = itins
                        var indx: [NSIndexPath] = [NSIndexPath(forRow: 0, inSection: 0)]
                        if close.count>0 && nitins.count>1{
                            indx.append(NSIndexPath(forRow: 0, inSection: 1))
                        }
                        if close.count>0 {
                            indx.append(NSIndexPath(forRow: 0, inSection: 2))
                        }
                        if nitins.count>0 {
                            nitins.removeLast()
                            let ns = nitins.enumerate().map{ (index, element) in
                                NSIndexPath(forRow: index, inSection: 3)
                            }
                            indx.appendContentsOf(ns)
                        }
                        
                        Shared.MyInfo.myIntis = nitins
                        Shared.MyInfo.myClose = close
                        self?.showRefresh.swap(indx)
                        }).start()
        
        }
    }
    
    //////                self.fetchLocationPid()
    //                    .on { (list) in
    //                        if let first = list.first,
    //                        let placeID = first.placeID
    //                        {
    //                            self.cityID.swap(placeID)
    //                            self.refreshObserver.sendNext()
    //                        }
    //                    }.start()
    
    
    
//    func goProfile(){
//        
//        if let u = Shared.MyInfo.myLoginUser.value {
//            Shared.MyInfo.showUserIDNav.swap([u])
//        }
//    }
    
    
    func showCloseFriends() {
        Shared.MyInfo.showUserFriends.swap(Shared.MyInfo.myClose)
    }
    
/////
    
    func numberSection() -> Int
    {
        return 7
    }
    
    func numberOfRowsInSection(section:Int) -> Int
    {
        if (self.showRefresh.value == nil){
            switch section {
            case 0: return 0
            case 1: return 0
            case 2: return 0
            case 3: return 0
            case 4: return 1
            case 5: return 1
            case 6: return 1
            default:return 1
            }
        }
        switch section {
        case 0: return 1
        case 1: if Shared.MyInfo.myClose.count > 0 || Shared.MyInfo.myIntis.count > 1 { return 1 } else { return 0 }
        case 2: if Shared.MyInfo.myClose.count > 0 { return 1 } else { return 0 }
        case 3: return Shared.MyInfo.myIntis.count
        case 4: return 1
        case 5: return 1
        case 6: return 1
        default:return 1
        }
    }
    

    
    func friendsNu() -> String
    {
        return "\(Shared.MyInfo.myClose.count)"
    }
    
    func itinNu() -> String
    {
        if Shared.MyInfo.myNears.count > 0 {
            return "\(Shared.MyInfo.myNears.count)"
        }
        return "\(Shared.MyInfo.myIntis.count)"
    }
    
    func friendsText() -> String
    {
        if Shared.MyInfo.myClose.count != 1 { return "Friends" }else{ return "Friend"}
    }
    
    func itinText() -> String
    {
        if Shared.MyInfo.myIntis.count != 1 { return "Suggestions" }else{ return "Suggestion"}
    }
    
    func goShowOneSugg(indexPath:NSIndexPath){
        showItin = Shared.MyInfo.myIntis[indexPath.row]
        if let fid = self.showItin?.ids?.first {
//            Shared.MyInfo.store.fetchFeedbackID(fid)
//                .startWithResult({ (result) in
//                    switch result {
//                    case let .Success(feeds):
//                        if let child = feeds.first {
//                            Shared.MyInfo.selectedSugg.swap(LocationChild(child: child))
//                            self.locationAdd(child)
//                            self.oneSelectionObserver.sendNext(child)
//                            
//                        }
//                    case .Failure:break
//                    }
//                })
        }
        
    }
    
    
    func locationAdd (child:Children) {
            dispatch_async(dispatch_get_main_queue(),{
                self.myStore.fetchGPlaceAutocomplete(child).on(next:{(lchild) in
//                    Shared.MyInfo.locationChildrens[child.cid] = lchild
//                    Shared.MyInfo.selectedSugg.swap(lchild)
                }).start()
            })
    }
    
    
    func welcomeCell(cell:UITableViewCell){
        let location = LocationManager.sharedInstance
        let wellbl = cell.contentView.viewWithTag(1) as! UILabel
        wellbl.text = location.currentCity
    }
    
    func welcomeInfoCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(infoCellIdentifier, forIndexPath: indexPath) as! WelcomeSuggCell
        if Shared.MyInfo.myIntis.count > 0 {
            let itin = Shared.MyInfo.myIntis[indexPath.row]
            cell.viewModel = WelcomeSuggModel(itin: itin)
        }
        return cell
    }
    
    func objForRowAtIndexPath(indexPath:NSIndexPath)
    {
        
    }
    
//    private func getCityId() -> String {
//        
//    }
    
    private func fetchLocationPid() -> SignalProducer< [GMSAutocompletePrediction], NSError> {
        return SignalProducer { observer, disposable in
            let filter = GMSAutocompleteFilter()
            filter.type = .City
            if let cl = LocationManager.sharedInstance.currentLocation
            {
                let name = LocationManager.sharedInstance.currentCity
                let coordinateBounds =  GMSCoordinateBounds().includingCoordinate(cl.coordinate)
                GMSPlacesClient.sharedClient().autocompleteQuery(name, bounds: coordinateBounds , filter: filter , callback: { (list, error) in
                    guard let list = list where error == nil else {
                        observer.sendFailed(error!)
                        observer.sendCompleted()
                        return
                    }
                    observer.sendNext(list)
                    observer.sendCompleted()
                })
            }
        }
    }
    
    private func getWeather() -> [String:String] {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Hour, .TimeZone]
        let components = calendar.components(unitFlags, fromDate: now)
        let tz = components.timeZone
        let location = LocationManager.sharedInstance
        let dict:[String:String] = ["lat":  "\((location.currentLocation?.coordinate.latitude)!)",
                                    "lng":  "\((location.currentLocation?.coordinate.longitude)!)",
                                    "hour": "\(components.hour)",
                                    "cdiff":"\(now.timeIntervalSince1970)",
                                    "tz":   "\(tz!.secondsFromGMT)",
                                    "city": "\(location.currentCity)",
                                    "iso":  "\(location.countryCode)"]
        return dict
        
    }
    
}

