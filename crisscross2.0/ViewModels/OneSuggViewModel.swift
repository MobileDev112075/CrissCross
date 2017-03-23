
//  OneSuggViewModel
//  RacCriss
//
//  Created by tycoon on 11/13/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import Argo
import Result
import Alamofire
import GoogleMaps
import GooglePlaces
import ReactiveCocoa
import AlamofireImage
import GooglePlacePicker

class OneSuggViewModel :DKViewModel {
    
    private let gplaceCellIdentifier = "GPlaceCell"
    private let contentChangesObserver: Observer<Any, NoError>
    // Outputs
    let contentChangesSignal: Signal<Any, NoError>
    let avatar  = MutableProperty<UIImage?>(nil)
    let bkimage = MutableProperty<UIImage?>(nil)
    var feeds   = [Feedback]()
    
    var address = ""
    
    let hidebt      = MutableProperty(true)
    let place       = MutableProperty<GMSPlace?>(nil)
    let images      = MutableProperty<[UIImage]>([])
    
    // MARK: - Lifecycle
    
    
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    
    override init(store: StoreType) {
        
        let (contentChangesSignal, contentChangesObserver) = Signal<Any, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        super.init(store: store)
        
        active.producer
            .filter { $0 }
            .map { _ in () }
            .start(refreshObserver)
        
        MainSuggSection.updateFeedback.producer
            .filter { $0.characters.count>0 }
            .map { _ in () }
            .start(refreshObserver)
        
        var selectedChild = Shared.MyInfo.selectedChild.value!
        
        self.address = selectedChild.item_title
        self.title = selectedChild.title
        
        SignalProducer(signal: refreshSignal)
            .on(next: { [weak self] _ in self?.isLoading.value = true
                if  MainSuggSection.updateFeedback.value.characters.count > 0 {
                    var ids = selectedChild.allIds
                    ids?.append(MainSuggSection.updateFeedback.value)
                    selectedChild.allIds = ids
                }})
            .flatMap(.Latest){ [weak self] _ in
                return (self?.myStore.fetchFeedback(selectedChild)
                    .flatMapError { error in
                        self?.alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer(value: [])})!
            }
            .combinePrevious([]) // Preserve history to calculate changeset
            .startWithNext({ [weak self] (oldfees, newfeeds) in
                self?.feeds = newfeeds
                if let observer = self?.contentChangesObserver {
                    let changeset = Changeset(
                        oldItems: oldfees,
                        newItems: newfeeds,
                        contentMatches: Feedback.contentMatches
                    )
                    observer.sendNext(changeset)
                }
                })
        
        SignalProducer(signal: refreshSignal)
            .on(next: { [weak self] _ in self?.isLoading.value = true })
            .flatMap(.Latest){  [weak self] _ in
                return (self?.myStore.fetchGPlaceAutocomplete(selectedChild)
                    .flatMapError { error in
                        self?.alertMessageObserver.sendNext(error.localizedDescription)
                        return SignalProducer.empty
                    })!
            }
            .startWithNext { [weak self] (locationC) in
                MainSuggSection.editMyChildrenLocation.swap(false)
                MainSuggSection.editChildrenLocation.swap(locationC)
                self?.place.swap(locationC.place)
        }
        
        self.place.producer
            .ignoreNil()
            .filter{$0.phoneNumber != nil}
            .startWithNext {  [weak self] (place) in
                self?.hidebt.swap(false)
        }
    }
    
    let selectedChild = Shared.MyInfo.selectedChild.value!
    var backImage: SignalProducer<(UIImage), NSError> {
        return BackgroundImage(child: selectedChild).fetchImageSignal()
    }
    
    // MARK: - Data Source
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfMatchesInSection(section: Int) -> Int {
        return feeds.count
    }
    
    func feedbackViewModel(indexPath: NSIndexPath) -> FeedbackCellModel {
        let feed = feedbackAtIndexPath(indexPath)
        return FeedbackCellModel(feedback:feed)
    }
    
    func editMyfeedback(indexPath: NSIndexPath) -> Bool
    {
        //        let feed = feedbackAtIndexPath(indexPath)
        //        if feed.userId == Shared.MyInfo.myIdentifier {
        //            MainSuggSection.editMyChildrenLocation.swap(true)
        //            return true
        //        }
        return false
    }
    
    // MARK: Internal Helpers
    
    private func feedbackAtIndexPath(indexPath: NSIndexPath) -> Feedback {
        return feeds[indexPath.row]
    }
    
}

