//
//  AppDreamingOfEditViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "MGSwipeTableCell.h"

@interface AppDreamingOfEditViewController : AppViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,MGSwipeTableCellDelegate>{
    NSMutableArray *_items;
    NSMutableArray *_itemsStored;
    AFHTTPRequestOperationManager *_searchManager;
    int _lastTicket;
    NSMutableDictionary *_previousResults;
    NSString *_selectedWhereId;
    NSMutableArray *_multiCellSelected;
    float _rowHeight;

}
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *cityView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *tableViewCity;
@property (strong, nonatomic) IBOutlet UIView *viewSearch;
@property (strong, nonatomic) IBOutlet UITextField *inputWhere;

-(IBAction)doAddCity;
-(IBAction)hideCityView;
    
@end
