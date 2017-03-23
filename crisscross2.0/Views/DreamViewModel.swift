//
//  CreatePSectionModel.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/27/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import Argo
import Result
import ReactiveCocoa
import GooglePlaces

class DreamViewModel {
    
 
    
    typealias DreamChangeset = Changeset<NSDictionary>
    // Inputs
    let active = MutableProperty(false)
    let editActive = MutableProperty(false)
    let seacrhCity = MutableProperty("")
    let refreshObserver: Observer<Void, NoError>
    // Outputs
    let searchFetchResults =    MutableProperty<[GMSAutocompletePrediction]>([])
    
    let title: String
    let contentChangesSignal: Signal<DreamChangeset, NoError>
    let alertMessageSignal: Signal<String, NoError>
    let isLoading: MutableProperty<Bool>
    var dictionary:[NSDictionary] = []
    
    
    let gfilter = GMSAutocompleteFilter()
    private var bounds:GMSCoordinateBounds? = nil

    private let store: StoreType
    private let contentChangesObserver: Observer<DreamChangeset, NoError>
    private let alertMessageObserver: Observer<String, NoError>
    var dreams: [Dreaming]

    // MARK: - Lifecycle
    
    init(store: StoreType) {
        
        self.gfilter.type = .City
        self.title = "Dreaming of"
        self.store = store
        self.dreams = []
        
        let (refreshSignal, refreshObserver) = Signal<Void, NoError>.pipe()
        self.refreshObserver = refreshObserver
        
        let (contentChangesSignal, contentChangesObserver) = Signal<DreamChangeset, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        let (alertMessageSignal, alertMessageObserver) = Signal<String, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
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

        searchFetchResults.producer
            .filter {$0.count > 0}
            .map { _ in () }
        
        
        
        

        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        editActive.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        SignalProducer(signal: refreshSignal)
            .on(next: { _ in isLoading.value = true })
            .flatMap(.Latest) { _ in
                return store.fetchDream()
                    .flatMapError { error in
                        alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])}}
            .on(next: { _ in isLoading.value = false })
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldDreams, newDreams) in
                self?.dreams = newDreams
                self?.convert()
            })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dictionary.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func dreamTitleAtIndex(indexPath: NSIndexPath) -> String {
        let dict = self.dictionary[indexPath.row]
        return dict["title"] as! String
    }
    
    func contentMatches(lhs: NSDictionary, _ rhs: NSDictionary) -> Bool {
        return lhs["title"] as! String  == rhs["title"] as! String
    }
    
    func convert() {
        var dict:[NSDictionary] = []
        for d in dreams
        {
            let t = ["db_id":d.db_id,"id":d.id_id,"title":d.title,"reference":d.reference]
            dict.append(t)
        }
        
        
        let observer = self.contentChangesObserver
        let changeset = Changeset(
                oldItems: self.dictionary,
                newItems: dict,
                contentMatches: self.contentMatches
            )
        self.dictionary = dict
        observer.sendNext(changeset)
    }
    
    

}

