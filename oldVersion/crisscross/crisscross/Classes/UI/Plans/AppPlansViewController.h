//
//  AppPlansViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "DPCalendarMonthlyView.h"
#import "MGSwipeTableCell.h"

@interface AppPlansViewController : AppViewController<DPCalendarMonthlyViewDelegate,UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>{
    DPCalendarMonthlyView *_calendarView;
    NSMutableArray *_items;
    NSMutableArray *_multiCellSelected;
    NSMutableArray *_events;
    BOOL _isOwner;
    AppUser *_tempUser;
    NSMutableArray *_usersThere;
    NSTimeInterval _firstTap;
    NSDate *_firstTapDate;
    UIView *_hintView;
    BOOL _haveConflicts;
    UILabel *_conflictLabel;
    UILabel *_conflictLabelByline;
    
    UIActivityIndicatorView *_act;

}

@property (strong, nonatomic) IBOutlet CCButton *btnPlus;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (assign, nonatomic) AppPlanType planType;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *calendarMonthTitle;
@property (strong, nonatomic) IBOutlet CCButton *btnCalendarLeft;
@property (strong, nonatomic) IBOutlet CCButton *btnCalendarRight;
@property (strong, nonatomic) NSString *mainContactId;
@property (strong, nonatomic) IBOutlet UITableView *tableThere;
@property (strong, nonatomic) IBOutlet UIView *viewThere;
@property (strong, nonatomic) IBOutlet CCButton *btnClose;
@property (strong, nonatomic) IBOutlet UIView *viewTableThereInner;

- (IBAction)doAdd;
- (IBAction)doMonthForward;
- (IBAction)doMonthBack;
- (IBAction)doCloseFriendView;

@end
