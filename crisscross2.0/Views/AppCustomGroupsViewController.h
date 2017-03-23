//
//  AppCustomGroupsViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AppContact.h"
#import "MGSwipeTableCell.h"
#import "AppFriendsInGroupViewController.h"

@interface AppCustomGroupsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>{
    NSMutableArray *_items;
    NSIndexPath *_pathInQuestion;
    NSMutableArray *_multiCellSelected;
    int _rowsOnScreen;
}
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AppContact *contact;

@property (assign, nonatomic) BOOL isManageView;

- (IBAction)doSave;
- (IBAction)doPromptCreateNew;

@end
