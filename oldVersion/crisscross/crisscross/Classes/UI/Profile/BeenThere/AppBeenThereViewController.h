//
//  AppBeenThereViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "MGSwipeTableCell.h"

@interface AppBeenThereViewController : AppViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,UITextFieldDelegate>{
    NSMutableArray *_items;
    NSMutableArray *_searchItems;
    NSArray *_filteredItems;
    
    AFHTTPRequestOperationManager *_searchManager;
    int _lastTicket;
    NSMutableDictionary *_previousResults;
    BOOL _searchActive;
    BOOL _searchShowing;
    BOOL _isOwner;
    UIView *_tableViewCurtain;
    float _tableContentSize;
    UIButton *_noItems;
    UIView *_hintView;
    BOOL _reloadOnReEntry;
    BOOL _hasFinishedFetch;
    
    UIView *_searchView;
    UITextField *_searchInput;
    BOOL _isFiltering;
    
    BOOL _canShowSearchBar;
    float _rowHeight;
}

@property (strong, nonatomic) IBOutlet CCButton *btnEdit;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AppUser *thisUser;
@property (assign, nonatomic) BOOL communityView;

@property (strong, nonatomic) AppActivity *searchActivity;

@property (strong, nonatomic) IBOutlet UIView *locationSelectionView;
@property (strong, nonatomic) IBOutlet UITableView *tableViewSearch;
@property (strong, nonatomic) IBOutlet CCButton *btnClose;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;


- (IBAction)doAdd;
- (IBAction)doClose;


@end
