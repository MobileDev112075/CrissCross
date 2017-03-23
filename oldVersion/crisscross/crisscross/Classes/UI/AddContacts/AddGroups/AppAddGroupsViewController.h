//
//  AppAddGroupsViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "MGSwipeTableCell.h"

@interface AppAddGroupsViewController : AppViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate,UIAlertViewDelegate>{
    NSMutableArray *_items;
    NSIndexPath *_pathInQuestion;
    int _rowsToShow;
}

@property (strong, nonatomic) AppGroup *selectedGroup;
@property (assign, nonatomic) BOOL loadFriends;
@property (strong, nonatomic) IBOutlet UIButton *btnSkip;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)doSkip;

@end
