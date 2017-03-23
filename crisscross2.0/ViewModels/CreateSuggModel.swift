//
//  AllSuggViewModel.swift
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

class CCTableViewCell: UITableViewCell {
    var viewModel:AnyObject?
}

class AllSuggViewModel {
    
    private let childCellIdentifier         = "ChildCell"
    private let locationCellIdentifier      = "LocationCell"
    private let cityCellIdentifier          = "CityCell"
    
    static let heightForChildHeaderInSection:CGFloat = 0
    static let heightForChildRowAtIndexPath:CGFloat = 154
    
    static let heightForHeaderInSection:CGFloat = 30
    static let heightForRowAtIndexPath:CGFloat = 126
    
    // Inputs
    let active =            MutableProperty(false)
    let refreshObserver:    Observer<Void, NoError>
    let filterHistory =     Shared.MyInfo.filterHistory
    
    // Outputs
    let title: String
    let isLoading:              MutableProperty<Bool>
    let alertMessageSignal:     Signal<String, NoError>
    let contentChangesSignal:   Signal<Bool, NoError>
    let oneSelectionSignal:     Signal<Children, NoError>
    
    // Actions
    
    private let store: StoreType
    private let localStore: StoreType
    
    private let oneSelectionObserver:   Observer<Children, NoError>
    private let alertMessageObserver:   Observer<String, NoError>
    private let contentChangesObserver: Observer<Bool, NoError>

    private let fetchDone = MutableProperty(false)
    
    private var myCountries: [[[Location]]]
    private var myCities: [[Location]]
    
    private var countries: [[[Location]]]
    private var cities: [[Location]]
    private var locations: [Location]
    private var nearby: [Location]
    
    private var beentheres: [Beenthere]
    private var oldBeens: [Beenthere]
    private var childrens: [Children]
    private var filterM: FilterModel?

    // MARK: - Lifecycle
    
    init(store: StoreType) {
        
        self.title = "Suggestions"
        self.store = store
        self.localStore = Shared.MyInfo.localStore
        
        self.myCountries    = []
        self.myCities       = []
        self.countries      = []
        self.cities         = []
        self.locations      = []
        self.childrens      = []
        self.beentheres     = []
        self.oldBeens       = []
        self.nearby         = []

        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        let (contentChangesSignal, contentChangesObserver) = Signal<Bool, NoError>.pipe()
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
        
        Shared.MyInfo.user.producer
        .startWithNext { (user) in
            let my = user.map{$0}?.beenTheres.map{$0}
            if let my = my {
                dispatch_async(dispatch_get_main_queue(),{
                    self.store.fetchGPlace(my)
                        .on(next:
                            {(locations:[Location]) in
                                
                                let myLocations = locations.sort{$0.distanceFromMyLocation() < $1.distanceFromMyLocation()}
                                let sort = myLocations.sort{$0.country() < $1.country()}
                                let countriesNames =  sort.map({ (location) -> String in
                                    location.country()
                                })
                                let uniqueName = Array(Set(countriesNames))
                                let locationsByCountries = uniqueName.map({ (name) -> [Location] in
                                    let country = sort.filter{$0.country() == name}
                                    return country
                                })
                                
                                let locationsByCities = locationsByCountries.map { (citiesLocations) -> [[Location]] in
                                    let sort = citiesLocations.sort{ $0.city() < $1.city()}
                                    let citiesNames =  sort.map({ (location) -> String in
                                        location.city()
                                    })
                                    let uniqueCityName = Array(Set(citiesNames))
                                    let locationsByCities = uniqueCityName.map({ (name) -> [Location] in
                                        sort.filter{$0.city() == name}
                                    })
                                    return locationsByCities
                                }

                                self.myCountries  = locationsByCities
                                self.myCities     = locationsByCities.flatMap {$0}.sort{$0.first!.city() < $1.first!.city()}

                        }).start()
                })
            }

        }

        SignalProducer(signal: refreshSignal)
            .filter{self.filterHistory.value.count==0}
            .on(next: { _ in isLoading.value = true })
            .flatMap(.Latest)
            { _ in
                return store.fetchSugg()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])}
            }
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldBeen, newBeen) in
                let onlyWithChildren = newBeen.filter{$0.children != nil}

                self?.beentheres    = onlyWithChildren
                self?.childrens     = onlyWithChildren.map{$0.children!}.flatMap{$0}.sort{$0.encode()["created"] as! String > $1.encode()["created"] as! String}
                self?.fetchDone.swap(true)
                })
        
        /// ADD and FETCH locations fetchGPlace
        
        fetchDone.producer
            .filter { $0 }
            .map { _ in () }
            .on(next: { _ in isLoading.value = false })
            .startWithNext {
                dispatch_async(dispatch_get_main_queue(),{
                    self.store.fetchGPlace(self.beentheres)
                        .on(next:
                            {(locations:[Location]) in
                                self.locations = locations.sort{$0.distanceFromMyLocation() < $1.distanceFromMyLocation()}
                                Shared.MyInfo.vis_Sugg_FilterModels.swap([Shared.MyInfo.allFilterModels["FilterSug"]!])
                                Shared.MyInfo.filterHistory.value.append((0,3))
                        }).start()
                })
        
        }
        
         ///
         ///
         ///
        
        filterHistory.producer
            .filter{$0.count>0}
            .filter({ (nums) -> Bool in
                let num = nums.last!
                return Shared.MyInfo.vis_Sugg_FilterModels.value.count>num.0
            })
            .startWithNext {(nums) in
                if let num = nums.last{
                    var vis = Shared.MyInfo.vis_Sugg_FilterModels.value
                    self.filterM = vis[num.0][num.1]
                    vis = Array(vis[0..<num.0+1])
                    if let call = self.filterM?.call,
                    let newfm = Shared.MyInfo.allFilterModels[call]
                    {
                        vis.append(newfm)
                    }
                    
                    Shared.MyInfo.vis_Sugg_FilterModels.swap(vis)
                    if self.filterM!.type == "Friends" {
                        self.sortLocations(false)
                        self.filterM = FilterModel(type: "A-Z City", call: nil ,defOn: true)
                    }
                    
                    if self.filterM!.type == "Nearby"{
                        self.nearby = self.locations
                    }
                    if self.filterM!.type == "Mine"{
                        
                    }
                    if self.filterM!.type == "Country"{
                        self.sortLocations(false)
                    }
                    if self.filterM!.type == "A-Z City"{
                        self.sortLocations(false)
                    }
                    if self.filterM!.type == "Activity"{
                         self.sortLocations(false)
                    }
                    self.contentChangesObserver.sendNext(true)
                }
        }
    }
    
    func goback() -> Bool
    {
        if self.filterHistory.value.count == 0 {
            return true
        }else{
            self.filterHistory.value.removeLast()
            return false
        }
    }
    
    func sortLocations(mine:Bool)
    {

        let sort = self.locations.sort{$0.country() < $1.country()}
        let countriesNames =  sort.map({ (location) -> String in
            location.country()
        })
        
        let uniqueName = Array(Set(countriesNames))
        let locationsByCountries = uniqueName.map({ (name) -> [Location] in
            let country = sort.filter{$0.country() == name}
            return country
        })
        
        let locationsByCities = locationsByCountries.map { (citiesLocations) -> [[Location]] in
            let sort = citiesLocations.sort{ $0.city() < $1.city()}
            let citiesNames =  sort.map({ (location) -> String in
                location.city()
            })
            let uniqueCityName = Array(Set(citiesNames))
            let locationsByCities = uniqueCityName.map({ (name) -> [Location] in
                sort.filter{$0.city() == name}
            })
            return locationsByCities
        }
        
        self.countries  = locationsByCities
        self.cities     = locationsByCities.flatMap {$0}.sort{$0.first!.city() < $1.first!.city()}
    }
    
    // MARK: - Data Source
    
    func cellIdentifier(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if filterM!.type == "Activity" {
            let cell = tableView.dequeueReusableCellWithIdentifier(childCellIdentifier, forIndexPath: indexPath) as! SuggCell
            cell.viewModel = SuggCellViewModel(child: childrens[indexPath.row])
            return cell
        }
        else if filterM!.type == "Nearby" {
            let cell = tableView.dequeueReusableCellWithIdentifier(locationCellIdentifier, forIndexPath: indexPath) as! LocationCell
            let been:Beenthere = nearby[indexPath.section].beenthere
            cell.viewModel = SuggCellViewModel(child: been.children![indexPath.row])
            return cell
        }else if filterM!.type == "State" {
            let cell = tableView.dequeueReusableCellWithIdentifier(locationCellIdentifier, forIndexPath: indexPath) as! LocationCell
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cityCellIdentifier, forIndexPath: indexPath) as! CityCell
            cell.viewModel = self.viewModelLocationIndexPath(indexPath)
            return cell
        }
    }
    
    private func viewModelLocationIndexPath(indexPath: NSIndexPath) -> LocationCellViewModel? {
        if filterM!.type == "Country" && countries.count > 0  {
            let cities : [Location] = countries[indexPath.row].first!
            return LocationCellViewModel(location: cities.first!, filter:filterM!)
        }else if filterM!.type == "A-Z City" && countries.count > 0 {
            let incities : [Location] = cities[indexPath.row]
            return LocationCellViewModel(location: incities.first!, filter:filterM!)
        }else if filterM!.type == "Mine" && myCountries.count > 0 {
            let incities : [Location] = myCities[indexPath.row]
            return LocationCellViewModel(location: incities.first!, filter:filterM!)
        }
        return nil
    }
    
    func heightForRow() -> CGFloat {
        if filterM!.type == "Activity" {
            return AllSuggViewModel.heightForChildRowAtIndexPath
        }
        return AllSuggViewModel.heightForRowAtIndexPath
    }
    
    func heightForHeader() -> CGFloat {
        if filterM!.type == "Nearby" {
            return AllSuggViewModel.heightForHeaderInSection
        }
        return AllSuggViewModel.heightForChildHeaderInSection
    }
    
    func numberOfSections() -> Int {
        if let filterM = filterM {
            if filterM.type == "Nearby" {
                return nearby.count
            }
            return 1
        }
        return 0
    }
    
    func numberOfChildrenInSection(section: Int) -> Int {
        if let filterM = filterM {
            if filterM.type == "Nearby" {
                let been:Beenthere = nearby[section].beenthere
                return been.children?.count ?? 0
            }
            if filterM.type == "Country" {
                return countries.count ?? 0
            }
            if filterM.type == "A-Z City" {
                return cities.count ?? 0
            }
            if filterM.type == "Activity" {
                return childrens.count
            }
            if filterM.type == "Mine" {
                return myCities.count
            }
            return locations.count
        }
        return 0
    }
    
    
    func didSelectRowAtIndexPath(indexPath: NSIndexPath)
    {
        if let filterM = filterM {
            if filterM.type == "Activity" {
                let child = Shared.MyInfo.feedChildrens[childrens[indexPath.row].cid]!
                if let loc = Shared.MyInfo.locationChildrens[child.cid] {
                        Shared.MyInfo.selectedSugg.swap(loc)
                }else{
                    self.store.fetchGPlaceAutocomplete(child).on(next:{(lchild) in
                        Shared.MyInfo.locationChildrens[child.cid] = lchild
                        Shared.MyInfo.selectedSugg.swap(lchild)
                        }).start()
                    }
            
                Shared.MyInfo.selectedSugg.swap(LocationChild(child: child))
                self.oneSelectionObserver.sendNext(child)
            }
            
            if filterM.type == "Country" {
                self.cities = self.countries[indexPath.row]
                let filterM = FilterModel(type: "A-Z City", call: nil, defOn:false)
                self.filterM = filterM
                self.contentChangesObserver.sendNext(true)
            }
            else if filterM.type == "A-Z City" {
                self.nearby = self.cities[indexPath.row]
                let filterM = FilterModel(type: "Nearby", call: nil, defOn:false)
                self.filterM = filterM
                let newfm = Shared.MyInfo.allFilterModels["FilterAct"]
                Shared.MyInfo.vis_Sugg_FilterModels.value.append(newfm!)                
                self.contentChangesObserver.sendNext(true)
            }
            else if filterM.type == "Mine" {
                self.nearby = self.myCities[indexPath.row]
                let filterM = FilterModel(type: "Nearby", call: nil, defOn:false)
                self.filterM = filterM
                let newfm = Shared.MyInfo.allFilterModels["FilterAct"]
                Shared.MyInfo.vis_Sugg_FilterModels.value.append(newfm!)
                self.contentChangesObserver.sendNext(true)
            }
            else if filterM.type == "Nearby" {
                let been:Beenthere = nearby[indexPath.section].beenthere
                let child = been.children![indexPath.row]
                self.store.fetchGPlaceAutocomplete(child).on(next:{(lchild) in
                    Shared.MyInfo.selectedSugg.swap(lchild)
                }).start()
                Shared.MyInfo.selectedSugg.swap(LocationChild(child: child))
                self.oneSelectionObserver.sendNext(child)
            }
        }
    }
    
    // MARK: - Location Data Source
    
    func headerForLocation(section: Int) -> String {
        let been:Beenthere = nearby[section].beenthere
        return been.title ?? ""
    }
}


