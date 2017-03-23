//
//  AppActivityViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppActivityViewController.h"
#import "AppActivityTableViewCell.h"
#import "MGSwipeButton.h"
#import "AppBeenThereDetailViewController.h"
#import "AppFindFriendViewController.h"
#import "AppCustomGroupsViewController.h"

#define kAppActivityTableViewCell @"AppActivityTableViewCell"

@interface AppActivityViewController ()

@end

@implementation AppActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _page = 0;
    _buttons = [[NSMutableArray alloc] init];
    _items = [[NSMutableArray alloc] init];
    _trackerItems = [[NSMutableArray alloc] init];
    _trackerItemsForFilter = [[NSMutableArray alloc] init];
    _sections = @[
                  @{@"title":@"My Updates"},
                  @{@"title":@"Travel Tracker"}
                  ];
    
    _sortBySections = @[
                  @{@"title":@"All"},
                  @{@"title":@"Upcoming Trips"},
                  ];

    [_tableViewTracker registerNib:[UINib nibWithNibName:kAppActivityTableViewCell bundle:nil] forCellReuseIdentifier:kAppActivityTableViewCell];
    [_tableViewActivity registerNib:[UINib nibWithNibName:kAppActivityTableViewCell bundle:nil] forCellReuseIdentifier:kAppActivityTableViewCell];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchDataFromPush) name:NOTIFICATION_REFRESH_ACTIVITY object:nil];
    _noResultsUpdates.hidden = _noResultsTracker.hidden = YES;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.backgroundColor = [UIColor clearColor];
    _refreshControl.tintColor = [UIColor grayColor];
    [_refreshControl addTarget:self action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    [_tableViewActivity addSubview:_refreshControl];
    
   
    
    
    [self fetchData];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}
-(void)layoutUI{
    
    if(!_didLayout){
        _didLayout = YES;
        _topnav.theTitle.text = @"Activity";
        
        _bubbleNewActs = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _bubbleNewActs.text = @"2";
        _bubbleNewActs.textColor = [UIColor whiteColor];
        _bubbleNewActs.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:10];
        _bubbleNewActs.textAlignment = NSTextAlignmentCenter;
        _bubbleNewActs.layer.cornerRadius = _bubbleNewActs.width/2;
        _bubbleNewActs.clipsToBounds = YES;
        _bubbleNewActs.userInteractionEnabled = NO;
        _bubbleNewActs.adjustsFontSizeToFitWidth = YES;
        _bubbleNewActs.hidden = YES;
        
        _bubbleNewTracks = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _bubbleNewTracks.text = @"2";
        _bubbleNewTracks.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:10];
        _bubbleNewTracks.textAlignment = NSTextAlignmentCenter;
        _bubbleNewTracks.textColor = [UIColor whiteColor];
        _bubbleNewTracks.layer.cornerRadius = _bubbleNewTracks.width/2;
        _bubbleNewTracks.clipsToBounds = YES;
        _bubbleNewTracks.userInteractionEnabled = NO;
        _bubbleNewTracks.adjustsFontSizeToFitWidth = YES;
        _bubbleNewTracks.hidden = YES;
        
        
        int count = 0;
        int startingX = 0;
        for(NSDictionary *dict in _sections){
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, _topView.width/[_sections count]+1, _topView.height)];
            b.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:14];
            [b setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
            b.tag = count;
            b.backgroundColor = self.view.backgroundColor;
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
            [b addTarget:self action:@selector(sectionTapped:) forControlEvents:UIControlEventTouchUpInside];
            startingX += b.maxX;
            [_topView addSubview:b];
            if(count++ == 0){
                _bubbleNewActs.x = b.width - _bubbleNewActs.width - 10;
                _bubbleNewActs.y = b.height/2 - _bubbleNewActs.height/2;
                [b addSubview:_bubbleNewActs];
                [self sectionTapped:b];
            }else{
                _bubbleNewTracks.x = b.width - _bubbleNewTracks.width - 10;
                _bubbleNewTracks.y = b.height/2 - _bubbleNewTracks.height/2;
                [b addSubview:_bubbleNewTracks];
            }
            [_buttons addObject:b];
        }
        
        
        _bottomView.y = _topView.maxY;
        _bottomView.height = self.view.height - _bottomView.y;
        
        _sortByHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        _sortByHolder.backgroundColor = [UIColor whiteColor];
        _simpleLoadingScreen.frame = _bottomView.frame;

        
        UILabel *sortBy = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, _sortByHolder.height)];
        sortBy.text = @"Sort by";
        sortBy.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
        sortBy.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:13];
        [sortBy sizeToFit];
        sortBy.height = _sortByHolder.height;
        sortBy.x = 15;
        [_sortByHolder addSubview:sortBy];
        
       
        startingX = sortBy.maxX + 8;
        int buttonWidth = (_sortByHolder.width - startingX)/([_sortBySections count] + 1);
        count = 0;
        for(NSDictionary *d in _sortBySections){
            
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, buttonWidth, _sortByHolder.height)];
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_BLUE_BG] forState:UIControlStateSelected];
            [b addTarget:self action:@selector(filterSelected:) forControlEvents:UIControlEventTouchUpInside];
            b.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:13];
            b.titleLabel.adjustsFontSizeToFitWidth = YES;
            b.tag = count;
            [b setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:d] forState:UIControlStateNormal];
            [b sizeToFit];
            b.height = _sortByHolder.height;
            b.width += 20;
            [_sortByHolder addSubview:b];
            startingX += b.width;
            
            if(count == 0)
                b.selected = YES;
            
            
            
            count++;
        }
        
        [_viewTrackerHolder addSubview:_sortByHolder];
        _viewTrackerHolder.clipsToBounds = YES;

        [_tableViewTracker setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
        [_tableViewActivity setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
        
        _sortByHolder.layer.shadowColor = [UIColor colorWithHexString:@"#CCCCCC"].CGColor;
        _sortByHolder.layer.shadowOffset = CGSizeMake(0,0);
        _sortByHolder.layer.shadowOpacity = 1;
        _sortByHolder.layer.shadowRadius = 12;
        
        _btnAddFriends = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _btnAddFriends.layer.borderColor = [UIColor colorWithHexString:COLOR_CC_TEAL].CGColor;
        _btnAddFriends.titleLabel.numberOfLines = 2;
        _btnAddFriends.layer.borderWidth = 1;
        _btnAddFriends.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:roundf(self.view.width * 0.055)];
        _btnAddFriends.titleLabel.textAlignment = NSTextAlignmentCenter;
        _btnAddFriends.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _btnAddFriends.layer.cornerRadius = 8;
        [_btnAddFriends setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
        [_btnAddFriends setTitle:@"Add friends to see what\ntheir next plan is!" forState:UIControlStateNormal];
        [_btnAddFriends addTarget:self action:@selector(doAddFriends) forControlEvents:UIControlEventTouchDown];
        [_btnAddFriends sizeToFit];
        _btnAddFriends.width = roundf(_tableViewActivity.width * 0.80);
        _btnAddFriends.height += 15;
        _btnAddFriends.x = _tableViewActivity.width/2 - _btnAddFriends.width/2;
        _btnAddFriends.hidden = YES;
        [_tableViewActivity addSubview:_btnAddFriends];
        
        _finishedLayout = YES;
    }
    
    
}

-(void)doAddFriends{
    AppFindFriendViewController *vc = [[AppFindFriendViewController alloc] initWithNibName:@"AppFindFriendViewController" bundle:nil];
    vc.fromProfile = YES;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    
}

-(void)fetchDataFromPush{
    UIButton *b = [_buttons firstObject];
    [self sectionTapped:b];
    [self fetchData];
}

-(void)filterSelected:(UIButton *)btn{
    for(UIView *v in _sortByHolder.subviews){
        if([v isKindOfClass:[UIButton class]]){
            UIButton *b = (UIButton *)v;
            b.selected = NO;
        }
    }
    
    [_trackerItemsForFilter removeAllObjects];
    int idx = (int)btn.tag;
    switch (idx) {
        case 0:
        {
            _trackerItemsForFilter = [NSMutableArray arrayWithArray:_trackerItems];
            [_tableViewTracker reloadData];
            [_tableViewTracker setContentOffset:CGPointMake(0, 0) animated:YES];
        }
            break;
        case 1:
        
        case 2:
        {
            NSTimeInterval d = [[NSDate date] timeIntervalSince1970];
            NSPredicate *p = [NSPredicate predicateWithFormat:@"startU >= %f",d];
            _trackerItemsForFilter = [NSMutableArray arrayWithArray:[_trackerItems filteredArrayUsingPredicate:p]];
            [_tableViewTracker reloadData];
            [_tableViewTracker setContentOffset:CGPointMake(0, 0) animated:YES];
        }
            break;
            
        default:
            break;
    }
    btn.selected = YES;
}


-(void)sectionTapped:(UIButton *)btn{
    for(UIButton *b in _buttons){
        b.backgroundColor = self.view.backgroundColor;
        [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
    }
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    
    int idx = (int)btn.tag;
    if(idx == 0){
        _viewUpdatesHolder.hidden = NO;
        _viewTrackerHolder.hidden = YES;
        _bubbleNewActs.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG2];
        _bubbleNewTracks.backgroundColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
        [UIView animateWithDuration:0.5 animations:^{
            _bubbleNewActs.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        _viewUpdatesHolder.hidden = YES;
        _viewTrackerHolder.hidden = NO;
        _bubbleNewActs.backgroundColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
        _bubbleNewTracks.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG2];
        [UIView animateWithDuration:0.5 animations:^{
            _bubbleNewTracks.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }
    
    
    if(_finishedLayout){
     if([UIApplication sharedApplication].applicationIconBadgeNumber > 0){
         [[RAVNPush sharedInstance] resetBadgeToZero];
         [AppController sharedInstance].currentUser.hasNewActivity = NO;
         NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
         AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
         manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
         [manager POST:[AppAPIBuilder APIForResetBadge:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         }];
     }
    }
}

-(void)fetchData{
    
    
    _isUpdating = YES;
    if(_page == 0){
        _simpleLoadingScreen.width = self.view.width;
        _simpleLoadingScreen.height = self.view.height;
        _simpleLoadingScreen.y = _topnav.view.height + _sortByHolder.height + _refreshControl.height - 20;
        _simpleLoadingScreen.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        [self.view addSubview:_simpleLoadingScreen];
    }


    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict addEntriesFromDictionary:@{@"page":[NSNumber numberWithInt:_page]}];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetActivity:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_refreshControl endRefreshing];
        _isUpdating = NO;
        [_simpleLoadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            
            int totalNewTrackers = 0;
            int totalNewActs = 0;
           
            if(_page == 0){
                [_trackerItems removeAllObjects];
                [_items removeAllObjects];
            }
            
            
            if([[NSString returnStringObjectForKey:@"more" withDictionary:responseObject] isEqualToString:@"N"]){
                _isUpdating = YES;
            }
            
            for(NSDictionary *d in [responseObject objectForKey:@"tracker"]){
                AppActivity *a = [[AppActivity alloc] initWithDictionary:d];
                if(a.created > [AppController sharedInstance].currentUser.lastSeenActivityTime){
                    totalNewTrackers++;
                }
                [_trackerItems addObject:a];
            }
            _trackerItemsForFilter = [NSMutableArray arrayWithArray:_trackerItems];
            
            
            for(NSDictionary *d in [responseObject objectForKey:@"updates"]){
                AppActivity *a = [[AppActivity alloc] initWithDictionary:d];
                if(a.created > [AppController sharedInstance].currentUser.lastSeenActivityTime){
                    totalNewActs++;
                }
                [_items addObject:a];
            }
            
            
            if(totalNewActs > 0){
                [_bubbleNewActs.layer removeAllAnimations];
                _bubbleNewActs.hidden = NO;
                _bubbleNewActs.alpha = 1;
                _bubbleNewActs.text = [NSString stringWithFormat:@"%d",totalNewActs];
            }
            
            if(totalNewTrackers > 0){
                [_bubbleNewTracks.layer removeAllAnimations];
                _bubbleNewTracks.hidden = NO;
                _bubbleNewTracks.alpha = 1;
                _bubbleNewTracks.text = [NSString stringWithFormat:@"%d",totalNewTrackers];
            }
            
            
            [_tableViewActivity reloadData];
            [_tableViewTracker reloadData];
            
            [AppController sharedInstance].currentUser.lastSeenActivityTime = [[NSDate date] timeIntervalSince1970];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isUpdating = NO;
        [_simpleLoadingScreen removeFromSuperview];
        [_refreshControl endRefreshing];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

}




#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _tableViewTracker){
        _noResultsTracker.hidden = ([_trackerItemsForFilter count] > 0);
        return [_trackerItemsForFilter count];
    }

    _noResultsUpdates.hidden = YES;
    
    if([_items count] < 3){
        int total = (int)[_items count];
        _btnAddFriends.hidden = NO;
        _btnAddFriends.y = _tableViewActivity.y + 40 + (total * 95);
    }else{
        _btnAddFriends.hidden = YES;
    }
    
    return [_items count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    AppActivityTableViewCell *cell = (AppActivityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppActivityTableViewCell];
    if (cell == nil) {
        cell = [[AppActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppActivityTableViewCell];
    }
    
    //
    AppActivity *a;
    if(tableView == _tableViewTracker){
        a = [_trackerItemsForFilter objectAtIndex:indexPath.row];
        cell.cellTypeTracker = YES;
        [cell setupWithActivity:a];
        
    }else{
        a = [_items objectAtIndex:indexPath.row];
        cell.cellTypeTracker = NO;
        [cell setupWithActivity:a];
    }
    
    
    if(a.userAcceptRejectOptions){
        cell.rightButtons = @[
                          [MGSwipeButton buttonWithTitle:@"ACCEPT" andIcon:@"f" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:95],
                          [MGSwipeButton buttonWithTitle:@"REJECT" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_RED] withHeight:95]
                          ];
        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }else if(a.userRejectOptions){
        
        //check if we are set in stone friends
        BOOL isSetInStone = NO;
        if(a.associatedContact){
            
            isSetInStone = a.associatedContact.isSetInStone;
        }
        
        cell.rightButtons = @[
                              [MGSwipeButton buttonWithTitle:@"REMOVE\nFRIEND" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_RED] withHeight:95],
                              [MGSwipeButton buttonWithTitle:@"ADD TO\nGROUP" andIcon:@"o" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:95],
                              [MGSwipeButton buttonWithTitle:(isSetInStone) ? @"ADDED TO\nSET IN STONE" : @"ADD TO\nSET IN STONE" andIcon:@"i" backgroundColor:[UIColor colorWithHexString:COLOR_CC_TEAL] withHeight:95]
                              ];
        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }else if(a.swipeOptionMissUpdatePlans){
        
        cell.rightButtons = @[
                              [MGSwipeButton buttonWithTitle:@"UPDATE\nPLANS" andIcon:@"f" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:95]
                              ];
        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }else if(a.swipeOptionMissJoin){
        
        if([a.usersInvitedToJoinPlan count] > 0){
            cell.rightButtons = @[
                                      [MGSwipeButton buttonWithTitle:@"ACCEPT" andIcon:@"f" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:95],
                                      [MGSwipeButton buttonWithTitle:@"REJECT" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_RED] withHeight:95],
                                      [MGSwipeButton buttonWithTitle:@"VIEW\nPEOPLE" andIcon:@"o" backgroundColor:[UIColor colorWithHexString:COLOR_CC_TEAL] withHeight:95]
                                      ];
        }else{
            cell.rightButtons = @[
                                  [MGSwipeButton buttonWithTitle:@"ACCEPT" andIcon:@"f" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:95],
                                  [MGSwipeButton buttonWithTitle:@"REJECT" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_RED] withHeight:95]
                                  ];
        }
        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }else{
        cell.rightButtons = @[];
    }
    

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppActivity *a;
    
    if(tableView == _tableViewTracker){
        a = [_trackerItemsForFilter objectAtIndex:indexPath.row];
    }else{
        a = [_items objectAtIndex:indexPath.row];
    }
    
    if(a.activityType == AppActivityTypeUser){
        [[AppController sharedInstance] routeToUserProfile:a.usersId];
    }else if(a.activityType == AppActivityTypePlan){

        if([a.usersId isNotEmpty])
            [[AppController sharedInstance] routeToUserProfile:a.usersId];

    }else if(a.activityType == AppActivityTypeBTDT){
        
        AppBeenThereDetailViewController *vc = [[AppBeenThereDetailViewController alloc] initWithNibName:@"AppBeenThereDetailViewController" bundle:nil];
                    vc.beenThere = a.btItem;
                    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        
    }
    
    
}


-(BOOL)swipeTableCell:(AppActivityTableViewCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    
    if(cell.cellTypeTracker){
        
        _pathInQuestion = [_tableViewTracker indexPathForCell:cell];
        _activityInQuestion = [_trackerItemsForFilter objectAtIndex:_pathInQuestion.row];
        _tableViewInQuestion = _tableViewTracker;
    }else{

        _pathInQuestion = [_tableViewActivity indexPathForCell:cell];
        _activityInQuestion = [_items objectAtIndex:_pathInQuestion.row];
        _tableViewInQuestion = _tableViewActivity;
    }
    
    
    
    if(_activityInQuestion.userAcceptRejectOptions){
    
        if(index == 1) {
    
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to deny this friend request?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
            alert.tag = 32;
            [alert show];
            return NO;
        }else if(index == 0) {
            
            if(!cell.cellTypeTracker){

                NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
                [dict setObject:_activityInQuestion.usersId forKey:@"user_id"];
                [dict setObject:@"Y" forKey:@"accept"];
                
                
                _activityInQuestion.line2 = @"Accepted friend request";
                _activityInQuestion.userAcceptRejectOptions = NO;
                _activityInQuestion.userRejectOptions = YES;
                
                [_tableViewActivity reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
                [manager POST:[AppAPIBuilder APIForUpdateFriendToFriend:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
                    responseObject = [VTUtils processResponse:responseObject];
                    if([VTUtils isResponseSuccessful:responseObject]){
                        
                    }else{
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            }
            
        }
    }else if(_activityInQuestion.userRejectOptions){

        if(index == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Friend" message:@"Are you sure you want to remove this friend?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
            alert.tag = 33;
            [alert show];
            return NO;
        }else if(index == 1) {
            
            AppCustomGroupsViewController *vc = [[AppCustomGroupsViewController alloc] initWithNibName:@"AppCustomGroupsViewController" bundle:nil];
            AppContact *c = [[AppContact alloc] init];
            c.userId = _activityInQuestion.usersId;
            vc.contact = c;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }else if(index == 2){
            if(_activityInQuestion.associatedContact){
                if(_activityInQuestion.associatedContact.isSetInStone){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"This contact is already added to Set in Stone and will be able to see all of your activity" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    return YES;
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Contacts added to Set in Stone will be able to see all of your activity" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add",nil];
            alert.tag = 34;
            [alert show];
            return NO;
        }
    }else if(_activityInQuestion.swipeOptionMissUpdatePlans){
        [[AppController sharedInstance] routeToPlans:AppPlanTypeUpdate];
    }else if(_activityInQuestion.swipeOptionMissJoin){
        
                
        if(index == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Accept Plan" message:@"Select which type of Plan" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sure Plan", @"If Plan",nil];
            alert.tag = 88;
            [alert show];
            return YES;
        }else if(index == 1) {
            
            [self doRejectPlan];
            return YES;
        }else if(index == 2) {
            
            
            if(_viewForUsersInvited != nil){
                [_viewForUsersInvited removeAllSubviews];
                [_viewForUsersInvited removeFromSuperview];
                _viewForUsersInvited = nil;
            }
            
            _viewForUsersInvited = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            _viewForUsersInvited.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.90];
            UIScrollView *sc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, roundf(self.view.height/2))];
            sc.y = roundf(self.view.height - sc.height);
            sc.showsVerticalScrollIndicator = NO;
            
            [self.view addSubview:_viewForUsersInvited];
            [_viewForUsersInvited addSubview:sc];
            
            float padding = roundf(self.view.width * 0.10);
            int startingY = 0;
            float delay = 0.02;
            int count = 0;
            for(AppContact *u in _activityInQuestion.usersInvitedToJoinPlan){
                
                UIButton *row = [[UIButton alloc] initWithFrame:CGRectMake(padding, startingY, self.view.width - (padding * 2), 44)];
                row.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
                [row addTarget:self action:@selector(doShowUserProfileFromInviteView:) forControlEvents:UIControlEventTouchUpInside];
                row.tag = count++;
                
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                iv.layer.borderColor = [UIColor colorWithHexString:@"CCCCCC"].CGColor;
                iv.layer.borderWidth = 1.0;
                iv.layer.cornerRadius = roundf(iv.height/2);
                [iv setImageWithURL:[NSURL URLWithString:u.img] placeholderImage:[AppController sharedInstance].personImageIcon];
                
                iv.x = 10;
                iv.y = roundf(row.height/2 - iv.height/2);
                
                UILabel *check = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, roundf(row.height * 0.50), roundf(row.height * 0.50))];
                check.backgroundColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
                check.clipsToBounds = YES;
                check.layer.cornerRadius = roundf(check.height/2);
                check.text = @"3";
                check.textAlignment = NSTextAlignmentCenter;
                check.font = [UIFont fontWithName:FONT_ICONS size:11];
                check.textColor = [UIColor whiteColor];
                check.y = roundf(row.height/2 - check.height/2);
                check.x = roundf(row.width - check.width - 10);
                
                if(!u.acceptedPlanJoinInvite){
                    check.hidden = YES;
                }
                UILabel *name = [[UILabel alloc] init];
                name.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:13];
                name.text = u.name;
                name.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
                name.x = iv.maxX + 8;
                name.height = row.height;
                name.width = roundf(check.x - name.x - 3);
                
                UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, row.height - 1, row.width, 1)];
                line.backgroundColor = [UIColor colorWithHexString:@"#F3F4F5"];
                
                [row addSubview:iv];
                [row addSubview:name];
                [row addSubview:check];
                [row addSubview:line];
                [sc addSubview:row];
                startingY += row.height;
                int offset = 50;
                row.y += offset;
                row.alpha = 0;
                [UIView animateWithDuration:0.8 delay:delay usingSpringWithDamping:0.65 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
                    row.y -= offset;
                    row.alpha = 1;
                } completion:^(BOOL finished) {
                   
                }];
                delay += 0.03;
            }
            
            CCButton *btnClose = [[CCButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            [btnClose addTarget:self action:@selector(doCloseInvitedView) forControlEvents:UIControlEventTouchUpInside];
            btnClose.x = roundf(self.view.width/2 - btnClose.width/2);
            btnClose.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:32];
            [btnClose setTitle:@"A" forState:UIControlStateNormal];
            [btnClose resetDefaults];

            btnClose.y = roundf(sc.y - btnClose.height - 20);
            [_viewForUsersInvited addSubview:btnClose];
            
            [sc setContentSize:CGSizeMake(sc.width, startingY)];
            
            
            return YES;
        }
       
    }
    return YES;
}

-(void)doShowUserProfileFromInviteView:(UIButton *)btn{
    int idx = (int) btn.tag;
    AppContact *c = [_activityInQuestion.usersInvitedToJoinPlan objectAtIndex:idx];
    [[AppController sharedInstance] routeToUserProfile:c.userId];
}

-(void)doCloseInvitedView{
    [_viewForUsersInvited removeFromSuperview];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    int idx =(int)buttonIndex;
    
    if(alertView.tag == 88){
        if(idx == 1){
            [self doDuplicatePlan:AppPlanTypeSure];
            return;
        }else if(idx == 2){
            [self doDuplicatePlan:AppPlanTypeIf];
            return;
        }
    }else if(alertView.tag == 34){
        if(idx == 1){
            
            if(_activityInQuestion.associatedContact){
                _activityInQuestion.associatedContact.isSetInStone = YES;
            }
            
            NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
            [dict setObject:_activityInQuestion.usersId forKey:@"id"];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
            [manager POST:[AppAPIBuilder APIForSetFriendInStone:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            }];
            [_tableViewInQuestion reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Added" message:@"Contact added to Set In Stone!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if(alertView.tag == 33){
        if(idx == 1){
            
            NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
            [dict setObject:_activityInQuestion.usersId forKey:@"user_id"];
            [dict setObject:@"N" forKey:@"accept"];
            _activityInQuestion.line2 = @"Removed friend";
            _activityInQuestion.userAcceptRejectOptions = NO;
            _activityInQuestion.userRejectOptions = NO;

            [_tableViewInQuestion reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
            [manager POST:[AppAPIBuilder APIForUpdateFriendToFriend:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                responseObject = [VTUtils processResponse:responseObject];
                if([VTUtils isResponseSuccessful:responseObject]){
                    
                }else{
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
            
        }else{
            [_tableViewActivity reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else if(alertView.tag == 32){
        if(idx == 1){
            
            NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
            [dict setObject:_activityInQuestion.usersId forKey:@"user_id"];
            [dict setObject:@"N" forKey:@"accept"];
            
            _activityInQuestion.line2 = @"Denied friend request";
            _activityInQuestion.userAcceptRejectOptions = NO;
            _activityInQuestion.userRejectOptions = NO;
            
            [_tableViewInQuestion reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
            [manager POST:[AppAPIBuilder APIForUpdateFriendToFriend:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                responseObject = [VTUtils processResponse:responseObject];
                
                if([VTUtils isResponseSuccessful:responseObject]){
                    
                }else{
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];

        }else{
         [_tableViewActivity reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else if(alertView.tag == 400){
        if(idx == 1){
            [self doDuplicatePlan:AppPlanTypeIf];
            [_tableViewActivity reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else if(alertView.tag == 401){
        if(idx == 1){
            [self doDuplicatePlan:AppPlanTypeSure];
            [_tableViewActivity reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

-(void)doDuplicatePlan:(AppPlanType)type{
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Saving" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:_activityInQuestion.swipeOptionId forKey:@"plans_id"];
    [dict setObject:[NSNumber numberWithInt:type] forKey:@"plans_types_id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForDuplicatePlan:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [[AppController sharedInstance].currentUser addKeyValueFromDictionary:[responseObject objectForKey:@"user"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_INFO_UPDATED object:nil];
            [[AppController sharedInstance] routeToPlans:type];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
}

-(void)doRejectPlan{
        
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:_activityInQuestion.swipeOptionId forKey:@"plans_id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForRejectPlanInvite:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [_items removeObjectAtIndex:_pathInQuestion.row];
            [_tableViewActivity deleteRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
