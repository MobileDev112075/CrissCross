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

class AllSuggViewModel:DKViewModel {
    
    private var selectedHistory     = [NSIndexPath]()
    private var currentLocations    = [Location]()
    
    private var beentheres          = [Beenthere]()
    private var childrens           = [Children]()
    
    private var locationsDistance   = [Location]()
    private var locationsFilterd    = [[Children]]()
    private var locationsCities     = [[Location]]() // array of locations per city // Beenthere + Place
    private var locationsStates     = [[Location]]() // array of Cities per country // Beenthere + Place
    private var locationsCountries  = [[[Location]]]() // array of Cities per country // Beenthere + Place
    
    private var myBeentheres        = [Beenthere]()
    private var myLocationsDistance = [Location]()
  
    /////////// >>>>>>>>>>>
    
    private let childCellIdentifier =       "ChildCell"
    private let locationCellIdentifier =    "LocationCell"
    private let cityCellIdentifier =        "CityCell"
    
    static let heightForChildHeaderInSection:CGFloat    = 0
    static let heightForChildRowAtIndexPath:CGFloat     = 154
    static let heightForHeaderInSection:CGFloat         = 30
    static let heightForRowAtIndexPath:CGFloat          = 126
    
    // Inputs
    
    var filterSections      = MutableProperty<[[FilterModel]]>([])
    var filterTreeHistory   = MutableProperty<[(Int,Int)]>([])
    var filterType          = MutableProperty<(String,Int)>("",0)
    // Outputs
    
    let contentChangesSignal: Signal<Bool, NoError>
    
    // Actions
    
    private let fetchDone = MutableProperty(false)
    private let contentChangesObserver: Observer<Bool, NoError>
    
    // MARK: - Lifecycle
    
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    override init(store: StoreType) {
        
        filterSections.swap([Shared.MyInfo.allFilterModels["FilterSug"]!])
        
        let (contentChangesSignal, contentChangesObserver) = Signal<Bool, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        super.init(store: store)
        
        self.title = "Suggestions"
        
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        //
        SignalProducer(signal: refreshSignal)
            .filter({  [weak self] _ in !(self?.fetchDone.value)! })
            .on(next: { [weak self]  _ in self?.isLoading.value = true })
            .flatMap(.Latest)
            {  [weak self] _ in
                return (self?.myStore.fetchSugg()
                    .flatMapError { [weak self] error in
                        self?.alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])})!
            }
            .startWithNext({ [weak self](newBeen) in
                let onlyWithChildren = newBeen.filter{$0.children != nil}
                self?.beentheres    = onlyWithChildren
                self?.childrens     = onlyWithChildren.map{$0.children!}.flatMap{$0}.sort{$0.encode()["created"] as! String > $1.encode()["created"] as! String}
                self?.fetchDone.swap(true)
                })
        
        Shared.MyInfo.myLoginUser.producer
        .startWithNext { [weak self] (user)  in
            if let user = user, let beentheres = user.beenTheres
            {
                self?.myBeentheres = beentheres
                self?.myMainThreadFetchGPlace()
            }
        }
        
        /// ADD and FETCH locations fetchGPlace
        
        fetchDone.producer
            .filter { $0 }
            .map { _ in () }
            .on(next: { [weak self] _ in self?.isLoading.value = false })
            .startWithNext { [weak self] _ in
                self?.mainThreadFetchGPlace()
                self?.filterTreeHistory.swap([(0,3)])
        }
        
        //// filters
        
        filterTreeHistory.producer
            .filter{$0.count>0}
            .filter({[weak self] (nums) -> Bool in
                let num = nums.last!
                return self?.filterSections.value.count>num.0
                })
            .startWithNext { [weak self] (nums) in
                if let type = self?.filterMachineExTypes(nums) {
                    self?.filterType.swap(type)
                }
        }
        
        filterType.signal
            .observeNext { [weak self] type in
                if type.0 == "Nearby" {
                    self?.selectedHistory = []
                    self?.currentLocations = self?.locationsDistance ?? []
                }
                else if type.0 == "Mine" {
                    self?.selectedHistory = []
                    self?.currentLocations = self?.myLocationsDistance ?? []
                }
                else if type.1 > 0, let currentLocations = self?.currentLocations
                {
                    self?.sortByFilerID(currentLocations, type: type.0,filter: type.1)
                }
                else {
                    self?.selectedHistory = []
                    self?.currentLocations = []
                }
                self?.contentChangesObserver.sendNext(true)
        }
    }
    
    
    
    // MARK: - Data Source
    
    func cellIdentifier(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if filterType.value.0 == "Activity" {
            let cell = tableView.dequeueReusableCellWithIdentifier(childCellIdentifier, forIndexPath: indexPath) as! SuggCell
            cell.viewModel = SuggCellViewModel(child: childrens[indexPath.row])
            return cell
        }else if filterType.value.0 == "Nearby" || filterType.value.0 == "Mine" {
            let cell = tableView.dequeueReusableCellWithIdentifier(locationCellIdentifier, forIndexPath: indexPath) as! LocationCell
            let been = self.currentLocations[indexPath.section].beenthere
            let child  = been.children?[indexPath.row]
            
            cell.viewModel = SuggCellViewModel(child: child!)
            return cell
        }else if filterType.value.1 > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(locationCellIdentifier, forIndexPath: indexPath) as! LocationCell
            let arr = self.locationsFilterd[indexPath.section]
            let child  = arr[indexPath.row]
            
            cell.viewModel = SuggCellViewModel(child: child)
            return cell
        }
            
        else if filterType.value.0 == "A-Z City" || filterType.value.0 == "Friends" {
            if selectedHistory.count>0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(locationCellIdentifier, forIndexPath: indexPath) as! LocationCell
                let been = self.currentLocations[indexPath.section].beenthere
                let child  = been.children?[indexPath.row]
                cell.viewModel = SuggCellViewModel(child: child!)
                return cell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(cityCellIdentifier, forIndexPath: indexPath) as! CityCell
            let location = locationsCities[indexPath.row].first!
            cell.viewModel = LocationCellViewModel(location: location, city: true)
            return cell
        }
            
        else if filterType.value.0 == "Country" {
            let cell = tableView.dequeueReusableCellWithIdentifier(cityCellIdentifier, forIndexPath: indexPath) as! CityCell
            let locations = locationsCountries[indexPath.row].first!
            let location = locations.first!
            cell.viewModel = LocationCellViewModel(location: location, city: false)
            return cell
        }
            
        else if filterType.value.0 == "State" {
            let cell = tableView.dequeueReusableCellWithIdentifier(locationCellIdentifier, forIndexPath: indexPath) as! LocationCell
            return cell
            
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cityCellIdentifier, forIndexPath: indexPath) as! CityCell
            return cell
        }
    }
    
    func didSelectRowAtIndexPath(indexPath: NSIndexPath) {
        
        if filterType.value.1 > 0 {
            let childs = locationsFilterd[indexPath.section]
            let child = childs[indexPath.row]
            Shared.MyInfo.selectedChild.swap(child)
        }
        else if filterType.value.0 == "Activity" {
            let child = childrens[indexPath.row]
            Shared.MyInfo.selectedChild.swap(child)
        }
//        else if filterM.type == "Country" {
//                self.cities = self.countries[indexPath.row]
//                let filterM = FilterModel(type: "A-Z City", call: nil, defOn:false, innerSort: nil, typeID:"0")
//                self.filterM = filterM
//                self.contentChangesObserver.sendNext(true)
//            }
        else if filterType.value.0 == "A-Z City"  || filterType.value.0 == "Friends" {
            if selectedHistory.count>0 {
                let childs = currentLocations[indexPath.section]
                let child = childs.beenthere.children![indexPath.row]
                Shared.MyInfo.selectedChild.swap(child)
            }else{
                let locations = locationsCities[indexPath.row]
                self.currentLocations = locations
                self.selectedHistory.append(indexPath)
                let newfm = Shared.MyInfo.allFilterModels["FilterAct"]
                filterSections.value.append(newfm!)
                self.contentChangesObserver.sendNext(true)
            }
        }
            
        else if filterType.value.0 == "Nearby" || filterType.value.0 == "Mine"{
            let childs = currentLocations[indexPath.section]
            let child = childs.beenthere.children![indexPath.row]
            Shared.MyInfo.selectedChild.swap(child)
        }
        
    }
    
    func heightForRow() -> CGFloat {
        if filterType.value.0 == "Activity" {
            return AllSuggViewModel.heightForChildRowAtIndexPath
        }
        return AllSuggViewModel.heightForRowAtIndexPath
    }
    
    func heightForHeader() -> CGFloat {
        if filterType.value.0 == "Nearby"  || filterType.value.0 == "Mine" {
            return AllSuggViewModel.heightForHeaderInSection
        }
        if filterType.value.1 > 0 {
            return AllSuggViewModel.heightForHeaderInSection
        }
        return AllSuggViewModel.heightForChildHeaderInSection
    }
    
    func numberOfSections() -> Int {
        if filterType.value.1 > 0 {
            return self.locationsFilterd.count
        }
        if self.currentLocations.count > 0 {
            return self.currentLocations.count
        }
        return 1
    }
    
    func numberOfChildrenInSection(section: Int) -> Int {
        if filterType.value.1 > 0 {
            return self.locationsFilterd[section].count
        }
        if self.currentLocations.count > 0 {
            let loca = self.currentLocations[section]
            return loca.beenthere.children?.count ?? 0
        }
        if filterType.value.0 == "Activity" {
            return childrens.count
        }
        if (filterType.value.0 == "A-Z City") || (filterType.value.0 ==  "Friends") {
            return self.locationsCities.count
        }
        if filterType.value.0 == "Country" {
            return self.locationsCountries.count
        }
        if filterType.value.0 == "State" {
            return self.locationsStates.count
        }
        
        return 0
        
    }
    
    
    
    // MARK: - Location Data Source
    
    func headerForLocation(section: Int) -> String {
        if filterType.value.0 == "Nearby"  || filterType.value.0 == "Mine" {
            let loca = self.currentLocations[section]
            return loca.beenthere.title ?? ""
        }
        if filterType.value.1 > 0 {
            let child = self.locationsFilterd[section]
            return child.first!.title
        }
        
        return ""
    }
    
}



extension AllSuggViewModel {
    
    private func mainThreadFetchGPlace () {
        dispatch_async(dispatch_get_main_queue(),{
            self.myStore.fetchGPlace(self.beentheres)
                .on(next:
                    {(locations:[Location]) in
                        // arrange distance
                        self.locationsDistance = locations.sort{$0.distanceFromMyLocation() < $1.distanceFromMyLocation()}
                        self.sortLocationsByCities(self.locationsDistance)
                        
                })
                .start()
        })
    }
    
    private func myMainThreadFetchGPlace () {
        dispatch_async(dispatch_get_main_queue(),{
            self.myStore.fetchGPlace(self.myBeentheres)
                .on(next:
                    {(locations:[Location]) in
                        // arrange distance
                        self.myLocationsDistance = locations.sort{$0.distanceFromMyLocation() < $1.distanceFromMyLocation()}
                        
                })
                .start()
        })
    }
    
    private func sortLocationsByCities(locations:[Location]) {
        let sort = locations.sort{$0.country() < $1.country()}
        let countriesNames =  sort.map({ (location) -> String in
            location.country()
        })
        
        let uniqueName = Array(Set(countriesNames))
        let locationsByCountries = uniqueName.map({ (name) -> [Location] in
            let country = sort.filter{$0.country() == name}
            return country
        })
        
        let locationsByState = sort.filter{$0.country() == "United States"}
        
        
        
        
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
        
        self.locationsCountries  = locationsByCities
        self.locationsCities     = locationsByCities.flatMap {$0}.sort{$0.first!.city() < $1.first!.city()}
        //        self.locationsStates     = locationsByState
        
    }
    
    // eat drink ..
    private func sortByFilerID(locations:[Location],type:String,filter:Int){
        let a =
            locations.map { (loca)  in
                loca.beenthere.children!.filter({ (child) -> Bool in
                    return (Int(child.category_id)! == filter) || (child.masterFilter == type)
                })
                }.filter { (childs) -> Bool in
                    childs.count>0
        }
        
        self.locationsFilterd = a
    }
    
    
    private func filterMachineExTypes (nums:[(Int, Int)]) -> (String,Int) {
        if let num = nums.last{
            var vis = self.filterSections.value
            let filterM = vis[num.0][num.1]
            vis = Array(vis[0..<num.0+1])
            if let call = filterM.call,
                let newfm = Shared.MyInfo.allFilterModels[call]
            {
                vis.append(newfm)
            }
            
            self.filterSections.swap(vis)
            let typeID = Int(filterM.typeID ?? "0") ?? 0
            return (filterM.type,typeID)
        }
        return ("",0)
    }
}

