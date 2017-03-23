//
//  AppActivityViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppActivityViewController : AppViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>{
    NSArray *_sections;
    NSArray *_sortBySections;
    NSMutableArray *_buttons;
    NSMutableArray *_items;
    NSMutableArray *_trackerItems;
    NSMutableArray *_trackerItemsForFilter;
    UIView *_sortByHolder;
    NSIndexPath *_pathInQuestion;
    
    AppActivity *_activityInQuestion;
    UITableView *_tableViewInQuestion;
    UIButton *_btnAddFriends;
    
    UILabel *_bubbleNewActs;
    UILabel *_bubbleNewTracks;
    BOOL _finishedLayout;
    BOOL _isUpdating;
    int _page;
    UIRefreshControl *_refreshControl;
    
    
    UIView *_viewForUsersInvited;
    
    
}

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UITableView *tableViewActivity;
@property (strong, nonatomic) IBOutlet UIView *simpleLoadingScreen;
@property (strong, nonatomic) IBOutlet UITableView *tableViewTracker;
@property (strong, nonatomic) IBOutlet UIView *viewUpdatesHolder;
@property (strong, nonatomic) IBOutlet UIView *viewTrackerHolder;
@property (strong, nonatomic) IBOutlet UILabel *noResultsTracker;
@property (strong, nonatomic) IBOutlet UILabel *noResultsUpdates;

@end
