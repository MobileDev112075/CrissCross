//
//  AppFriendsInGroupViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 8/4/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "MGSwipeButton.h"

@interface AppFriendsInGroupViewController : AppViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate,UISearchBarDelegate>{
    
    NSMutableArray *_items;
    NSMutableArray *_searchResults;
    BOOL _searchActive;
    BOOL _searchShowing;
    NSIndexPath *_pathInQuestion;
}


@property (strong, nonatomic) AppGroup *theGroup;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UILabel *noResults;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *labelFriendsInGroup;

@end
