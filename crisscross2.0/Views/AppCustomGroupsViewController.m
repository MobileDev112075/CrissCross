//
//  AppCustomGroupsViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppCustomGroupsViewController.h"

#import "AppAddCustomGroupTableViewCell.h"
#import "MGSwipeButton.h"
#import "AppConstants.h"
#import "UIView+Additions.h"
#import "UIColor+Additions.h"
#import "NSString+Additions.h"

#define kAppAddCustomGroupTableViewCell @"AppAddCustomGroupTableViewCell"

@interface AppCustomGroupsViewController ()

@end

@implementation AppCustomGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rowsOnScreen = 10;
    _multiCellSelected = [[NSMutableArray alloc] init];
    _items = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    [_tableView registerNib:[UINib nibWithNibName:kAppAddCustomGroupTableViewCell bundle:nil] forCellReuseIdentifier:kAppAddCustomGroupTableViewCell];
//    [self fetchGroups];
}

-(void)viewWillDisappear:(BOOL)animated{
    if([_items count] > 0){
        AppGroup *g = [_items firstObject];
        if(g.isTopBlock){
            [_items removeObjectAtIndex:0];
        }
    }
//    [AppController sharedInstance].currentUser.groups = _items;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_GROUPS_UPDATED object:nil];
    [super viewWillDisappear:animated];
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
//    if(!_didLayout){
//        _didLayout = YES;
    
//        if(_isManageView){
//            _btnSave.hidden = YES;
//            _topnav.theTitle.text = @"Manage Groups";
//            _tableView.y = _topView.maxY;
//            _tableView.height = self.view.height - _tableView.y;
//        }else{
//            _topnav.theTitle.text = @"Add to Group";
//        }
        _topView.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG2];
        _tableView.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
//    }
}



//
//-(void)fetchGroups{
//    
//    
//    [_loadingScreen removeFromSuperview];
//    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading Groups" andColor:nil withDelay:0];
//    _loadingScreen.alpha = 1;
//    [self.view addSubview:_loadingScreen];
//    
//    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
//    [manager POST:[AppAPIBuilder APIForGetAllGroups:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        [_loadingScreen removeFromSuperview];
//        responseObject = [VTUtils processResponse:responseObject];
//        if([VTUtils isResponseSuccessful:responseObject]){
//
//            [_items removeAllObjects];
//            NSArray *dataReturned = [responseObject objectForKey:@"groups"];
//            
//            for(NSDictionary *tempDict in dataReturned){
//                AppGroup *g = [[AppGroup alloc] initWithDictionary:tempDict];
//                [_items addObject:g];
//            }
//            [_tableView reloadData];
//            
//        }else{
//            [[AppController sharedInstance] alertWithServerResponse:responseObject];
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [_loadingScreen removeFromSuperview];
//        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
//    }];
//    
//    
//}
//



#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return round(self.view.height/_rowsOnScreen);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppAddCustomGroupTableViewCell *cell = (AppAddCustomGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppAddCustomGroupTableViewCell];
    if (cell == nil) {
        cell = [[AppAddCustomGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppAddCustomGroupTableViewCell];
    }
    
    AppGroup *g = [_items objectAtIndex:indexPath.row];
    g.isManageView = _isManageView;
    [cell setupWithGroup:g andSelected:[_multiCellSelected containsObject:indexPath]];
    
     cell.rightButtons = @[];
    if(_isManageView || indexPath.row >= 0){
    
        if([g.groupId isEqualToString:@"STONE"]){
            
        }else{

            cell.rightButtons = @[
                              [MGSwipeButton buttonWithTitle:@"DELETE\nGROUP" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:round(self.view.height/_rowsOnScreen)],
                              [MGSwipeButton buttonWithTitle:@"CHANGE\nNAME" andIcon:@"z" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:round(self.view.height/_rowsOnScreen)]
                              ];
            cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        }
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    if(_isManageView){
       
        AppGroup *g = [_items objectAtIndex:indexPath.row];
        AppFriendsInGroupViewController *vc = [[AppFriendsInGroupViewController alloc] initWithNibName:@"AppFriendsInGroupViewController" bundle:nil];
        vc.theGroup = g;
//        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        return;
    }
    
    if ([_multiCellSelected containsObject:indexPath]){
        [_multiCellSelected removeObject:indexPath];
    }
    else{
        [_multiCellSelected addObject:indexPath];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}



-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    _pathInQuestion = [_tableView indexPathForCell:cell];
    AppGroup *g = [_items objectAtIndex:_pathInQuestion.row];
    
    if(index == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to delete this group?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil];
        alert.tag = 32;
        [alert show];
        return NO;
    }else if(index == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Update the group name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.text = g.title;
        alert.tag = 29;
        [alert show];
        return NO;
    }
    return YES;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    int idx =(int)buttonIndex;
    if(alertView.tag == 33){
        if(idx == 1){
            
        }
    }else if(alertView.tag == 32){
        if(idx == 1){
            AppGroup *g = [_items objectAtIndex:_pathInQuestion.row];
            [self deleteGroupId:g.groupId];
            [_items removeObjectAtIndex:_pathInQuestion.row];
            [_tableView deleteRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationLeft];

            
        }else{
            [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
        }
    }else if(alertView.tag == 31){
        if(idx == 1){
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *groupNameString = textField.text;
            if([groupNameString isEmpty]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Cannot add a blank name for a group" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alert show];
                if(_pathInQuestion != nil)
                    [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
                return;
            }
            [self createGroupWithName:groupNameString];
            
        }else{
            if(_pathInQuestion != nil)
                [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
        }
    }else if(alertView.tag == 29){
        if(idx == 1){
//            UITextField *textField = [alertView textFieldAtIndex:0];
//            NSString *groupNameString = textField.text;
//            if([groupNameString isEmpty]){
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Cannot have a blank name for a group" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//                [alert show];
//                [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
//                return;
//            }
//            AppGroup *g = [_items objectAtIndex:_pathInQuestion.row];
//            
//            
//            NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
//            [dict setObject:groupNameString forKey:@"title"];
//            [dict setObject:g.groupId forKey:@"id"];
//            
//            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//            manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
//            [manager POST:[AppAPIBuilder APIForUpdateGroupTitle:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) { 
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            }];
//            g.title = groupNameString;
//            [_tableView reloadData];
        }else{
            [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
    _pathInQuestion = nil;
}

-(void)createGroupWithName:(NSString *)groupName{
    
//    [_loadingScreen removeFromSuperview];
//    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Creating Group" andColor:nil withDelay:2.0];
//    _loadingScreen.alpha = 1;
//    [self.view addSubview:_loadingScreen];
//    
//    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
//    [dict setObject:groupName forKey:@"title"];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
//    [manager POST:[AppAPIBuilder APIForCreateGroup:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        [_loadingScreen removeFromSuperview];
//        responseObject = [VTUtils processResponse:responseObject];
//        if([VTUtils isResponseSuccessful:responseObject]){
//            
//
//            AppGroup *g = [[AppGroup alloc] initWithDictionary:[responseObject objectForKey:@"group"]];
//            [_items insertObject:g atIndex:0];
//            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
//            
//            
//        }else{
//            [[AppController sharedInstance] alertWithServerResponse:responseObject];
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [_loadingScreen removeFromSuperview];
//        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
//    }];
}


-(void)addUserId:(NSString *)userId toGroupIds:(NSMutableArray *)ids{
    
//    [_loadingScreen removeFromSuperview];
//    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Saving" andColor:nil withDelay:0];
//    _loadingScreen.alpha = 1;
//    [self.view addSubview:_loadingScreen];
//    
//    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
//    [dict setObject:userId forKey:@"user_id"];
//    [dict setObject:ids forKey:@"ids"];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
//    [manager POST:[AppAPIBuilder APIForAddToGroup:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        [_loadingScreen removeFromSuperview];
//        responseObject = [VTUtils processResponse:responseObject];
//        if([VTUtils isResponseSuccessful:responseObject]){
//            [[AppController sharedInstance] goBack];
//        }else{
//            [[AppController sharedInstance] alertWithServerResponse:responseObject];
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [_loadingScreen removeFromSuperview];
//        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
//    }];
}


-(void)deleteGroupId:(NSString *)groupId{
    
//    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
//    [dict setObject:groupId forKey:@"id"];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
//    [manager POST:[AppAPIBuilder APIForDeleteGroup:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    }];
}

- (IBAction)doSave {
    
    
    NSMutableArray *groupIds = [[NSMutableArray alloc] init];
    for(NSIndexPath *ip in _multiCellSelected){
        AppGroup *g = [_items objectAtIndex:ip.row];
        [groupIds addObject:g.groupId];
    }
    [self addUserId:_contact.userId toGroupIds:groupIds];
}

- (IBAction)doPromptCreateNew {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Enter the name of the new group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    alert.tag = 31;
    [alert show];

    
}


@end
