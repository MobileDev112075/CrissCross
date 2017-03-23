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

class CreateSurePlanModel {
    
    static func contentMatches(lhs: Int, _ rhs: Int) -> Bool {
        return lhs == rhs
    }
    
    
    private let childCellIdentifier = "SearchCell"

    // Inputs

    let refreshObserver:        Observer<Void, NoError>
    let active =                MutableProperty(false)
    let selectedReady =         MutableProperty(false)
    let seacrhCity =            MutableProperty("")
    
    // Outputs
    let searchFetchResults =    MutableProperty<[GMSAutocompletePrediction]>([])
    let selectedCitySignal =    MutableProperty<GMSAutocompletePrediction?>(nil)
    let selectedPlaceSignal =   MutableProperty<GMSPlace?>(nil)
    let cityImage =             MutableProperty<UIImage?>(nil)
    let titleSignal =           MutableProperty<String>("")
    let isLoading:              MutableProperty<Bool>

    let refreshSignal:          Signal<Void, NoError>
    let alertMessageSignal:     Signal<AnyObject, NoError>
    
    // Actions
    
    private let store: StoreType
    private let filter = GMSAutocompleteFilter()
    private var bounds:GMSCoordinateBounds? = nil
    

    // MARK: - Lifecycle
    
    init(store: StoreType){
        
        self.filter.type = .City
        self.store = store

        let (alertMessageSignal, _) = Signal<AnyObject, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver    = refreshObserver
        self.refreshSignal      = refreshSignal
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading

        self.titleSignal.swap("Add Suggestion")
        

        
        self.seacrhCity.producer
            .filter({ (str) -> Bool in
                str.characters.count>2
            })
            
        .startWithNext {[weak self] (str) in
            store.fetchGPlaceAutoComp(str, bounds: self?.bounds, filter: self?.filter)
                .startWithResult({ (result) in
                    switch result{
                    case let .Success(res):
                        self?.searchFetchResults.swap(res)
                    case .Failure(_):break
                    }
                })
        }


        self.selectedCitySignal.producer
            .startWithNext({ (pred:GMSAutocompletePrediction?)in
                if let predSelected = pred, let placeID = predSelected.placeID {
                    self.store.lookUpPlaceID(placeID)
                        .startWithResult({[weak self] (result) in
                            switch result{
                            case let .Success(place):
                                self?.selectedPlaceSignal.swap(place)
                            case .Failure(_):
                                break
                            }
                        })
                }
        })
        
        self.selectedPlaceSignal.producer
            .startWithNext { (plc) in
            if let plc = plc {
                if (self.filter.type == .Establishment){
//                    Shared.MyInfo.write_sugg_FilterModels.swap([Shared.MyInfo.allFilterModels["FilterAct"]!])
//                    Shared.MyInfo.wtite_filterHistory.swap([])
                    self.selectedReady.swap(true)
                }
                if (self.filter.type == .City){
                    self.filter.type = .Establishment
                }
                self.bounds =  GMSCoordinateBounds().includingCoordinate(plc.coordinate)
                self.store.fetchImagesSingleGPlace(plc).startWithResult({[weak self] (result) in
                        switch result{
                        case let .Success(img):
                        self?.cityImage.swap(img)
                        case .Failure(_):break
                        }
                    })
                }
        }
    }
    
    
    
    
    func goback() -> Bool
    {
        if self.selectedPlaceSignal.value == nil {
            MainSection.showSections.swap([])
            return true
        }else{
            self.filter.type = .City
            self.searchFetchResults.swap([])
            self.selectedPlaceSignal.swap(nil)
            self.selectedReady.swap(false)
            return false
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(childCellIdentifier, forIndexPath: indexPath)
        let compPre:GMSAutocompletePrediction = self.searchFetchResults.value[indexPath.row]
        let label = cell.contentView.viewWithTag(200) as! UILabel
        label.text = compPre.attributedFullText.string
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchFetchResults.value.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let compPre:GMSAutocompletePrediction = self.searchFetchResults.value[indexPath.row]
        self.selectedCitySignal.swap(compPre)
        let name = compPre.attributedFullText.string
        self.titleSignal.swap(name)
        self.searchFetchResults.swap([])
        self.seacrhCity.swap("")
        if let pid = compPre.placeID {
            MainSection.planPid.swap((pid,name))
        }
    }
}
