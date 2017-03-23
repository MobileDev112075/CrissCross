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

enum PlanSection:Int {
    case PlanSectionDates = 0
    case PlanSectionDays = 1
    case PlanSectionCalendar = 2
    case PlanSectionHow = 3
    case PlanSectionType = 4
    case PlanSectionVisible = 5
    case PlanSectionInvite = 6
    case PlanSectionDetails = 7
    case PlanSectionAddPlan = 8
    
}

enum FriendsScreen:Int {
    case FriendsScreenProfile = 0
    case FriendsScreenAddPlan = 1
    case FriendsScreenRemove = 2
}

struct MainSection {
    
    static var createPlanType:AppPlanType = AppPlanType.AppPlanTypeSure
    
    static let FScreenStatus    = MutableProperty<Int>(0)
    static let showSections     = MutableProperty<[Int]>([])
    static let startDate        = MutableProperty<NSDate?>(nil)
    static let endDate          = MutableProperty<NSDate?>(nil)
    static let planDates        = MutableProperty<(NSDate,NSDate)?>(nil)
    static let planPid          = MutableProperty<(NSString,NSString)>("","")
    
    static let monthTitle       = MutableProperty<String>("")
    static let endDateTitle     = MutableProperty<String>("Return date: ")
    static let startDateTitle   = MutableProperty<String>("Depart date: ")
    static let end              = MutableProperty<Bool>(false)
    
    static let planRequest      = Signal<[String:String], NoError>.pipe()
    static let planSavedResult  = Signal<[Plan], NoError>.pipe()
    static let showCal          = Signal<Void, NoError>.pipe()
    static let showFriends      = Signal<Void, NoError>.pipe()
    static let cal_prev         = Signal<Void, NoError>.pipe()
    static let cal_next         = Signal<Void, NoError>.pipe()
    static let howType          = MutableProperty<Int>(0)
    static let planType         = MutableProperty<Int>(0)
    static let planVisible      = MutableProperty<Int>(0)
    
    
    
    static let planTypes        = MutableProperty<[FilterModel]>(Shared.MyInfo.allFilterModels["PlanTypes"]!)
    static let visiTypes        = MutableProperty<[FilterModel]>(Shared.MyInfo.allFilterModels["PlanVisible"]!)
}


class CreatePSectionModel {
    
    typealias MatchChangeset = Changeset<Int>
    
    private let datesCellIdentifier     = "DatesSectionCell"
    private let daysCellIdentifier      = "DaysSectionCell"
    private let calendarCellIdentifier  = "CalendarSectionCell"
    private let howCellIdentifier       = "HowSectionCell"
    private let typeCellIdentifier      = "TypeSectionCell"
    private let visibleCellIdentifier   = "VisibleToSectionCell"
    private let inviteCellIdentifier    = "InviteSectionCell"
    private let detailsCellIdentifier   = "DetailsSectionCell"
    private let addPlanCellIdentifier   = "AddPlanSectionCell"
    
    private let store: StoreType
    private let contentChangesObserver: Observer<MatchChangeset, NoError>
    
    // Inputs
    
    let active = MutableProperty(false)
    
    // Outputs
    
    let contentChangesSignal: Signal<MatchChangeset, NoError>
    let isLoading: MutableProperty<Bool>
    
    
    init(store: StoreType){
        self.store = store
        
        
        let (contentChangesSignal, contentChangesObserver) = Signal<MatchChangeset, NoError>.pipe()
        self.contentChangesSignal = contentChangesSignal
        self.contentChangesObserver = contentChangesObserver
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        active.producer
            .filter { $0 }
            .map { _ in () }
            .startWithNext({
//                MainSection.showSections.swap([])
            })
        
        MainSection.planPid.signal
            .observeNext({ (pid) in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 800), dispatch_get_main_queue(), { () -> Void in
                    MainSection.showSections.swap([PlanSection.PlanSectionDates.rawValue])
                })
            })
        
        MainSection.showCal.0
            .observeNext({ () in
                MainSection.showSections.swap([PlanSection.PlanSectionDates.rawValue,PlanSection.PlanSectionDays.rawValue])
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200), dispatch_get_main_queue(), { () -> Void in
                    MainSection.showSections.value.insert(PlanSection.PlanSectionCalendar.rawValue, atIndex: 2)
                })
            })
        
        
        
        MainSection.planDates.signal
            .observeNext { (type) in
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    MainSection.showSections.swap([PlanSection.PlanSectionDates.rawValue,PlanSection.PlanSectionHow.rawValue])
                }
        }
        
        MainSection.howType.signal
            .observeNext { (type) in
                MainSection.showSections.swap([PlanSection.PlanSectionDates.rawValue,PlanSection.PlanSectionHow.rawValue,PlanSection.PlanSectionType.rawValue])
        }
        
        
        MainSection.planType.signal
            .observeNext { (type) in
                MainSection.showSections.swap([PlanSection.PlanSectionDates.rawValue,PlanSection.PlanSectionHow.rawValue,PlanSection.PlanSectionType.rawValue,PlanSection.PlanSectionVisible.rawValue])
        }
        
        MainSection.planVisible.signal
            .observeNext { (type) in
                MainSection.showSections.swap([PlanSection.PlanSectionDates.rawValue,PlanSection.PlanSectionHow.rawValue,PlanSection.PlanSectionType.rawValue,PlanSection.PlanSectionVisible.rawValue,PlanSection.PlanSectionAddPlan.rawValue])
        }
        
        MainSection.showSections.signal
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
        
       MainSection.planRequest.0
        .observeNext { (dict) in
            self.store.savePlan(dict)
                .on(next: { (plans:[Plan]) in
                    MainSection.planSavedResult.1.sendNext(plans)
                }).start()
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if MainSection.showSections.value[indexPath.row] == 1 {
            return 40
        }
        if MainSection.showSections.value[indexPath.row] == 2 {
            let a = tableView.frame.size.width
            return a
        }
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainSection.showSections.value.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell!
        switch Int(MainSection.showSections.value[indexPath.row]) {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(datesCellIdentifier, forIndexPath: indexPath)
            break
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(daysCellIdentifier, forIndexPath: indexPath)
            break
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(calendarCellIdentifier, forIndexPath: indexPath)
            break
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier(howCellIdentifier, forIndexPath: indexPath)
            break
        case 4:
            cell = tableView.dequeueReusableCellWithIdentifier(typeCellIdentifier, forIndexPath: indexPath)
            break
        case 5:
            cell = tableView.dequeueReusableCellWithIdentifier(visibleCellIdentifier, forIndexPath: indexPath)
            break
        case 6:
            cell = tableView.dequeueReusableCellWithIdentifier(inviteCellIdentifier, forIndexPath: indexPath)
            break
        case 7:
            cell = tableView.dequeueReusableCellWithIdentifier(detailsCellIdentifier, forIndexPath: indexPath)
            break
        case 8:
            cell = tableView.dequeueReusableCellWithIdentifier(addPlanCellIdentifier, forIndexPath: indexPath)
            break
            
        default:
            cell = tableView.dequeueReusableCellWithIdentifier(addPlanCellIdentifier, forIndexPath: indexPath)
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            if let string = cell.reuseIdentifier {
                if (string == addPlanCellIdentifier){
                    
                    self.createPlan()
                }
            }
        }
    }
    
    func createPlan(){
        MainSection.showSections.swap([])
        
        let st = String(round((MainSection.startDate.value?.timeIntervalSince1970)!)).stringByReplacingOccurrencesOfString(".", withString: "")
        let et = String(round((MainSection.endDate.value?.timeIntervalSince1970)!)).stringByReplacingOccurrencesOfString(".", withString: "")
        
        let dict:[String:String] =
            [   "plan_type":String(MainSection.createPlanType.rawValue),
                "where_id":MainSection.planPid.value.0 as String,
                "where_place[id]":MainSection.planPid.value.0 as String,
                "where_place[title]":MainSection.planPid.value.1 as String,
                "when_start":String(st),
                "when_end":String(et),
                "how_id":String(MainSection.howType.value),
                "type_ids":String(MainSection.planType.value),
                "groupIds[]":"all",
                "type_ids[]":"2"]
        
        self.store.savePlan(dict)
        MainSection.planRequest.1.sendNext(dict)
    }
    
    
}
