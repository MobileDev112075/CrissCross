//
//  AppFindViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppFindViewController : AppViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *_items;
    NSMutableArray *_usersThere;
    
    CGSize _kbSize;
    AFHTTPRequestOperationManager *_searchManager;
    int _lastTicket;
    NSMutableDictionary *_previousResults;
    UITableView *_tableThere;
    
    UIView *_viewThere;
    UIView *_viewTableThereInner;
    UIButton *_btnClose;
    
    UIButton *_btnAddAndInviteFriends;
    
}

@property (strong, nonatomic) IBOutlet CCButton *btnFind;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *inputSearch;

- (IBAction)doSearchNextStep;

@end
