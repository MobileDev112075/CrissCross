//
//  AppPlanAddViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DPCalendarMonthlyView.h"



@interface AppPlanAddViewController : AppViewController<DPCalendarMonthlyViewDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate,UISearchBarDelegate>{
    NSMutableArray *_items;
    NSArray *_sectionTypeBtns;
    NSArray *_sectionHowBtns;
    AFHTTPRequestOperationManager *_searchManager;
    int _lastTicket;
    NSMutableDictionary *_previousResults;
    NSString *_selectedWhereId;
    NSMutableArray *_multiCellSelected;
    
    NSDictionary *_placePicked;
    int _howIdx;
    int _typeIdx;
    BOOL _isEditing;
    UIScrollView *_scrollViewGroups;
    
    UIView *_calendarViewHolder;
    DPCalendarMonthlyView *_calendarView;
    UIView *_calendarViewWrapper;
    UILabel *_calStartDateText;
    UILabel *_calEndDateText;
    UILabel *_calendarMonthTitle;
    UIButton *_calBtnContinue;
    NSDate *_firstTapDate;
    NSDate *_secondTapDate;
    DPCalendarEvent *_calEvent;
    BOOL _calDoingUpdate;
    BOOL _calDoingUpdateLong;
    BOOL _searchActive;
    UILabel *_arrowLeft;
    UILabel *_arrowRight;
    
    
    
    UIView *_backgroundHighlight;
    
    UIView *_viewUpper;
    UIView *_viewLower;
    UITextField *_inputCity;
    UIButton *_btnDateStart;
    UIButton *_btnDateEnd;
    UIButton *_btnCancelCityView;
    UIView *_viewHow;
    UIView *_viewType;
    NSMutableArray *_sections;
    NSMutableArray *_searchResultsFriendsToInvite;
    UIView *_viewGroups;
    UIView *_viewSave;
    UIButton *_btnSave;
    NSString *_originalCityName;
    UIButton *_btnInviteFriends;

    NSMutableArray *_sharingGroups;
    
    UIView *_inviteMoreFriendsBanner;
    UIButton *_inviteMoreFriendsBannerHitArea;
    UILabel *_inviteMoreFriendsText1;
    UILabel *_inviteMoreFriendsText2;

}


@property (assign, nonatomic) AppPlanType planType;
@property (strong, nonatomic) AppPlan *editingPlan;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDate *startingDate;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *cityView;
@property (strong, nonatomic) IBOutlet UITableView *tableViewCity;


@property (strong, nonatomic) IBOutlet UIView *inviteFriendsView;
@property (strong, nonatomic) IBOutlet UIView *inviteFriendsViewInner;
@property (strong, nonatomic) IBOutlet UITableView *tableViewInviteFriends;


@property (strong, nonatomic) IBOutlet UIView *viewChangePlanType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *planTypeSegment;



@end
