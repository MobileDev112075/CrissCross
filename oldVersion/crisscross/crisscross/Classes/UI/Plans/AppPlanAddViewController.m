//
//  AppPlanAddViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppPlanAddViewController.h"
#import "AppPlansTableViewCell.h"
#import "AppPlansInviteTableViewCell.h"
#import "AppAddGroupsViewController.h"
#import "AppFindFriendViewController.h"
#import "AppCustomGroupsViewController.h"

#define kAppPlansInviteTableViewCell @"AppPlansInviteTableViewCell"
#define kAppStaticCellName @"kAppStaticCellName"



@interface AppPlanAddViewController ()

@end

@implementation AppPlanAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _lastTicket = 0;
    _items = [[NSMutableArray alloc] init];
    _multiCellSelected = [[NSMutableArray alloc] init];
    _searchResultsFriendsToInvite = [[NSMutableArray alloc] init];
    _sharingGroups = [[NSMutableArray alloc] init];
    self.canLeaveWithSwipe = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFriendsUpdated) name:NOTIFICATION_USER_INFO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFriendsUpdated) name:NOTIFICATION_USER_GROUPS_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doUpdateInviteBannerForMore) name:NOTIFICATION_EMAIL_OR_SMS_INVITE_SENT object:nil];
    
    
    
    _previousResults = [[NSMutableDictionary alloc] init];
    [_tableViewInviteFriends registerNib:[UINib nibWithNibName:kAppPlansInviteTableViewCell bundle:nil] forCellReuseIdentifier:kAppPlansInviteTableViewCell];
    
    _sectionTypeBtns = @[
                         @{@"title":@"Family",@"typeId":@"1"},
                         @{@"title":@"Friends",@"typeId":@"2"},
                         @{@"title":@"Work",@"typeId":@"3"},
                         @{@"title":@"Play",@"typeId":@"4"},
                         @{@"title":@"Other",@"typeId":@"5"},
                         ];
    _sectionHowBtns = @[
                        @{@"title":@"'",@"typeId":@"1"},
                        @{@"title":@"w",@"typeId":@"2"},
                        @{@"title":@"k",@"typeId":@"3"},
                        @{@"title":@";",@"typeId":@"4"},
                        ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _inviteFriendsView.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG2] colorWithAlphaComponent:0.9];
    [[AppController sharedInstance].currentUser refreshUserDataFromServer];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)userFriendsUpdated{

    [_tableViewInviteFriends reloadData];
    int btnWidth = 30;
    int startingX = 18;
    int count = 0;
    [_scrollViewGroups removeAllSubviews];
    

    [[AppController sharedInstance].currentUser doubleCheckGroupsHaveAdd];
    int fontSize = roundf(_scrollViewGroups.height * 0.28);

    [_sharingGroups removeAllObjects];
    [_sharingGroups addObject:[[AppGroup alloc] initWithDictionary:@{@"isAll":@"Y",@"title":@"All",@"id":@"all"}]];
    [_sharingGroups addObjectsFromArray:[AppController sharedInstance].currentUser.groups];
    [_sharingGroups addObject:[[AppGroup alloc] initWithDictionary:@{@"isAdd":@"Y",@"title":@"+ Add Groups",@"id":@"add"}]];
    
    UIButton *btnAll;
    
    for(AppGroup *group in _sharingGroups){
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, btnWidth, _scrollViewGroups.height)];
        [b setTitle:group.title forState:UIControlStateNormal];
        [b setTitleColor:[[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:fontSize];
        if(count == 0)
            btnAll = b;
        
        b.tag = count++;
        if(group.isAdd){
            b.tag = -100;
            b.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:roundf(fontSize - fontSize * 0.10)];
        }
        [b addTarget:self action:@selector(groupBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [b sizeToFit];
        b.width += 10;
        b.height = _scrollViewGroups.height;
        startingX += b.width + 20;
        [_scrollViewGroups addSubview:b];
        
        if(!group.isAdd){
            UILabel *icon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            icon.font = [UIFont fontWithName:FONT_ICONS size:roundf(fontSize - fontSize * 0.10)];
            icon.text = @"p";
            [icon sizeToFit];
            icon.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            icon.userInteractionEnabled = NO;
            icon.x = b.width/2 - icon.width/2;
            icon.y = 5;
            [b addSubview:icon];
        }
        
        if(_isEditing){
            if([_editingPlan.sharedWithGroupsIds containsObject:group.groupId]){
                [self groupBtnTapped:b];
            }
        }
    }
    
    if(_isEditing){
        if(_editingPlan.isViewableByAll){
            [self groupBtnTapped:btnAll];
        }
    }else{
        [self groupBtnTapped:btnAll];
    }


    [_scrollViewGroups setContentSize:CGSizeMake(MAX(_scrollViewGroups.width,startingX), _scrollViewGroups.height)];
    
    if(_isEditing){
        
        for(NSString *uid in _editingPlan.sharedWithUsersIds){
            NSPredicate *p = [NSPredicate predicateWithFormat:@"userId MATCHES %@",uid];
            NSArray *foundUser = [[AppController sharedInstance].currentUser.friends filteredArrayUsingPredicate:p];
            
            AppContact *fcontact = [foundUser firstObject];
            NSUInteger idx = [[AppController sharedInstance].currentUser.friends indexOfObject:fcontact];
            if(idx == NSNotFound){
                
            }else{
                NSIndexPath *ip = [NSIndexPath indexPathForRow:idx inSection:0];
                [_multiCellSelected addObject:ip];
            }
        }
        [_tableViewInviteFriends reloadData];
        [self doInviteFriendsDone];
    }
}

-(void)layoutUI{
    
    if(!_didLayout){

        _didLayout = YES;

        if(_editingPlan != nil){
            _isEditing = YES;
            if(_editingPlan.planType == AppPlanTypeSure){
                _topnav.theTitle.text = @"Edit Sure Plans";
            }else{
                _topnav.theTitle.text = @"Edit If Plans";
            }
        }else{
            if(_planType == AppPlanTypeSure){
                _topnav.theTitle.text = @"Add Sure Plans";
            }else{
                _topnav.theTitle.text = @"Add If Plans";
            }
        }
        self.view.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:1];
        _scrollView.backgroundColor = [UIColor clearColor];
        _viewUpper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, roundf((self.view.height - _topnav.view.height) * 0.25))];
        _viewUpper.y = _topnav.view.height;
        _viewUpper.backgroundColor = [UIColor clearColor];
        
        _viewLower = [[UIView alloc] initWithFrame:CGRectMake(0, _viewUpper.maxY, self.view.width, self.view.height - _viewUpper.maxY)];
        _viewLower.backgroundColor = [UIColor clearColor];
        
        _tableViewCity.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];

        _tableViewCity.tableFooterView = [UIView new];

        
        [self.view addSubview:_viewUpper];
        [self.view addSubview:_viewLower];
        
        _inputCity = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _inputCity.delegate = self;
        int fontSize = roundf((_viewUpper.height/2 - _viewUpper.height/4) * 0.8);

        _inputCity.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Destination City" attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSize], NSForegroundColorAttributeName : [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.5]}];
        
        
        
        _inputCity.textAlignment = NSTextAlignmentCenter;
        _inputCity.textColor = [UIColor whiteColor];
        _inputCity.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSize];
        [_inputCity sizeToFit];
        _inputCity.x = 20;
        _inputCity.width = _viewUpper.width - 40;
        _inputCity.y = _viewUpper.height/2 - _inputCity.height - _inputCity.height/8;
        _inputCity.adjustsFontSizeToFitWidth = YES;
        UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(_inputCity.x, _inputCity.maxY + 3, _inputCity.width, 1)];
        line1.backgroundColor = [UIColor whiteColor];
        [_viewUpper addSubview:_inputCity];
        [_viewUpper addSubview:line1];
        
        _btnDateStart = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _btnDateEnd = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        
        for(UIButton *b in @[_btnDateStart,_btnDateEnd]){
        
            b.layer.borderColor = [UIColor whiteColor].CGColor;
            b.layer.borderWidth = 1;
            b.layer.cornerRadius = 6;
            [b setTitle:@"Arrival Date" forState:UIControlStateNormal];
            b.titleLabel.adjustsFontSizeToFitWidth = YES;
            b.titleLabel.textColor = [UIColor whiteColor];
            b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [b setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            [b addTarget:self action:@selector(doShowPickDateStart) forControlEvents:UIControlEventTouchDown];
            b.width = _viewUpper.width/2 - 40;
            b.x = 20;
            b.height = _viewUpper.height/2/2;
            b.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:roundf(b.height * 0.33)];
            b.y = _inputCity.maxY + ((_viewUpper.height - _inputCity.maxY)/2 - b.height/2);
            
            UILabel *icon1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            icon1.font = [UIFont fontWithName:FONT_ICONS size:roundf(_btnDateStart.height * 0.33)];
            icon1.text = @"u";
            [icon1 sizeToFit];
            icon1.userInteractionEnabled = NO;
            icon1.y = b.height/2 - icon1.height/2;
            icon1.x = b.width - icon1.width - 10;
            icon1.textColor = [UIColor whiteColor];
            [b addSubview:icon1];
        }
    
        [_viewUpper addSubview:_btnDateStart];
        [_btnDateEnd setTitle:@"Departure Date" forState:UIControlStateNormal];
        _btnDateEnd.x = _viewUpper.width - _btnDateEnd.width - 20;
        [_viewUpper addSubview:_btnDateEnd];
    
        _btnCancelCityView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_btnCancelCityView setTitle:@"Cancel" forState:UIControlStateNormal];
        _btnCancelCityView.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:12];
        [_btnCancelCityView sizeToFit];
        _btnCancelCityView.x = _viewUpper.width - _btnCancelCityView.width - 10;
        _btnCancelCityView.y = 10;
        [_btnCancelCityView addTarget:self action:@selector(doCancelCity) forControlEvents:UIControlEventTouchDown];
        _btnCancelCityView.hidden = YES;
        [_viewUpper addSubview:_btnCancelCityView];
        
        
        
        _calendarViewHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _calendarViewHolder.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG2] colorWithAlphaComponent:0.9];
        _calendarViewHolder.width = self.view.width;
        _calendarViewHolder.height = self.view.height;
        
        _calendarViewWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _calendarViewHolder.width-40, _calendarViewHolder.height-60)];
        _calendarViewWrapper.backgroundColor = [UIColor whiteColor];
        [_calendarViewHolder addSubview:_calendarViewWrapper];
        
        int topCalHeight = 55;
        
        UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, _calendarViewWrapper.width/2, 10)];
        l1.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:9];
        l1.text = @"ARRIVAL";
        l1.textAlignment = NSTextAlignmentCenter;
        l1.textColor = [UIColor colorWithHexString:@"#AAAAAA"];
        [_calendarViewWrapper addSubview:l1];
        
        UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake(_calendarViewWrapper.width/2, 10, _calendarViewWrapper.width/2, 10)];
        l2.font = l1.font;
        l2.text = @"DEPARTURE";
        l2.textAlignment = NSTextAlignmentCenter;
        l2.textColor = [UIColor colorWithHexString:@"#AAAAAA"];
        [_calendarViewWrapper addSubview:l2];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(_calendarViewWrapper.width/2,0,0.5,topCalHeight)];
        line.backgroundColor = [UIColor colorWithHexString:@"#E5E4EC"];
        [_calendarViewWrapper addSubview:line];
        
        _calStartDateText = [[UILabel alloc] initWithFrame:CGRectMake(0, l1.maxY, _calendarViewWrapper.width/2, topCalHeight-l1.maxY - 10)];
        _calStartDateText.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:19];
        _calStartDateText.text = @"Feb 9th";
        _calStartDateText.textAlignment = NSTextAlignmentCenter;
        _calStartDateText.adjustsFontSizeToFitWidth = YES;
        _calStartDateText.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        [_calendarViewWrapper addSubview:_calStartDateText];
        
        _calEndDateText = [[UILabel alloc] initWithFrame:CGRectMake(_calendarViewWrapper.width/2, l2.maxY, _calendarViewWrapper.width/2, topCalHeight-l2.maxY - 10)];
        _calEndDateText.font = _calStartDateText.font;
        _calEndDateText.text = @"Feb 9th";
        _calEndDateText.adjustsFontSizeToFitWidth = YES;
        _calEndDateText.textAlignment = NSTextAlignmentCenter;
        _calEndDateText.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        [_calendarViewWrapper addSubview:_calEndDateText];
        
        _calendarMonthTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, topCalHeight, _calendarViewWrapper.width, topCalHeight)];
        _calendarMonthTitle.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:18];
        _calendarMonthTitle.text = @"CURRENT";
        _calendarMonthTitle.textAlignment = NSTextAlignmentCenter;
        _calendarMonthTitle.adjustsFontSizeToFitWidth = YES;
        _calendarMonthTitle.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        [_calendarMonthTitle sizeToFit];
        _calendarMonthTitle.height = topCalHeight;
        
        [_calendarViewWrapper addSubview:_calendarMonthTitle];
        
        UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(0,topCalHeight,_calendarViewWrapper.width,0.5)];
        line2.backgroundColor = [UIColor colorWithHexString:@"#E5E4EC"];
        [_calendarViewWrapper addSubview:line2];
        
        _arrowLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, _calendarMonthTitle.y + (topCalHeight/2)-3, 10, 10)];
        _arrowLeft.font = [UIFont fontWithName:FONT_ICONS size:10];
        _arrowLeft.textColor = _calendarMonthTitle.textColor;
        _arrowLeft.textAlignment = NSTextAlignmentCenter;
        _arrowLeft.text = @".";
        [_arrowLeft sizeToFit];
        
        _arrowRight = [[UILabel alloc] initWithFrame:CGRectMake(0, _arrowLeft.y, 10, 10)];
        _arrowRight.font = _arrowLeft.font;
        _arrowRight.textAlignment = NSTextAlignmentCenter;
        _arrowRight.textColor = _calendarMonthTitle.textColor;
        _arrowRight.text = @"N";
        [_arrowRight sizeToFit];
        
        [_calendarViewWrapper addSubview:_arrowLeft];
        [_calendarViewWrapper addSubview:_arrowRight];
        
        
        _calendarView = [[DPCalendarMonthlyView alloc] initWithFrame:CGRectMake(0, _calendarMonthTitle.maxY, _calendarViewWrapper.width, _calendarViewWrapper.width) delegate:self];
        _calendarView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _calendarView.showsHorizontalScrollIndicator = NO;
        _calendarView.clipsToBounds = YES;
        _calendarView.contentInset = UIEdgeInsetsZero;
        _calendarView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        _calendarView.scrollEnabled = YES;
        _calendarView.pagingEnabled = YES;
        [_calendarViewWrapper insertSubview:_calendarView atIndex:0];
        
        _calendarViewWrapper.x = _calendarViewHolder.width/2 - _calendarViewWrapper.width/2;
        
        _calBtnContinue = [[UIButton alloc] initWithFrame:CGRectMake(0, _calendarView.maxY, _calendarViewWrapper.width, topCalHeight)];
        _calBtnContinue.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:18];
        [_calBtnContinue setTitle:@"Continue" forState:UIControlStateNormal];
        [_calBtnContinue setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
        [_calBtnContinue addTopBorderWithHeight:0.5 andColor:[UIColor colorWithHexString:@"#E5E4EC"]];
        [_calBtnContinue addTarget:self action:@selector(doCalContinue) forControlEvents:UIControlEventTouchUpInside];
        [_calendarViewWrapper addSubview:_calBtnContinue];
        
        _calendarViewWrapper.height = _calBtnContinue.maxY;
        _calendarViewWrapper.x = _calendarViewHolder.width/2 - _calendarViewWrapper.width/2;
        _calendarViewWrapper.y = _calendarViewHolder.height/2 - _calendarViewWrapper.height/2;
        
        
        

        _viewHow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _viewType = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _viewGroups = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _viewSave = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _btnInviteFriends = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        _sections = [[NSMutableArray alloc] initWithArray:@[
                      @{@"title":@"How",@"view":_viewHow},
                      @{@"title":@"Type",@"view":_viewType},
                      @{@"title":@"Visible To",@"view":_viewGroups},
                      @{@"title":@"Save",@"view":_viewSave},
                      ]];
        
        if(_isEditing){
            [_sections insertObject:@{@"title":@"Edit Plan Type",@"view":_viewChangePlanType} atIndex:3];
        }
        
        
        float sectionHeight = roundf((_viewLower.height - (_viewLower.height * 0.10))/[_sections count]);
        float startingY = 0;
        fontSize = roundf(sectionHeight * 0.18);
        int labelMaxY = 0;
        
        
        [_btnInviteFriends setTitle:@"Tap to Invite Friends" forState:UIControlStateNormal];
        _btnInviteFriends.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:roundf(fontSize * 0.80)];
        _btnInviteFriends.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        [_btnInviteFriends setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnInviteFriends sizeToFit];
        _btnInviteFriends.width += 24;
        _btnInviteFriends.titleLabel.adjustsFontSizeToFitWidth = YES;
        _btnInviteFriends.height += 5;
        [_btnInviteFriends addTarget:self action:@selector(doInviteFriendsView) forControlEvents:UIControlEventTouchDown];
        _btnInviteFriends.layer.cornerRadius = 6;
        
        _btnSave = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_btnSave setTitle:@"Save Plan" forState:UIControlStateNormal];
        [_btnSave setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
        _btnSave.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:roundf(fontSize + fontSize * 0.20)];
        _btnSave.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_btnSave addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchDown];
        
        

        for(NSDictionary *dict in _sections){
            
            UIView *v = (UIView *) [dict objectForKey:@"view"];
            v.backgroundColor = [UIColor clearColor];
            v.width = _viewLower.width;
            v.y = startingY;
            [_viewLower addSubview:v];
            v.height = sectionHeight;
            int offsetLabelY = 0;
            if(!_isEditing){
                v.userInteractionEnabled = NO;
            }
            
            if(v == _viewSave){
                [v addSubview:_btnSave];
                _btnSave.width = v.width/2;
                _btnSave.x = v.width/2 - _btnSave.width/2;
                _btnSave.height = v.height;
                continue;
            }else if(v == _viewGroups){
                v.height = roundf(sectionHeight + (_viewLower.height * 0.10));
                _btnInviteFriends.x = roundf(v.width/2 - _btnInviteFriends.width/2);
                _btnInviteFriends.y = roundf(v.height - _btnInviteFriends.height - 5);
                [v addSubview:_btnInviteFriends];
                offsetLabelY = - 10;
                
            }else if(v == _viewChangePlanType){
                _planTypeSegment.x = roundf(v.width/2 - _planTypeSegment.width/2);
                _planTypeSegment.y = roundf(v.height - _planTypeSegment.height - 5);
                [v addSubview:_planTypeSegment];
                offsetLabelY = 10;
            }

            startingY += v.height;
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            lab.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
            lab.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:fontSize];
            lab.textColor = [UIColor whiteColor];
            [lab sizeToFit];
            lab.x = v.width/2 - lab.width/2;
            lab.y = v.height/4 - lab.height/2 + offsetLabelY;
            labelMaxY = lab.maxY;
            [v addSubview:lab];
        }
        
        if(!_isEditing){
            _viewUpper.userInteractionEnabled = YES;
            _viewHow.alpha = 0.10;
            _viewType.alpha = 0.10;
            _viewGroups.alpha = 0.10;
            _viewSave.alpha = 0.10;
            
        }
    
        
        int startingX = 0;
        int count = 1;
        labelMaxY = roundf(_viewHow.height/4);
        fontSize = roundf(_viewHow.height * 0.30);
        int btnWidth = roundf(_viewHow.width/[_sectionHowBtns count]);
        for(NSDictionary *dict in _sectionHowBtns){
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, labelMaxY, btnWidth, _viewHow.height - labelMaxY)];
            [b setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
            [b setTitleColor:[[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
            b.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:fontSize];
            b.tag = count++;
            [b addTarget:self action:@selector(howBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            startingX += b.width;
            [_viewHow addSubview:b];
        }
        labelMaxY = roundf(_viewType.height/2);
        int btnHeight = roundf(_viewType.height - labelMaxY - 10);
        startingX = 8;
        count = 1;
    
        fontSize = roundf(_viewType.height * 0.14);
        btnWidth = roundf((_viewType.width - 8)/[_sectionTypeBtns count]);
        for(NSDictionary *dict in _sectionTypeBtns){
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, labelMaxY, btnWidth, btnHeight)];
            [b setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
            b.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:fontSize];
            b.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.5].CGColor;
            b.layer.borderWidth = 1;
            b.layer.cornerRadius = 6;
            b.titleLabel.adjustsFontSizeToFitWidth = YES;
            b.selected = NO;
            [b addTarget:self action:@selector(typeBtnTapped:) forControlEvents:UIControlEventTouchDown];
            b.tag = count++;
            [b sizeToFit];
            b.height = btnHeight;
            b.width = btnWidth - 8;
            startingX += b.width + 8;
            [_viewType addSubview:b];
        }
        
        
        
        
        _scrollViewGroups = [[UIScrollView alloc] initWithFrame:CGRectMake(0, labelMaxY - 5, _viewGroups.width, _viewGroups.height - labelMaxY - _btnInviteFriends.height - 5)];
        _scrollViewGroups.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
        [_viewGroups addSubview:_scrollViewGroups];
        
        
        
        if(_isEditing){
            
            _inputCity.text = _editingPlan.title;
            _placePicked = @{};
            
            _firstTapDate = [NSDate dateWithTimeIntervalSince1970:_editingPlan.startDateInterval];
            _secondTapDate = [NSDate dateWithTimeIntervalSince1970:_editingPlan.endDateInterval];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMM dd, yyyy"];
            
            [_btnDateStart setTitle:[dateFormat stringFromDate:_firstTapDate] forState:UIControlStateNormal];
            [_btnDateEnd setTitle:[dateFormat stringFromDate:_secondTapDate] forState:UIControlStateNormal];
            
            _selectedWhereId = _editingPlan.locationsId;
            _viewChangePlanType.hidden = NO;
            
            _planTypeSegment.selectedSegmentIndex = _editingPlan.planType == AppPlanTypeIf;
            [_planTypeSegment setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE size:12], NSForegroundColorAttributeName : [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:1 ] } forState:UIControlStateSelected];
            [_planTypeSegment setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE size:12], NSForegroundColorAttributeName : [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:1 ] } forState:UIControlStateNormal];
            
            _planTypeSegment.tintColor = [UIColor colorWithHexString:@"FFFFFF"];
            
            for(UIView *v in _viewHow.subviews){
                if([v isKindOfClass:[UIButton class]]){
                    UIButton *b = (UIButton *) v;
                    
                    if(b.tag == _editingPlan.howTransitId){
                        [self howBtnTapped:b];
                    }
                }
            }
            
            for(UIButton *b in _viewType.subviews){
                NSString *theTag = [NSString stringWithFormat:@"%d",(int)b.tag];
                if([_editingPlan.kindOfPlanIds containsObject:theTag]){
                    [self typeBtnTapped:b];
                }
            }
            

        }else{
            
            if(_startingDate){
                _firstTapDate = _startingDate;
            }
            
            _viewChangePlanType.hidden = YES;
            _btnSave.y = 0;
            if(_firstTapDate != nil){
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMM dd, yyyy"];
                [_btnDateStart setTitle:[dateFormat stringFromDate:_firstTapDate] forState:UIControlStateNormal];
            }
           
        }
        
        
        
        if(!_isEditing){
            [_inputCity becomeFirstResponder];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_inputCity becomeFirstResponder];
            });
        }else{
            [[AppController sharedInstance] hideKeyboard];
        }
        
        
        if(_firstTapDate){
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMM dd"];
            _calStartDateText.text = [dateFormat stringFromDate:_firstTapDate];
            
            _calDoingUpdate = NO;
            if(_secondTapDate){
                _calEndDateText.text = [dateFormat stringFromDate:_secondTapDate];
                _calEvent = [[DPCalendarEvent alloc] initWithTitle:@"title" startTime:_firstTapDate endTime:_secondTapDate colorIndex:0];
            }else{
                _calEndDateText.text = @"-";
                _calEvent = [[DPCalendarEvent alloc] initWithTitle:@"title" startTime:_firstTapDate endTime:_firstTapDate colorIndex:0];
            }
            _calEvent.doFillWithColor = YES;
            _calEvent.fillWithColor = @"#ADF0FB";
            _calEvent.fillWithColorOn = @"#50DDF7";
            [_calendarView setEvents:@[_calEvent] complete:nil];
        }else{
            _calStartDateText.text = @"-";
            _calEndDateText.text = @"-";
        }
        
        _backgroundHighlight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _viewUpper.height)];
        _backgroundHighlight.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        [self.view insertSubview:_backgroundHighlight atIndex:0];
        [self moveHighlightToSection:_viewUpper];
        
        [self userFriendsUpdated];
    }
    
}

-(void)moveHighlightToSection:(UIView *)theView{
    
    float finalY = 0;
    float finalHeight = 0;

    if(theView == _viewUpper){
        finalY = _viewUpper.y;
        finalHeight = _viewUpper.height;
    }else{
        
        if(theView == _viewHow){
            if(_firstTapDate && _secondTapDate && [_inputCity.text length] > 0){
                finalY = theView.y + _viewLower.y;
                finalHeight = theView.height;
                theView.userInteractionEnabled = YES;
            }else{
                return;
            }
        }
        
        finalY = theView.y + _viewLower.y;
        finalHeight = theView.height;
        
        if(theView.alpha == 1)
            return;
        
        theView.userInteractionEnabled = YES;
    }
    [_backgroundHighlight.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.88 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _backgroundHighlight.y = finalY;
        _backgroundHighlight.height = finalHeight;
        _backgroundHighlight.alpha = 1;
        theView.alpha = 1;
    } completion:^(BOOL finished) {
        if(theView == _viewGroups){
            [UIView animateWithDuration:0.5 delay:0.2 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
                _backgroundHighlight.alpha = 0;
                _viewSave.alpha = 1;
                _viewSave.userInteractionEnabled = YES;
            } completion:^(BOOL finished) {
            }];
        }
        
    }];
    
}





-(void)showCityView{
    _originalCityName = _inputCity.text;
    _cityView.width = _scrollView.width;
    _cityView.y = _viewUpper.y + _inputCity.maxY;
    _cityView.height = _scrollView.height - _cityView.y;
    [self.view addSubview:_cityView];
    _btnCancelCityView.hidden = NO;
    
}
-(void)hideCityView{
    _btnCancelCityView.hidden = YES;
    [_cityView removeFromSuperview];
    [[AppController sharedInstance] hideKeyboard];
}

-(void)processSearchResult:(NSDictionary *)dict overrideTicket:(BOOL)override{

    NSString *ticket = [NSString returnStringObjectForKey:@"ticket" withDictionary:dict];

    if(override || [ticket isEqualToString:[NSString stringWithFormat:@"%d",_lastTicket]]){
        [_items removeAllObjects];
        _items = [NSMutableArray arrayWithArray:[dict objectForKey:@"data"]];
        [_tableViewCity reloadData];
    }

}

-(void)updateCalendarCurrentMonthTitle:(NSString *)str{
    int offset = 14;
    _calendarMonthTitle.text = str;
    [_calendarMonthTitle sizeToFit];
    _calendarMonthTitle.height = 55;
    _calendarMonthTitle.x = _calendarViewWrapper.width/2 - _calendarMonthTitle.width/2;
    _arrowLeft.x = _calendarMonthTitle.x - _arrowLeft.width - offset;
    _arrowRight.x = _calendarMonthTitle.maxX + offset;

}

- (void)performStringGeocode:(NSString *)str{
    
    if(_searchManager){
        [_searchManager.operationQueue cancelAllOperations];
    }
    if([_previousResults objectForKey:str] != nil){
        [self processSearchResult:[_previousResults objectForKey:str] overrideTicket:YES];
    }else{
        NSDictionary *dict = @{@"query":str,@"ticket":[NSString stringWithFormat:@"%d",++_lastTicket]};
        _searchManager = [AFHTTPRequestOperationManager manager];
        _searchManager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [_searchManager POST:[AppAPIBuilder APIForSearchCity:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            responseObject = [VTUtils processResponse:responseObject];
            if([VTUtils isResponseSuccessful:responseObject]){
                NSString *term = [NSString returnStringObjectForKey:@"term" withDictionary:responseObject];
                [_previousResults setObject:responseObject forKey:term];
                [self processSearchResult:responseObject overrideTicket:NO];
            }else{
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
  
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.01);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
            [self performStringGeocode:textField.text];
            
            if(_btnCancelCityView.hidden){
                [self showCityView];
            }
            
        });

    return YES;
}


-(void)typeBtnTapped:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    if(btn.selected){
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor colorWithHexString:COLOR_CC_BLUE_BG] forState:UIControlStateNormal];
        btn.layer.borderWidth = 0;
    }else{
        btn.backgroundColor = [UIColor clearColor];
        [btn setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
        btn.layer.borderWidth = 1;
    }

    [self moveHighlightToSection:_viewGroups];
}

-(void)howBtnTapped:(UIButton *)btn{
    
    for(UIView *v in _viewHow.subviews){
        if([v isKindOfClass:[UIButton class]]){
            UIButton *b = (UIButton *) v;
            [b setTitleColor:[[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
        }
    }
    _howIdx = (int)btn.tag;
    [btn setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
    [self moveHighlightToSection:_viewType];
}

-(void)groupBtnTapped:(UIButton *)btn{
    
    
    if(btn.tag == -100){
        
        AppCustomGroupsViewController *vc = [[AppCustomGroupsViewController alloc] initWithNibName:@"AppCustomGroupsViewController" bundle:nil];
        vc.isManageView = YES;
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        return;
    }

    btn.selected = !btn.selected;
    
    if(btn.selected){
        [btn setTitleColor:[[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:1] forState:UIControlStateNormal];
    }else{
        [btn setTitleColor:[[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    }
    
    
}



#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView == _tableViewInviteFriends){
        if(_searchActive)
            return [_searchResultsFriendsToInvite count];
        else
            return [[AppController sharedInstance].currentUser.friends count];
    }
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _tableViewInviteFriends){

        return 55.0;
    }
    
    
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(tableView == _tableViewInviteFriends){
        
        AppPlansInviteTableViewCell *cell = (AppPlansInviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppPlansInviteTableViewCell];
        if (cell == nil) {
            cell = [[AppPlansInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppPlansInviteTableViewCell];
        }
        AppContact *c;
        if(_searchActive){
            c = [_searchResultsFriendsToInvite objectAtIndex:indexPath.row];
            NSInteger idx = [[AppController sharedInstance].currentUser.friends indexOfObject:c];
            NSIndexPath *tempPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [cell setupWithContact:c andSelected:[_multiCellSelected containsObject:tempPath]];
        }else{
            c = [[AppController sharedInstance].currentUser.friends objectAtIndex:indexPath.row];
            [cell setupWithContact:c andSelected:[_multiCellSelected containsObject:indexPath]];
        }
        cell.itemTextRight.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppStaticCellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppStaticCellName];
    }
    
    NSDictionary *dict = [_items objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:14];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == _tableViewInviteFriends){
        
        if(_searchActive){
            
            AppContact *c = [_searchResultsFriendsToInvite objectAtIndex:indexPath.row];
            NSInteger idx = [[AppController sharedInstance].currentUser.friends indexOfObject:c];
            NSIndexPath *tempPath = [NSIndexPath indexPathForRow:idx inSection:0];
            if ([_multiCellSelected containsObject:tempPath]){
                [_multiCellSelected removeObject:tempPath];
            }
            else{
                [_multiCellSelected addObject:tempPath];
            }
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
        }else{
            if ([_multiCellSelected containsObject:indexPath]){
                [_multiCellSelected removeObject:indexPath];
            }
            else{
                [_multiCellSelected addObject:indexPath];
            }
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }else{
        _placePicked = [_items objectAtIndex:indexPath.row];
        _inputCity.text = [NSString returnStringObjectForKey:@"title" withDictionary:_placePicked];
        _selectedWhereId = [NSString returnStringObjectForKey:@"id" withDictionary:_placePicked];
        [[AppController sharedInstance] hideKeyboard];
        [self hideCityView];
        [self moveHighlightToSection:_viewHow];
    }

}

- (IBAction)doInviteFriendsDone {

    if([_multiCellSelected count] > 0){

        [_btnInviteFriends setTitle:[NSString stringWithFormat: @"%d friend%@ invited",(int)[_multiCellSelected count],([_multiCellSelected count] == 1) ? @"" : @"s"] forState:UIControlStateNormal];
    }else{
        [_btnInviteFriends setTitle:@"Tap to invite friends" forState:UIControlStateNormal];
    }
    [[AppController sharedInstance] hideKeyboard];
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _inviteFriendsView.alpha = 0;
                         _inviteFriendsViewInner.y = 100;
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)doFindFriends{
    AppFindFriendViewController *vc = [[AppFindFriendViewController alloc] initWithNibName:@"AppFindFriendViewController" bundle:nil];
    vc.fromProfile = YES;
    vc.fromPlans = YES;
    
    NSString *planTypeText = @"Sure Plan";
    
    if(_editingPlan != nil){
        
        if(_editingPlan.planType == AppPlanTypeSure){
            planTypeText = @"Sure Plan";
        }else{
            planTypeText = @"If Plan";
        }
    }else{
        if(_planType == AppPlanTypeSure){
            planTypeText = @"Sure Plan";
        }else{
            planTypeText = @"If Plan";
        }
    }
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd"];
    
    vc.fromPlansString = [NSString stringWithFormat:@"Come join my %@ to %@: %@ to %@.",planTypeText,_inputCity.text,[dateFormat stringFromDate:_firstTapDate],[dateFormat stringFromDate:_secondTapDate]];

    
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

- (IBAction)doInviteFriendsView{
    
    [self.view addSubview:_inviteFriendsView];
    _inviteFriendsView.width = self.view.width;
    _inviteFriendsView.height = self.view.height;
    
    float newHeight = self.view.height - _inviteFriendsViewInner.y - 20;
    _inviteFriendsViewInner.height = newHeight;
    
    if(_inviteMoreFriendsBanner == nil){
        
        _inviteMoreFriendsBanner = [[UIView alloc] initWithFrame:CGRectMake(0, _searchBar.maxY, _inviteFriendsViewInner.width, 66)];
        _inviteMoreFriendsBanner.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG2] colorWithAlphaComponent:1];
        [_inviteFriendsViewInner addSubview:_inviteMoreFriendsBanner];
        _tableViewInviteFriends.y = _inviteMoreFriendsBanner.maxY;
        _tableViewInviteFriends.height = _inviteFriendsViewInner.height - _inviteMoreFriendsBanner.maxY;
        
        _inviteMoreFriendsText1 = [[UILabel alloc] init];
        _inviteMoreFriendsText1.textColor = [UIColor whiteColor];
        _inviteMoreFriendsText1.text = @"Not on CrissCross?";
        _inviteMoreFriendsText1.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:20];
        [_inviteMoreFriendsText1 sizeToFit];
        _inviteMoreFriendsText1.x = 10;
        _inviteMoreFriendsText1.y = 10;
        _inviteMoreFriendsText1.adjustsFontSizeToFitWidth = YES;
        _inviteMoreFriendsText1.width = _inviteMoreFriendsBanner.width - 40;
        
        _inviteMoreFriendsText2 = [[UILabel alloc] init];
        _inviteMoreFriendsText2.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
        _inviteMoreFriendsText2.text = @"Invite friends who aren't on Crisscross to your trip!";
        _inviteMoreFriendsText2.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:14];
        [_inviteMoreFriendsText2 sizeToFit];
        _inviteMoreFriendsText2.x = 10;
        _inviteMoreFriendsText2.adjustsFontSizeToFitWidth = YES;
        _inviteMoreFriendsText2.width = _inviteMoreFriendsBanner.width - 40;
        _inviteMoreFriendsText2.y = _inviteMoreFriendsText1.maxY;
        
        [_inviteMoreFriendsBanner addSubview:_inviteMoreFriendsText1];
        [_inviteMoreFriendsBanner addSubview:_inviteMoreFriendsText2];
        
        _inviteMoreFriendsBannerHitArea = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _inviteMoreFriendsBanner.width, _inviteMoreFriendsBanner.height)];
        [_inviteMoreFriendsBannerHitArea addTarget:self action:@selector(doFindFriends) forControlEvents:UIControlEventTouchUpInside];
        [_inviteMoreFriendsBanner addSubview:_inviteMoreFriendsBannerHitArea];
        
    }

    _inviteFriendsView.alpha = 0;
    _inviteFriendsViewInner.alpha = 0;
    _inviteFriendsViewInner.y = 200;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _inviteFriendsView.alpha = 1;
                         _inviteFriendsViewInner.alpha = 1;
                         _inviteFriendsViewInner.y = 68;
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

-(void)doUpdateInviteBannerForMore{
    if(_inviteMoreFriendsBanner != nil){
        
        _inviteMoreFriendsText1.text = @"Invites sent. Forget anyone?";
        [_inviteMoreFriendsText1 sizeToFit];
        _inviteMoreFriendsText1.width = _inviteMoreFriendsBanner.width - 40;
        _inviteMoreFriendsText2.text = @"Invite friends who aren't on Crisscross to your trip!";
        [_inviteMoreFriendsText2 sizeToFit];
        _inviteMoreFriendsText2.width = _inviteMoreFriendsBanner.width - 40;
    }
}




- (IBAction)doCancelCity {
    _inputCity.text = _originalCityName;
    if(_selectedWhereId == nil){
            _inputCity.text = @"";
    }
    [self hideCityView];
}

- (IBAction)doShowPickDateStart {
    
    
    [_inputCity resignFirstResponder];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM yyyy"];
    
    if(_firstTapDate){
        [_calendarView scrollToMonth:_firstTapDate complete:^{
            _calDoingUpdate = NO;
        }];
        [self updateCalendarCurrentMonthTitle:[dateFormat stringFromDate:_firstTapDate]];

    }else{
        NSDate *today = [NSDate new];
        [_calendarView scrollToMonth:today complete:^{
            _calDoingUpdate = NO;
        }];
        [self updateCalendarCurrentMonthTitle:[dateFormat stringFromDate:today]];
    }
    
    
    [self.view addSubview:_calendarViewHolder];
    _calendarViewHolder.width = self.view.width;
    _calendarViewHolder.height = self.view.height;
    _calendarViewHolder.alpha = 0;
    _calendarViewHolder.y = 0;
    _calendarViewHolder.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                        _calendarViewHolder.alpha = 1;
                        _calendarViewHolder.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         
                     }];

    
}

- (void)doCalContinue {
   
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    
    if(_firstTapDate)
        [_btnDateStart setTitle:[dateFormat stringFromDate:_firstTapDate] forState:UIControlStateNormal];
    else{
        
    }
    
    if(_secondTapDate)
        [_btnDateEnd setTitle:[dateFormat stringFromDate:_secondTapDate] forState:UIControlStateNormal];
    else{
        
    }
    
    
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _calendarViewHolder.alpha = 0;
                     } completion:^(BOOL finished) {
                          [_calendarViewHolder removeFromSuperview];
                         [self moveHighlightToSection:_viewHow];
                     }];

    
}

- (IBAction)doSave {
    
    
    
    if(_selectedWhereId == nil || _placePicked == nil){
        [[AppController sharedInstance] showAlertWithTitle:@"Destination Missing" andMessage:@"Please enter a destination"];
        return;
    }
    
    if(_firstTapDate == nil || _secondTapDate == nil){
        [[AppController sharedInstance] showAlertWithTitle:@"Date Missing" andMessage:@"Please enter the proper date"];
        return;
    }
    

    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Saving" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:[NSNumber numberWithInt:_planType] forKey:@"plan_type"];
    [dict setObject:_selectedWhereId forKey:@"where_id"];
    [dict setObject:_placePicked forKey:@"where_place"];
    if(_isEditing){
        [dict setObject:_editingPlan.planId forKey:@"existing_id"];
        [dict setObject:(_planTypeSegment.selectedSegmentIndex == 0) ? @0 : @1 forKey:@"plan_type"];
    }else{
        [dict setObject:[NSNumber numberWithInt:_planType] forKey:@"plan_type"];
    }
    
    
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *ymd = [dateFormat stringFromDate:_firstTapDate];
    NSArray *parts = [ymd componentsSeparatedByString:@"-"];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:0];
    [comps setDay:[[parts objectAtIndex:2] intValue]];
    [comps setMonth:[[parts objectAtIndex:1] intValue]];
    [comps setYear:[[parts objectAtIndex:0] intValue]];
    [comps setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    NSDate *dateInGMT = [[NSCalendar currentCalendar] dateFromComponents:comps];
    float startSeconds = roundf([dateInGMT timeIntervalSince1970]);
    
    
    ymd = [dateFormat stringFromDate:_secondTapDate];
    parts = [ymd componentsSeparatedByString:@"-"];
    
    comps = [[NSDateComponents alloc] init];
    [comps setHour:0];
    [comps setDay:[[parts objectAtIndex:2] intValue]];
    [comps setMonth:[[parts objectAtIndex:1] intValue]];
    [comps setYear:[[parts objectAtIndex:0] intValue]];
    [comps setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    
    
    dateInGMT = [[NSCalendar currentCalendar] dateFromComponents:comps];
    float endSeconds = roundf([dateInGMT timeIntervalSince1970]);
    

    [dict setObject:[NSString stringWithFormat:@"%.f",startSeconds] forKey:@"when_start"];
    [dict setObject:[NSString stringWithFormat:@"%.f",endSeconds] forKey:@"when_end"];
    [dict setObject:[NSNumber numberWithInt:_howIdx] forKey:@"how_id"];
    
    
    NSMutableArray *typesIds = [[NSMutableArray alloc] init];
    for(UIView *v in _viewType.subviews){
        if([v isKindOfClass:[UIButton class]]){
            UIButton *b = (UIButton *)v;
            if(b.selected){
                [typesIds addObject:[NSString stringWithFormat:@"%d",(int)b.tag]];
            }
        }
    }
    
    [dict setObject:typesIds forKey:@"type_ids"];
    
    NSMutableArray *groupIds = [[NSMutableArray alloc] init];
    for(UIButton *b in _scrollViewGroups.subviews){
        if(b.selected){
            AppGroup *g = [_sharingGroups objectAtIndex:b.tag];
            [groupIds addObject:[NSString stringWithFormat:@"%@",g.groupId]];
        }
    }
    
    [dict setObject:groupIds forKey:@"groups_id"];
    NSMutableArray *contactsIds = [[NSMutableArray alloc] init];
    
    for(NSIndexPath *ip in _multiCellSelected){
        
        AppContact *c = [[AppController sharedInstance].currentUser.friends objectAtIndex:ip.row];
        if(c.userId != nil)
            [contactsIds addObject:c.userId];
    }
    [dict setObject:contactsIds forKey:@"contacts_ids"];
    

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForSavingPlans:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [[AppController sharedInstance].currentUser setupPlansWithDictionary:responseObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLANS_UPDATED object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_loadingScreen removeFromSuperview];
                [[AppController sharedInstance] goBack];
            });
        }else{
            [_loadingScreen removeFromSuperview];
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
    
}



- (void)keyboardWillShow:(NSNotification*)aNotification{
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    
    if([_searchBar isFirstResponder]){
        
        float newHeight = self.view.height - kbSize.height - _inviteFriendsViewInner.y;
        [UIView animateWithDuration: 0.15
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             _inviteFriendsViewInner.height = newHeight;
                             _tableViewCity.height = newHeight;
                         }
                         completion:^(BOOL finished){}];
        
    }else{
    
        float newHeight = self.view.height - kbSize.height - _cityView.y;
        [_scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        _scrollView.scrollEnabled = NO;
        
        
        [UIView animateWithDuration: 0.15
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             _cityView.height = newHeight;
                         }
                         completion:^(BOOL finished){}];
    }
    
    
}

- (void)keyboardWillHide:(NSNotification*)aNotification{

    if([_searchBar isFirstResponder]){
        
        float newHeight = self.view.height - _inviteFriendsViewInner.y - 68;
        [UIView animateWithDuration: 0.15
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             _inviteFriendsViewInner.height = newHeight;
                         }
                         completion:^(BOOL finished){}];
        
    }
}



#pragma search

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    

    _searchActive = YES;
    if([searchText isEmpty]){
        _searchActive = NO;
        [_tableViewInviteFriends reloadData];
    }else{
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"( (name BEGINSWITH[cd] %@) OR (name CONTAINS[cd] %@) OR (lastName BEGINSWITH[cd] %@) OR (firstName BEGINSWITH[cd] %@))", searchText,[NSString stringWithFormat:@" %@",searchText],searchText,searchText];
        _searchResultsFriendsToInvite = [NSMutableArray arrayWithArray:[[AppController sharedInstance].currentUser.friends filteredArrayUsingPredicate:p]];
        [_tableViewInviteFriends reloadData];
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [[AppController sharedInstance] hideKeyboard];
    _searchBar.text = @"";
    _searchActive = NO;
    float newHeight = self.view.height - _inviteFriendsViewInner.y - 68;
    [UIView animateWithDuration: 0.15
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _inviteFriendsViewInner.height = newHeight;
                     }
                     completion:^(BOOL finished){}];

    [_tableViewInviteFriends reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
}








#pragma mark Cal

-(void) didScrollToMonth:(NSDate *)month firstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate{
    
    if(_calEvent){
        _calDoingUpdate = YES;
        _calDoingUpdateLong = YES;
        [_calendarView setEvents:@[_calEvent] complete:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _calDoingUpdateLong = NO;
            _calDoingUpdate = YES;
            [_calendarView setEvents:@[_calEvent] complete:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _calDoingUpdate = NO;
            });
            
        });
    }
}

-(void) didSkipToMonth:(NSDate *)month firstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM yyyy"];
    [self updateCalendarCurrentMonthTitle:[dateFormat stringFromDate:month]];
}
- (BOOL) shouldHighlightItemWithDate:(NSDate *)date{
    return YES;
}
- (BOOL) shouldSelectItemWithDate:(NSDate *)date{
    return YES;
}

- (void) didSelectItemWithDate:(NSDate *)date{
    
    
    
    
    if(_calDoingUpdate){
        _calDoingUpdate = NO;
        return;
    }
    if(_calDoingUpdateLong){
        return;
    }
    
    NSDate *theDate = [[NSDate alloc] init];
    
    int diff = [date timeIntervalSince1970] - [theDate timeIntervalSince1970];
    if(diff < -(86400)){
        [[AppController sharedInstance] showAlertWithTitle:@"Past Date" andMessage:@"Please pick a date in the future"];
        return;
    }
    
    
    if(_firstTapDate && _secondTapDate){
        _firstTapDate = nil;
        _secondTapDate = nil;
    }
    
    if(!_firstTapDate){
        
        _firstTapDate = date;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd"];
        _calStartDateText.text = [dateFormat stringFromDate:date];
        _calDoingUpdate = YES;
        _calEvent = [[DPCalendarEvent alloc] initWithTitle:@"title" startTime:_firstTapDate endTime:_firstTapDate colorIndex:0];
        _calEvent.doFillWithColor = YES;
        _calEvent.fillWithColor = @"#ADF0FB";
        _calEvent.fillWithColorOn = @"#50DDF7";
        
        [_calendarView setEvents:@[_calEvent] complete:nil];
    }else{
        _secondTapDate = date;
        
        if([_secondTapDate timeIntervalSince1970] < [_firstTapDate timeIntervalSince1970]){
            _firstTapDate = nil;
            _secondTapDate = nil;
            [self didSelectItemWithDate:date];
            return;
        }
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd"];
        _calEndDateText.text = [dateFormat stringFromDate:date];
        _calDoingUpdate = YES;
        _calEvent = [[DPCalendarEvent alloc] initWithTitle:@"title" startTime:_firstTapDate endTime:_secondTapDate colorIndex:0];
        _calEvent.doFillWithColor = YES;
        _calEvent.fillWithColor = @"#ADF0FB";
        _calEvent.fillWithColorOn = @"#50DDF7";
        [_calendarView setEvents:@[_calEvent] complete:nil];
    }
    
}



- (void)didTapEvent:(DPCalendarEvent *)event onDate:(NSDate *)date{
}




-(NSDictionary *)monthlyViewAttributes {
    return @{
             
             DPCalendarMonthlyViewAttributeCellNotInSameMonthSelectable: @YES,
             DPCalendarMonthlyViewAttributeCellHeight:@40.f,
             DPCalendarMonthlyViewAttributeEventDrawingStyle: [NSNumber numberWithInt:DPCalendarMonthlyViewEventDrawingStyleBar],
             DPCalendarMonthlyViewAttributeEventColors:@[[UIColor colorWithHexString:COLOR_CC_GREEN],[UIColor colorWithHexString:COLOR_CC_TEAL],[UIColor colorWithHexString:COLOR_CC_BLUE_BG2]],
             DPCalendarMonthlyViewAttributeSeparatorColor:[UIColor clearColor],
             DPCalendarMonthlyViewAttributeIconEventMarginX:@0,
             DPCalendarMonthlyViewAttributeIconEventMarginY:@0,
             DPCalendarMonthlyViewAttributeWeekdayFont:[UIFont fontWithName:FONT_HELVETICA_NEUE size:10],
             DPCalendarMonthlyViewAttributeEventFont:[UIFont fontWithName:FONT_HELVETICA_NEUE size:6],
             
             

             };
    
}







@end
