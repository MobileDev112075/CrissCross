//
//  AppMyPlansViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppMyPlansViewController.h"
#import "AppMyPlansTableViewCell.h"
#import "MGSwipeButton.h"
#import "AppPlanAddViewController.h"

#define kAppMyPlansTableViewCell @"AppMyPlansTableViewCell"

@interface AppMyPlansViewController ()

@end

@implementation AppMyPlansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _items = [AppController sharedInstance].currentUser.allPlans;
    [_tableView registerNib:[UINib nibWithNibName:kAppMyPlansTableViewCell bundle:nil] forCellReuseIdentifier:kAppMyPlansTableViewCell];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:NOTIFICATION_PLANS_UPDATED object:nil];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
        _topnav.theTitle.text = @"My Plans";
        [self.view addSubview:_btnPlus];
        [self fetchData];
    }else{
        [_tableView reloadData];
    }
}



-(void)fetchData{
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading Plans" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:@"all" forKey:@"plan_type"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetPlans:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [_items removeAllObjects];
            [[AppController sharedInstance].currentUser setupPlansWithDictionary:responseObject];
            [_tableView reloadData];
            [self checkTotal];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];    
}

-(void)checkTotal{
    if([_items count] == 0){
        _noPlans.hidden = NO;
        _noPlans.numberOfLines = 0;
        _noPlans.text = @"No Plans\nClick on the plus icon above\nto add a Plan";
        _tableView.hidden = YES;
    }else{
        _noPlans.hidden = YES;
        _tableView.hidden = NO;
    }
}




#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 116.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppMyPlansTableViewCell *cell = (AppMyPlansTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppMyPlansTableViewCell];
    if (cell == nil) {
        cell = [[AppMyPlansTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppMyPlansTableViewCell];
    }
    
    AppPlan *p = [_items objectAtIndex:indexPath.row];
    [cell setupWithPlan:p];
    cell.rightButtons = @[
                          [MGSwipeButton buttonWithTitle:@"" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:116],
                          [MGSwipeButton buttonWithTitle:@"" andIcon:@"z" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:116]
                          
                          ];
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppPlan *p = [_items objectAtIndex:indexPath.row];
    AppPlanAddViewController *vc = [[AppPlanAddViewController alloc] initWithNibName:@"AppPlanAddViewController" bundle:nil];
    vc.editingPlan = p;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        
        NSIndexPath * path = [_tableView indexPathForCell:cell];
        AppPlan *p = [_items objectAtIndex:path.row];
        [[[AppController sharedInstance].currentUser ifPlans] removeObject:p];
        [[[AppController sharedInstance].currentUser surePlans] removeObject:p];
        [self deletePlan:p];
        [_items removeObjectAtIndex:path.row];
        [_tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self checkTotal];
        return NO;
    }else{
        NSIndexPath * path = [_tableView indexPathForCell:cell];
        AppPlan *p = [_items objectAtIndex:path.row];
        AppPlanAddViewController *vc = [[AppPlanAddViewController alloc] initWithNibName:@"AppPlanAddViewController" bundle:nil];
        vc.editingPlan = p;
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    }
    
    return YES;
}


-(void)deletePlan:(AppPlan *)plan{
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:@"Y" forKey:@"delete"];
    [dict setObject:plan.planId forKey:@"plan_id"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForSavingPlans:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

- (IBAction)doAdd {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Add Plan" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sure Plan",@"If Plan",nil];
    [as showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    int idx = (int)buttonIndex;
    if(idx == 2){
        return;
    }else if(idx == 1){
        AppPlanAddViewController *vc = [[AppPlanAddViewController alloc] initWithNibName:@"AppPlanAddViewController" bundle:nil];
        vc.planType = AppPlanTypeIf;
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    }else if(idx == 0){
        AppPlanAddViewController *vc = [[AppPlanAddViewController alloc] initWithNibName:@"AppPlanAddViewController" bundle:nil];
        vc.planType = AppPlanTypeSure;
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    }
    
}


@end
