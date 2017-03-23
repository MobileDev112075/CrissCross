//
//  AppAddGroupsViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppAddGroupsViewController.h"

#import "AppCustomGroupsViewController.h"
#import "AppAddGroupsTableViewCell.h"
#import "UIView+Additions.h"
#import "UIColor+Additions.h"
#import "AppConstants.h"
#import "MGSwipeButton.h"

#define kAppAddGroupsTableViewCell @"AppAddGroupsTableViewCell"


@interface AppAddGroupsViewController ()

@end

@implementation AppAddGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rowsToShow = 10;
    [_tableView registerNib:[UINib nibWithNibName:kAppAddGroupsTableViewCell bundle:nil] forCellReuseIdentifier:kAppAddGroupsTableViewCell];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
//    [self layoutUI];
}

//-(void)layoutUI{
//    if(!_didLayout){
//        _didLayout = YES;
//        
//        if(_selectedGroup){
//            _items = [AppController sharedInstance].currentUser.friends;
//            _topnav.theTitle.text = @"Manage Group";
//            _tableView.y = _topnav.view.height;
//            _tableView.height = self.view.height - _tableView.y;
//        }else if(_loadFriends){
//            _items = [AppController sharedInstance].currentUser.friends;
//            _topnav.theTitle.text = @"Manage Groups2";
//        }else{
//            _items = [AppController sharedInstance].currentUser.latestInvites;
//            _topnav.theTitle.text = @"Add to Group";
//            _topnav.btnBack.hidden = YES;
//            [self.view addSubview:_btnSkip];
//        }
//        
//        
//        
//    }
//}



#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return round(self.view.height/_rowsToShow);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppAddGroupsTableViewCell *cell = (AppAddGroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppAddGroupsTableViewCell];
    if (cell == nil) {
        cell = [[AppAddGroupsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppAddGroupsTableViewCell];
    }
    
    AppContact *c = [_items objectAtIndex:indexPath.row];
    
    [cell setupWithContact:c];
    
    cell.rightButtons = @[
                          [MGSwipeButton buttonWithTitle:@"REMOVE\nFRIEND" andIcon:@"h" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:round(self.view.height/_rowsToShow)],
                          [MGSwipeButton buttonWithTitle:@"ADD TO\nCUSTOM" andIcon:@"+" backgroundColor:[UIColor colorWithHexString:COLOR_CC_TEAL] withHeight:round(self.view.height/_rowsToShow)],
                          [MGSwipeButton buttonWithTitle:@"ADD TO\nSET IN STONE" andIcon:@"i" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:round(self.view.height/_rowsToShow)]
                          ];
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;    
}



-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    _pathInQuestion = [_tableView indexPathForCell:cell];
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to remove this friend from CrissCross?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove",nil];
        alert.tag = 32;
        [alert show];
        return NO;
    }else if(index == 1) {
        
        AppCustomGroupsViewController *vc = [[AppCustomGroupsViewController alloc] initWithNibName:@"AppCustomGroupsViewController" bundle:nil];
        AppContact *c = [_items objectAtIndex:_pathInQuestion.row];
    
        if(c.userId.length < 7 && c.databaseId.length > 2){
            c.userId = c.databaseId;
        }
        
        vc.contact = c;
//        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        return YES;
    }else if(index == 2) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Contacts added to Set in Stone will be able to see all of your activity" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add",nil];
        alert.tag = 33;
        [alert show];
        return NO;
    }
    return YES;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    int idx =(int)buttonIndex;
//    if(alertView.tag == 33){
//        if(idx == 1){
//            AppContact *c = [_items objectAtIndex:_pathInQuestion.row];
//            NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
//            [dict setObject:c.databaseId forKey:@"id"];
//            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//            manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
//            [manager POST:[AppAPIBuilder APIForSetFriendInStone:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            }];
//            [_tableView reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Added" message:@"Contact Added!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//            [alert show];
//        }
//    }else if(alertView.tag == 32){
//        if(idx == 1){
//            AppContact *c = [_items objectAtIndex:_pathInQuestion.row];
//            NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
//            [dict setObject:c.databaseId forKey:@"id"];
//            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//            manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
//            [manager POST:[AppAPIBuilder APIForRemoveFriend:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            }];
//            [_items removeObjectAtIndex:_pathInQuestion.row];
//            [_tableView deleteRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationLeft];
//        }
//    }
}


- (IBAction)doSkip {
//    [[AppController sharedInstance] routeToDashboard];
}
@end
