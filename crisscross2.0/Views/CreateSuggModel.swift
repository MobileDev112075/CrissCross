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

class CreateSuggModel {
    
    private let childCellIdentifier = "SearchCell"

    // Inputs

    let refreshObserver:        Observer<Void, NoError>
    let active =                MutableProperty(false)
    let seacrhCity =            MutableProperty("")
    
    // Outputs
    let searchFetchResults =    MutableProperty<[GMSAutocompletePrediction]>([])
    let selectedCitySignal =    MutableProperty<GMSAutocompletePrediction?>(nil)
    
    let cityImage =             MutableProperty<UIImage?>(nil)
    let titleSignal =           MutableProperty<String>("")
    let searchTitle =           MutableProperty<String>("")
    let isLoading:              MutableProperty<Bool>
    
    let selectedPriceSignal =   MutableProperty<Int>(0)
    let selectedCommentSignal = MutableProperty<String>("")

    let refreshSignal:          Signal<Void, NoError>
    let alertMessageSignal:     Signal<AnyObject, NoError>
    let gfilter = GMSAutocompleteFilter()
    
    // Actions
    
    private let store: StoreType
    private var bounds:GMSCoordinateBounds? = nil
    
    // MARK: - Lifecycle
    
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    init(store: StoreType){
        
        MainSuggSection.updateFeedback.swap("")
        MainSuggSection.cityReady.swap(nil)
        MainSuggSection.placeReady.swap(nil)
        MainSuggSection.photoReady.swap(nil)
        MainSuggSection.commeReady.swap("")
        MainSuggSection.sortReady.swap([])
        
        
        self.gfilter.type = .City
        
        self.store = store

        let (alertMessageSignal, _) = Signal<AnyObject, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver    = refreshObserver
        self.refreshSignal      = refreshSignal
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading

        self.titleSignal.swap("Add Suggestion")
        
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        SignalProducer(signal: refreshSignal)
            .startWithNext({ _ in

                })
        
        self.seacrhCity.producer
            .filter({ (str) -> Bool in
                str.characters.count>2
            })
        .startWithNext {[weak self] (str) in
            store.fetchGPlaceAutoComp(str, bounds: self?.bounds, filter: self?.gfilter)
            .startWithResult({ (result) in
                    switch result{
                    case let .Success(res):
                        self?.searchFetchResults.swap(res)
                    case .Failure(_):break
                    }
                })
        }
//
        self.selectedCitySignal.producer
            .startWithNext{ [weak self] (pred:GMSAutocompletePrediction?) in
                if let predSelected = pred, let placeID = predSelected.placeID {
                    self?.store.lookUpPlaceID(placeID)
                        .startWithResult({[weak self] (result) in
                            switch result{
                            case let .Success(place):
                                self?.showImages(place)
                                self?.bounds =  GMSCoordinateBounds().includingCoordinate(place.coordinate)
                                if (self?.gfilter.type == .City){
                                    
                                    MainSuggSection.cityReady.swap(place)
                                    
                                    self?.gfilter.type = .Establishment
                                }else{
                                    MainSuggSection.placeReady.swap(place)
                                }
                         

                            case .Failure(_):
                                break
                            }
                        })
                }
        }

        MainSuggSection.editChildrenLocation.producer
            .ignoreNil()
            .startWithNext { [weak self] (locationChild) in
                self?.titleSignal.swap(locationChild.child.title)
                self?.searchTitle.swap(locationChild.child.item_title)
                MainSuggSection.placeReady.swap(locationChild.place)
                if MainSuggSection.editMyChildrenLocation.value{
                    
                }
        }

        
    }
    
    func showImages(plc:GMSPlace) {
        self.store.fetchImagesSingleGPlace(plc).startWithResult({[weak self] (result) in
            switch result{
            case let .Success(img):
                self?.cityImage.swap(img)
            case .Failure(_):break
            }})
    }
    
    
    func goback() -> Bool
    {
        if  MainSuggSection.placeReady.value == nil {
            return true
        }else{
            self.gfilter.type = .City
            MainSuggSection.placeReady.swap(nil)
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
        if self.gfilter.type == .City {
            self.titleSignal.swap(compPre.attributedFullText.string)
        }else{
            self.searchTitle.swap(compPre.attributedPrimaryText.string)
        }
        self.searchFetchResults.swap([])
        self.seacrhCity.swap("")
    }
}
