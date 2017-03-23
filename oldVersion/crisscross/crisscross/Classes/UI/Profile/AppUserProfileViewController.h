//
//  AppUserProfileViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "MGSwipeTableCell.h"
#import "VTImagePicker.h"


@interface AppUserProfileViewController : AppViewController<MGSwipeTableCellDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSArray *_sections;
    NSMutableArray *_bottomSections;
    NSMutableArray *_bottomSectionRows;
    NSMutableArray *_buttons;
    
    BOOL _searchShowing;
    BOOL _searchActive;
    
    BOOL _blockSurePlan;
    BOOL _blockIfPlan;
    
    NSMutableArray *_searchResults;
    
    UIScrollView *_sectionsHolder;
    NSIndexPath *_pathInQuestion;
    VTImagePicker *_imagePicker;
    BOOL _isOwner;
    UIView *_highlightOn;
    BOOL _doAnimateIn;
    UIView *_simpleLoadingScreen;
    AppPlan *_surePlan;
    AppPlan *_ifPlan;
    
    AppActivity *_activityInQuestion;
    UILabel *_labelNoActivity;
    UIView *_hintView;
    
    BOOL _areFriends;
    
    
}
@property (strong, nonatomic) IBOutlet CCButton *btnChangeBg;
@property (strong, nonatomic) IBOutlet UIView *simpleLoadingScreen;

@property (strong, nonatomic) IBOutlet UIView *mastheadView;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIImageView *topImage;
@property (strong, nonatomic) IBOutlet UIView *bottomViewFriends;
@property (strong, nonatomic) IBOutlet UIView *friendsPrivateView;
@property (strong, nonatomic) IBOutlet UIButton *btnFriendRequest;


@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *userLocation;
@property (strong, nonatomic) IBOutlet CCButton *btnSettings;
@property (strong, nonatomic) IBOutlet AppUser *thisUser;
@property (strong, nonatomic) NSString *mainContactId;

@property (strong, nonatomic) IBOutlet UIView *addFriendsHolder;

@property (strong, nonatomic) IBOutlet UIButton *btnHitArea;
@property (strong, nonatomic) IBOutlet UILabel *labelNoFriends;

@property (strong, nonatomic) IBOutlet UITableView *tableViewTimeline;
@property (strong, nonatomic) IBOutlet UITableView *tableViewFriends;
@property (strong, nonatomic) IBOutlet UIButton *btnAddFriends;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *c;

@property (strong, nonatomic) IBOutlet UIView *viewNotFriends;
- (IBAction)doPhotoLargerView;
- (IBAction)doSettings;
- (IBAction)doAddFriends;
- (IBAction)doChangeBackground;
- (IBAction)doSendFriendRequest;

@end
