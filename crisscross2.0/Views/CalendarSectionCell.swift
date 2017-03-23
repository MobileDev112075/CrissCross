//
//  CalendarSectionCell.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/27/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import Foundation
import JTAppleCalendar
import Result
import ReactiveCocoa

class CalendarSectionCell: UITableViewCell {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    var numberOfRows = 6
    var viewDidAppear = true
    let formatter = NSDateFormatter()
    let testCalendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        formatter.dateFormat = "MMM dd, YYYY"
        testCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.registerCellViewXib(fileName: "CalendarCellView")
        calendarView.direction = .Horizontal                                 // default is horizontal
        calendarView.cellInset = CGPoint(x: 3, y: 3)                         // default is (3,3)
        calendarView.allowsMultipleSelection = true                         // default is false
        calendarView.firstDayOfWeek = .Sunday                                // default is Sunday
        calendarView.scrollEnabled = true                                    // default is true
        calendarView.scrollingMode = .StopAtEachCalendarFrameWidth
        calendarView.itemSize = round(self.frame.width/7)
        calendarView.rangeSelectionWillBeUsed = true                        // default is false
        calendarView.reloadData()
        calendarView.scrollToDate(NSDate(), triggerScrollToDateDelegate: false, animateScroll: false) {
            let currentDate = self.calendarView.currentCalendarDateSegment()
            self.setupViewsOfCalendar(currentDate.dateRange.start, endDate: currentDate.dateRange.end)
        }
        MainSection.end.producer
        .startWithNext { (end) in
            self.calendarView.allowsMultipleSelection = end
        }
        
        MainSection.cal_prev.0
            .observeNext { _ in
                self.calendarView.scrollToPreviousSegment()
                let currentDate = self.calendarView.currentCalendarDateSegment()
                self.setupViewsOfCalendar(currentDate.dateRange.start, endDate: currentDate.dateRange.end)

        }

        MainSection.cal_next.0
            .observeNext { _ in
                self.calendarView.scrollToNextSegment()
                let currentDate = self.calendarView.currentCalendarDateSegment()
                self.setupViewsOfCalendar(currentDate.dateRange.start, endDate: currentDate.dateRange.end)

        }
    }
    
    @IBAction func printSelectedDates() {
        print("Selected dates --->")
        for date in calendarView.selectedDates {
            print(formatter.stringFromDate(date))
        }
    }
 
    func setupViewsOfCalendar(startDate: NSDate, endDate: NSDate) {
        let month = testCalendar.component(NSCalendarUnit.Month, fromDate: startDate)
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        let year = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: startDate)
        MainSection.monthTitle.swap(monthName + " " + String(year))
    }


}

extension CalendarSectionCell: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        
        let firstDate = NSDate()
        let threeYears = NSCalendar.currentCalendar()
            .dateByAddingUnit(
                .Year,
                value: 3,
                toDate: firstDate,
                options: []
        )
        let secondDate = threeYears
        let aCalendar = NSCalendar.currentCalendar() // Properly configure your calendar to your time zone here
        return (startDate: firstDate, endDate: secondDate!, numberOfRows: numberOfRows, calendar: aCalendar)
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        (cell as? CalendarCellView)?.setupCellBeforeDisplay(cellState, date: date)
    }
    
    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CalendarCellView)?.cellSelectionChanged(cellState)
        if (MainSection.end.value){
            self.calendarView.selectDates(from: date, to: MainSection.endDate.value!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
            MainSection.endDateTitle.swap(formatter.stringFromDate(date))
            MainSection.endDate.swap(date)
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, canSelectDate date: NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        if (MainSection.end.value){
            MainSection.endDateTitle.swap(formatter.stringFromDate(date))
            if let startDate = MainSection.startDate.value{
                MainSection.endDate.swap(date)
                if let oneDayAfter =
                    NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: startDate, options: [])
                {
                    if date == oneDayAfter {
                        self.calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                    }else{
                        self.calendarView.selectDates(from: oneDayAfter, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                    }
                }
                selectionDone()
                return false
            }
             MainSection.end.swap(false)
            return true
        }
        return true
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CalendarCellView)?.cellSelectionChanged(cellState)
        if (!MainSection.end.value){
            self.calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
            MainSection.startDate.swap(date)
            MainSection.startDateTitle.swap(formatter.stringFromDate(date))
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToResetCell cell: JTAppleDayCellView) {
        if (viewDidAppear) {
            viewDidAppear = false
            (cell as? CalendarCellView)?.selectedView.hidden = true
        }
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        setupViewsOfCalendar(startDate, endDate:endDate)
    }
    
    func selectionDone(){
        MainSection.end.swap(false)
        MainSection.planDates.swap((MainSection.startDate.value!,MainSection.endDate.value!))
    }
}

func delayRunOnMainThread(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

