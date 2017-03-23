//
//  AppPlansViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppPlansViewController.h"
#import "AppPlanAddViewController.h"
#import "AppPlansTableViewCell.h"
#import "MGSwipeButton.h"
#import "AppPlansInviteTableViewCell.h"

#define kAppPlansInviteTableViewCell @"AppPlansInviteTableViewCell"
#define kAppPlansTableViewCell @"AppPlansTableViewCell"

@interface AppPlansViewController ()

@end

@implementation AppPlansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _items = [[NSMutableArray alloc] init];
    _usersThere = [[NSMutableArray alloc] init];
    _events = [[NSMutableArray alloc] init];
    _multiCellSelected = [[NSMutableArray alloc] init];
    [_tableView registerNib:[UINib nibWithNibName:kAppPlansTableViewCell bundle:nil] forCellReuseIdentifier:kAppPlansTableViewCell];
    [_tableThere registerNib:[UINib nibWithNibName:kAppPlansInviteTableViewCell bundle:nil] forCellReuseIdentifier:kAppPlansInviteTableViewCell];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:NOTIFICATION_PLANS_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConflict:) name:NOTIFICATION_PLAN_CONFLICT_ITEM object:nil];
    
    _conflictLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, 30, 30)];
    _conflictLabel.text = @"8";
    _conflictLabel.font = [UIFont fontWithName:FONT_ICONS size:22];
    _conflictLabel.textColor = [UIColor redColor];
    [_conflictLabel sizeToFit];
    
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading Plans" andColor:nil withDelay:0];
    _conflictLabelByline = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    _conflictLabelByline.text = @"DATE CONFLICT\nBELOW";
    _conflictLabelByline.textAlignment = NSTextAlignmentCenter;
    _conflictLabelByline.numberOfLines = 2;
    _conflictLabelByline.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:8];
    _conflictLabelByline.textColor = [UIColor redColor];
    [_conflictLabelByline sizeToFit];
    _conflictLabelByline.x = _conflictLabel.maxX;
    _conflictLabelByline.y = 35;
    
    
    self.view.clipsToBounds = YES;

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateEventsOnCalendar];
    [self checkIfWeHaveConflicts];
}

-(void)layoutUI{
    
    if(!_didLayout){
        _didLayout = YES;
        _topView.alpha = 0;
        _bottomView.alpha = 0;
        if(_planType == AppPlanTypeSure){
            _topnav.theTitle.text = @"Sure Plans";
            
        }else if(_planType == AppPlanTypeIf){
            _topnav.theTitle.text = @"If Plans";
            
        }
        
        if([_mainContactId isEqualToString:[AppController sharedInstance].currentUser.userId]){
            _isOwner = YES;
        }
        
        _act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_act startAnimating];
        _act.y = _topView.y + roundf(_topView.height/2 - _act.height/2);
        _act.x = roundf(_topView.width/2 - _act.width/2);
        [self.view addSubview:_act];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            _calendarView = [[DPCalendarMonthlyView alloc] initWithFrame:CGRectMake(0, 40, _topView.width, _topView.height-20) delegate:self];
            _calendarView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            _calendarView.showsHorizontalScrollIndicator = NO;
            _calendarView.clipsToBounds = YES;
            _calendarView.contentInset = UIEdgeInsetsZero;
            _calendarView.scrollEnabled = NO;
            _calendarView.pagingEnabled = YES;
            _calendarView.alpha = 0;
            [_topView insertSubview:_calendarView atIndex:0];
            
            NSDate *today = [NSDate new];
            [_calendarView scrollToMonth:today complete:^{}];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MMM yyyy"];
            _calendarMonthTitle.text = [dateFormat stringFromDate:today];
            
            if(_isOwner)
                [self.view addSubview:_btnPlus];
            else
                _btnPlus.hidden = YES;
            
            _topView.layer.shadowColor = [UIColor colorWithHexString:@"CCCCCC"].CGColor;
            _topView.layer.shadowOffset = CGSizeMake(0,0);
            _topView.layer.shadowOpacity = 1;
            _topView.layer.shadowRadius = 12;
            
            
            _viewTableThereInner.layer.shadowColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG].CGColor;
            _viewTableThereInner.layer.shadowOffset = CGSizeMake(0,0);
            _viewTableThereInner.layer.shadowOpacity = 1;
            _viewTableThereInner.layer.shadowRadius = 12;
            _viewTableThereInner.layer.cornerRadius = 20;
            _bottomView.height = self.view.height - _topView.maxY;
            [self fetchData];
            [self adjustBottomViewAnimated:NO];
            
            _hintView = [AppNotificationViewController buildHintViewWithText:@"Add your travel plans & share with friends to see if you will CrissCross!" andOffset:60];
            _hintView.hidden = YES;
            
            [UIView animateWithDuration:0.4 animations:^{
                _calendarView.alpha = 1;
                _topView.alpha = 1;
                _bottomView.alpha = 1;
                _act.alpha = 0;
            } completion:^(BOOL finished) {
                
            }];

        });
        

    }
}

-(void)checkToShowHint{
    if(!_isOwner){
        _hintView.hidden = YES;
        return;
    }
    if([_items count] == 0){
        [self.view addSubview:_hintView];
        _hintView.hidden = NO;
    }else{
        _hintView.hidden = YES;
    }
    
}

-(void)fetchData{
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _loadingScreen.alpha = 1;
        [self.view addSubview:_loadingScreen];
    });
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:@"all" forKey:@"plan_type"];
    [dict setObject:_mainContactId forKey:@"user_id"];
    [dict setObject:@"Y" forKey:@"with_cross"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetPlans:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _loadingScreen.hidden = YES;
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        
        if([VTUtils isResponseSuccessful:responseObject]){
            [_items removeAllObjects];
            

                if(_isOwner){
                    [[AppController sharedInstance].currentUser setupPlansWithDictionary:responseObject];
                    
                    _tempUser = [AppController sharedInstance].currentUser;
                }else{
                    _tempUser = [[AppUser alloc] initWithDictionary:nil];
                    [_tempUser setupPlansWithDictionary:responseObject];
                }
            
            if(_planType == AppPlanTypeSure){
                _items = _tempUser.surePlans;
            }else if(_planType == AppPlanTypeIf){
                _items = _tempUser.ifPlans;
            }
            
            [_tableView reloadData];
            [self updateEventsOnCalendar];
            
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _loadingScreen.hidden = YES;
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
    
}

-(void)updateEventsOnCalendar{
    [_events removeAllObjects];
    int count = 0;
    

    [self checkIfWeHaveConflicts];
    [_tableView reloadData];
    
    for(AppPlan *p in _items){
        p.markAsConflict = NO;
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:p.startDateInterval];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:p.endDateInterval];
        DPCalendarEvent *event = [[DPCalendarEvent alloc] initWithTitle:@"title" startTime:startDate endTime:endDate colorIndex:count++];
        event.specialId = p.planId;
        [_events addObject:event];
    }
    [_calendarView setEvents:_events complete:nil];
    [self checkToShowHint];
}

-(void)checkIfWeHaveConflicts{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSPredicate *p = [NSPredicate predicateWithFormat:@"markAsConflict == YES"];
        NSArray *plans = [_items filteredArrayUsingPredicate:p];

        _haveConflicts = [plans count] > 0;
        _haveConflicts = NO;
        if(_haveConflicts){
            _topnav.btnBack.hidden = YES;
            [self.view addSubview:_conflictLabel];
            [self.view addSubview:_conflictLabelByline];
            self.canLeaveWithSwipe = NO;
        }else{
            [_conflictLabel removeFromSuperview];
            [_conflictLabelByline removeFromSuperview];
            _topnav.btnBack.hidden = NO;
            self.canLeaveWithSwipe = YES;
        }
        [_tableView reloadData];
    });
}


-(void)updateConflict:(NSNotification *)note{
    
    DPCalendarEvent *e = (note.object);
    NSPredicate *p = [NSPredicate predicateWithFormat:@"planId MATCHES %@",e.specialId];
    NSArray *plans = [_items filteredArrayUsingPredicate:p];
    if([plans count] > 0){
        AppPlan *p = [plans firstObject];
        p.markAsConflict = YES;
        [_tableView reloadData];
    }
    
    [self checkIfWeHaveConflicts];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkIfWeHaveConflicts];
    });
}



-(void)adjustBottomViewAnimated:(BOOL)animate{
    _bottomView.y = _topView.maxY;
    _bottomView.height = self.view.height - _bottomView.y;
    
}

- (IBAction)doMonthForward {
    [_calendarView scrollToNextMonthWithComplete:^{
        
    }];
    
}


- (IBAction)doMonthBack {
    [_calendarView scrollToPreviousMonthWithComplete:^{
        
    }];

}

- (IBAction)doCloseFriendView {
    [UIView animateWithDuration:0.3 animations:^{
        _viewThere.alpha = 0;
    }];
}

- (void)showFriendView {
    
    _viewThere.width = self.view.width;
    _viewThere.height = self.view.height;
    [self.view addSubview:_viewThere];
    _viewThere.alpha = 0;
    _viewThere.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.85];
    
    _viewTableThereInner.alpha = 0;
    if([_usersThere count] > 3){
        _viewTableThereInner.height = roundf(_viewThere.height * 0.50);
    }else{
        _viewTableThereInner.height = roundf([_usersThere count] * 45);
    }
    
    _viewTableThereInner.width = roundf(_viewThere.width - 50);
    _viewTableThereInner.x = roundf(_viewThere.width/2 - _viewTableThereInner.width/2);
    _viewTableThereInner.y = roundf(_viewThere.height/2 - _viewTableThereInner.height/2);
    _btnClose.alpha = 0;
    _btnClose.x = roundf(_viewThere.width/2 - _btnClose.width/2);
    _btnClose.y = roundf(_viewTableThereInner.y - _btnClose.height - 10);
    _viewTableThereInner.y += 100;
    [UIView animateWithDuration:0.2 animations:^{
        _viewThere.alpha = 1;
    }];
    
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _viewTableThereInner.alpha = 1;
        _viewTableThereInner.y -= 100;
        _btnClose.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}



-(void) didScrollToMonth:(NSDate *)month firstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate{
}


-(void) didSkipToMonth:(NSDate *)month firstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM yyyy"];
    _calendarMonthTitle.text = [dateFormat stringFromDate:month];
}

- (BOOL) shouldHighlightItemWithDate:(NSDate *)date{
    return YES;
}



- (BOOL) shouldSelectItemWithDate:(NSDate *)date{
    return YES;
}



- (void) didSelectItemWithDate:(NSDate *)date{


    
    if(_firstTapDate == date){
        double diff = [[NSDate date] timeIntervalSince1970] - _firstTap;
        if(!_isOwner)
            return;
        
        if(diff < 0.4){
            AppPlanAddViewController *vc = [[AppPlanAddViewController alloc] initWithNibName:@"AppPlanAddViewController" bundle:nil];
            vc.planType = _planType;
            vc.startingDate = date;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
        _firstTap = [[NSDate date] timeIntervalSince1970];
    }else{
        _firstTapDate = date;
        _firstTap = [[NSDate date] timeIntervalSince1970];
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


#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _tableThere)
        return [_usersThere count];
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _tableThere)
        return 45.0;
    return 65.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(tableView == _tableThere){
        
        AppPlansInviteTableViewCell *cell = (AppPlansInviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppPlansInviteTableViewCell];
        if (cell == nil) {
            cell = [[AppPlansInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppPlansInviteTableViewCell];
        }
        
        AppContact *c = [_usersThere objectAtIndex:indexPath.row];
        [cell setupWithContact:c andSelected:[_multiCellSelected containsObject:indexPath]];
        cell.itemTextRight.hidden = YES;
        [cell showMinimal];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
        
    AppPlansTableViewCell *cell = (AppPlansTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppPlansTableViewCell];
    if (cell == nil) {
        cell = [[AppPlansTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppPlansTableViewCell];
    }
    
    AppPlan *p = [_items objectAtIndex:indexPath.row];
    [cell setupWithPlan:p andSelected:[_multiCellSelected containsObject:indexPath] isOwner:_isOwner];
     cell.rightButtons = @[];
    
    if(_isOwner){
        
        if(!p.markAsConflict)
            cell.swipeText.hidden = NO;
        
        if([p.overlappedUsers count] > 0){
            cell.rightButtons = @[
                                  [MGSwipeButton buttonWithTitle:@"REMOVE" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:65],
                                  [MGSwipeButton buttonWithTitle:@"EDIT" andIcon:@"z" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:65],
                                  [MGSwipeButton buttonWithTitle:@"VIEW\nPEOPLE" andIcon:@"o" backgroundColor:[UIColor colorWithHexString:COLOR_CC_TEAL] withHeight:65]
                                  ];
        }else{
            
            cell.rightButtons = @[
                                  [MGSwipeButton buttonWithTitle:@"REMOVE" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:65],
                                  [MGSwipeButton buttonWithTitle:@"EDIT" andIcon:@"z" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:65]
                                  
                                  ];
        }
        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    }else{
        
        if([p.overlappedUsers count] > 0){
            cell.swipeText.hidden = NO;
            cell.rightButtons = @[
                                  [MGSwipeButton buttonWithTitle:@"VIEW\nPEOPLE" andIcon:@"o" backgroundColor:[UIColor colorWithHexString:COLOR_CC_TEAL] withHeight:65]
                                  ];

            
        }else{
            cell.swipeText.hidden = YES;
            cell.rightButtons = @[];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _tableThere){

        AppContact *c = [_usersThere objectAtIndex:indexPath.row];
        [[AppController sharedInstance] routeToUserProfile:c.userId];
    }else{
        
        if ([_multiCellSelected containsObject:indexPath]){
            [_multiCellSelected removeObject:indexPath];
        }
        else{
            [_multiCellSelected addObject:indexPath];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    int idx = (int)index;
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    AppPlan *p = [_items objectAtIndex:path.row];
    
    if(!_isOwner && [p.overlappedUsers count] > 0){

        _usersThere = p.overlappedUsers;
        [_tableThere reloadData];
        [self showFriendView];
        return YES;
    }
    
    if (direction == MGSwipeDirectionRightToLeft && idx == 0) {

        [[[AppController sharedInstance].currentUser allPlans] removeObject:p];
        [self deletePlan:p];
        [_items removeObjectAtIndex:path.row];
        [_tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self updateEventsOnCalendar];
        [self updateAllListeners];
        return NO;
    }else if(idx == 2){

        _usersThere = p.overlappedUsers;
        [_tableThere reloadData];
        [self showFriendView];
    }else{
        AppPlanAddViewController *vc = [[AppPlanAddViewController alloc] initWithNibName:@"AppPlanAddViewController" bundle:nil];
        vc.editingPlan = p;
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    }
    return YES;
}


-(void)deletePlan:(AppPlan *)plan{
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:@"Y" forKey:@"delete"];
    [dict setObject:plan.planId forKey:@"plan_id"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForSavingPlans:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];

}


-(void)updateAllListeners{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLANS_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLANS_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:NOTIFICATION_PLANS_UPDATED object:nil];
}


- (IBAction)doAdd {
    AppPlanAddViewController *vc = [[AppPlanAddViewController alloc] initWithNibName:@"AppPlanAddViewController" bundle:nil];
    vc.planType = _planType;
    if(_firstTapDate != nil)
        vc.startingDate = _firstTapDate;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}
















@end
