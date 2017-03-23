//
//  AppFindFriendViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/18/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppFindFriendViewController : AppViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UISearchBarDelegate,UIActionSheetDelegate>{
    

    NSMutableDictionary *_sectionData;
    NSMutableArray *_sectionKeys;
    
    NSMutableArray *_allContacts;
    NSMutableArray *_allContactsWithApp;
    NSMutableArray *_allContactsWithOutApp;
    

    NSMutableDictionary *_sectionDataHaveApp;
    NSMutableArray *_sectionKeysHaveApp;
    
    
    NSMutableArray *_contactsChanged;
    NSMutableArray *_multiCellSelected;
    
    BOOL _hasAccess;
    
    BOOL _searchShowing;
    BOOL _searchActive;
    BOOL _checkOnEnterView;
    
    BOOL _tabHaveAppInstalledActive;
    
    NSMutableArray *_searchResults;
    CGSize _kbSize;
    
    NSMutableArray *_allEmails;
    UIView *_topTabsView;
    NSMutableArray *_buttons;
}

@property (strong, nonatomic) IBOutlet UIButton *btnSelectAll;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *btnSkip;
@property (assign, nonatomic) BOOL fromProfile;
@property (assign, nonatomic) BOOL fromPlans;
@property (strong, nonatomic) NSString *fromPlansString;
@property (strong, nonatomic) IBOutlet UIButton *btnContinue;
@property (strong, nonatomic) IBOutlet UIView *curtainWithButton;
@property (strong, nonatomic) IBOutlet UIButton *btnCurtainContinue;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *bottomView;



- (IBAction)doContinue;
- (IBAction)doSkip;
- (IBAction)doGrantAccess;
- (IBAction)doSelectAll;

@end
