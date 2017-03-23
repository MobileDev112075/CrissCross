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

enum SuggSection:Int {
    case SuggSectionSort        = 0
    case SuggSectionPhoto       = 1
    case SuggSectionPrice       = 2
    case SuggSectionComments    = 3
    case SuggSectionAdd         = 4
    case SuggSectionAddComments = 8
    case SuggSectionText        = 10
}

struct MainSuggSection {
    
    static var editChildrenLocation = MutableProperty<LocationChild?>(nil)
    static var editMyChildrenLocation = MutableProperty(false)
    
    static var createPlanType:AppPlanType = AppPlanType.AppPlanTypeSure
    
    static let showSections     = MutableProperty<[Int]>([])
    
    static let sortReady        = MutableProperty<[[FilterModel]]>([])
    static let cityReady        = MutableProperty<GMSPlace?>(nil)
    static let placeReady       = MutableProperty<GMSPlace?>(nil)
    static let priceReady       = MutableProperty<Int>(0)
    static let photoReady       = MutableProperty<UIImage?>(nil)
    static let commeReady       = MutableProperty("")
    
    static let updateFeedback   = MutableProperty("")
    
    static let planRequest      = Signal<[String:String], NoError>.pipe()
    static let planSavedResult  = Signal<[Plan], NoError>.pipe()
    
    static let howType          = MutableProperty<Int>(0)
    static let planType         = MutableProperty<Int>(0)
    static let planVisible      = MutableProperty<Int>(0)
    
    static let planTypes        = MutableProperty<[FilterModel]>(Shared.MyInfo.allFilterModels["PlanTypes"]!)
    static let visiTypes        = MutableProperty<[FilterModel]>(Shared.MyInfo.allFilterModels["PlanVisible"]!)
    
}


class CreateSuggSecModel:DKViewModel {
    
    typealias MatchChangeset = Changeset<Int>
    
    private let addCellIdentifier       = "SuggSectionAddCell"
    private let sortCellIdentifier      = "SuggSectionSortCell"
    private let photoCellIdentifier     = "SuggSectionPhotoCell"
    private let priceCellIdentifier     = "SuggSectionPriceCell"
    private let commeCellIdentifier     = "SuggSectionCommentsCell"
    private let textCellIdentifier      = "SuggSectionTextViewCell"
    private let addCommeCellIdentifier  = "SuggSectionAddCommentsCell"
    
    private let contentChangesObserver: Observer<MatchChangeset, NoError>
    private var filterHeight = 140
    private var lock = false
    private var editAddComment = false
    
    // Outputs
    let contentChangesSignal: Signal<MatchChangeset, NoError>
    let keyBoardSignal = NSNotificationCenter.defaultCenter().rac_addObserverForName(UIKeyboardWillShowNotification, object: nil)
    
    let stopEditing = Signal<Void, NoError>.pipe()
    let addPhotoSelect = Signal<Void, NoError>.pipe()
    let photoSelected: MutableProperty<UIImage?> = MutableProperty(nil)
    
    var sortFilterSections      = MutableProperty<[[FilterModel]]>([])
    var sortFilterTreeHistory   = MutableProperty<[(Int,Int)]>([])
    
    // MARK: - Lifecycle
    
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    override init(store: StoreType){
        
        let (contentChangesSignal, contentChangesObserver) = Signal<MatchChangeset, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        
        super.init(store: store)
        
        self.editAddComment = MainSuggSection.editChildrenLocation.value != nil
        
        self.sortFilterSections.swap([Shared.MyInfo.allFilterModels["FilterAct"]!])
        self.sortFilterTreeHistory.producer
            .filter{$0.count>0}
            .filter({ (nums) -> Bool in
                let num = nums.last!
                return self.sortFilterSections.value.count>num.0
            })
            .startWithNext {(nums) in
                if let num = nums.last{
                    var vis = self.sortFilterSections.value
                    let filterM = vis[num.0][num.1]
                    vis = Array(vis[0..<num.0+1])
                    if let call = filterM.call,
                        let newfm = Shared.MyInfo.allFilterModels[call]
                    {
                        vis.append(newfm)
                    }
                    self.sortFilterSections.swap(vis)
                }
                if (nums.count == 2) {
                    MainSuggSection.sortReady.swap(self.sortFilterSections.value)
                }
        }
        
        
        MainSuggSection.showSections.signal
            .combinePrevious([]) // Preserve history to calculate changeset
            .observeNext({ [weak self] (oldIdx, newIdx)  in
                if let observer = self?.contentChangesObserver {
                    let changeset = Changeset(
                        oldItems: oldIdx,
                        newItems: newIdx,
                        contentMatches: CreateSurePlanModel.contentMatches
                    )
                    observer.sendNext(changeset)
                }
                }
        )
        
        MainSuggSection.showSections.swap([])
        MainSuggSection.placeReady
            .producer
            .startWithNext { (place) in
                if let _ = place {
                    UIView.animateWithDuration(0.5) {
                        MainSuggSection.showSections.swap([0])
                    }
                }else{
                    UIView.animateWithDuration(0.5) {
                        MainSuggSection.showSections.swap([])
                    }
                }
        }
        
        MainSuggSection.sortReady.signal
            .filter({ $0.count > 0 })
            .observeNext {[weak self] (type) in
                self?.smoothy()
        }
        
        self.photoSelected.signal
            .observeNext { [weak self] (image) in
                MainSuggSection.photoReady.swap(image)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) { () -> Void in
                    MainSuggSection.showSections.swap([0])
                }
                self?.smoothy()
        }
    }
    
    func smoothy() {
        if (!lock){
            lock = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))),
                           dispatch_get_main_queue()) { () -> Void in
                            MainSuggSection.showSections.swap([0,1])
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))),
                                           dispatch_get_main_queue()) { () -> Void in
                                            MainSuggSection.showSections.swap([0,1,2])
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))),
                                                           dispatch_get_main_queue()) { () -> Void in
                                                            MainSuggSection.showSections.swap([0,1,2,3])
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))),
                                                                           dispatch_get_main_queue()) { () -> Void in
                                                                            MainSuggSection.showSections.swap([0,1,2,3,4])
                                                                            self.lock = false
                                                            }
                                            }
                            }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if MainSuggSection.showSections.value[indexPath.row] == 1 {
            if (self.photoSelected.value != nil){
                return 137
            }
        }
        if MainSuggSection.showSections.value[indexPath.row] == 0 {
            return CGFloat(filterHeight)
        }
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainSuggSection.showSections.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell!
        switch Int(MainSuggSection.showSections.value[indexPath.row]) {
        case 0:
            let sortCell:SuggSectionSortCell = tableView.dequeueReusableCellWithIdentifier(sortCellIdentifier, forIndexPath: indexPath) as! SuggSectionSortCell
            
            sortCell.filterTableView.viewModel.filterSections = self.sortFilterSections
            sortCell.filterTableView.viewModel.filterTreeHistory = self.sortFilterTreeHistory
            
            self.sortFilterSections.signal
                .observeOn(UIScheduler())
                .observeNext({ _ in
                    sortCell.filterTableView.reloadData()
                })
            
            
            cell = sortCell
            break
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(photoCellIdentifier, forIndexPath: indexPath)
            if let image =  self.photoSelected.value {
                if let photoAdded = cell.viewWithTag(10) as? UIImageView {
                    photoAdded.image = image
                }
            }
            break
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(priceCellIdentifier, forIndexPath: indexPath)
            break
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier(commeCellIdentifier, forIndexPath: indexPath)
            if let addTextView = cell.viewWithTag(10) as? UILabel,
                let textView = cell.viewWithTag(25) as? UITextView{
                if MainSuggSection.commeReady.value.characters.count > 0 {
                    addTextView.hidden = true
                    textView.text = MainSuggSection.commeReady.value
                }else{
                    addTextView.hidden = false
                }
            }
            break
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier(addCellIdentifier, forIndexPath: indexPath)
            break
        case 8:
            cell = tableView.dequeueReusableCellWithIdentifier(addCommeCellIdentifier, forIndexPath: indexPath)
            break
        case 10:
            cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
            if let textView = cell.viewWithTag(10) as? UITextView {
                textView.becomeFirstResponder()
                MainSuggSection.commeReady <~ textView.signalProducer()
            }
            break
        default:
            cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            if let string = cell.reuseIdentifier {
                if (string == addCellIdentifier){
                    self.createSugg()
                }
                if (string == photoCellIdentifier){
                    self.addPhotoSelect.1.sendNext()
                }
                if (string == commeCellIdentifier){
                    MainSuggSection.showSections.swap([10,8])
                }
                if (string == addCommeCellIdentifier)
                {
                    
                    self.stopEditing.1.sendNext()
                    self.smoothy()
                }
                
            }
        }
    }
    
    
    func createSugg(){

        var lid = ""
        var title = ""
        
        let price   = MainSuggSection.priceReady.value
        let comme   = MainSuggSection.commeReady.value
        let image   = MainSuggSection.photoReady.value
        
        let subcat  = self.filterCat()
        
        if let place = MainSuggSection.placeReady.value
        {
            
            if let city = MainSuggSection.cityReady.value {
                title = place.name
                lid = city.placeID
            }else if let locationChild = MainSuggSection.editChildrenLocation.value {
                title = locationChild.child.item_title
                lid = locationChild.child.lid!
            }
            
            let dict = ["a":"sitem", "title":title, "comment":comme, "lid":lid, "rating":"\(price)", "subcat_id":subcat, "v":"11", "token":Shared.MyInfo.myToken]
            self.myStore.editSaveSugg(dict , image: image).startWithResult({ (result) in
                switch result {
                case .Success(let str):
                    MainSuggSection.updateFeedback.swap(str)
                    break
                case .Failure(let err):
                    print(err.domain)
                    break
                    
                }
            })
        }
    }
    
    
    func  filterCat() -> String{
        if let filterA = MainSuggSection.sortReady.value.last,
            let history = self.sortFilterTreeHistory.value.last
        {
            return filterA[history.1].typeID ?? "10"
        }
        return "20"
    }
    
    func addPhoto(){
        
        //
        //        - (IBAction)doChangePhoto {
        //            if(!_imagePicker){
        //                _imagePicker = [[VTImagePicker alloc] init];
        //                _imagePicker.delegateViewController = self;
        //            }
        //            [_imagePicker presentPhotoPicker];
        //        }
        //   
    }
}
