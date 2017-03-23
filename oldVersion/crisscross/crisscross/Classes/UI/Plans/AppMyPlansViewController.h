//
//  AppMyPlansViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "MGSwipeTableCell.h"

@interface AppMyPlansViewController : AppViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate,UIActionSheetDelegate>{
    
    NSMutableArray *_items;
}


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *noPlans;
@property (strong, nonatomic) IBOutlet CCButton *btnPlus;
- (IBAction)doAdd;

@end
