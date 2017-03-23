//
//  AppFriendsInGroupViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 8/4/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppFriendsInGroupViewController.h"
#import "MGSwipeButton.h"
#import "AppPlansInviteTableViewCell.h"

#define kAppPlansInviteTableViewCell @"AppPlansInviteTableViewCell"
#define kAppStaticCellName @"kAppStaticCellName"




@interface AppFriendsInGroupViewController ()

@end

@implementation AppFriendsInGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _items = [[NSMutableArray alloc] init];
    _searchResults = [[NSMutableArray alloc] init];
    
    [_tableView registerNib:[UINib nibWithNibName:kAppPlansInviteTableViewCell bundle:nil] forCellReuseIdentifier:kAppPlansInviteTableViewCell];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:FONT_HELVETICA_NEUE size:13], NSFontAttributeName, nil]
     forState:UIControlStateNormal];
    _noResults.hidden = YES;
    
    [self fetchData];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
        
        if(_theGroup != nil){
            _topnav.theTitle.text = @"Edit Friends in Group";
            _topView.y = _topnav.view.height;
            _labelFriendsInGroup.y = _topView.maxY + 10;
            _tableView.y = _labelFriendsInGroup.maxY;
            _tableView.height = self.view.height - _tableView.y;
            [_tableView reloadData];
            _topView.layer.shadowColor = [UIColor colorWithHexString:@"CCCCCC"].CGColor;
            _topView.layer.shadowOffset = CGSizeMake(0,0);
            _topView.layer.shadowOpacity = 1;
            _topView.layer.shadowRadius = 12;
        }
        
    }
}



-(void)fetchData{
    
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:_theGroup.groupId forKey:@"id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetGroup:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            
            [_items removeAllObjects];
            for(NSDictionary *d in [responseObject objectForKey:@"users"]){
                AppContact *c = [[AppContact alloc] initWithDictionary:d];
                [_items addObject:c];
            }
            [_tableView reloadData];
            
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
    
}




#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(_searchActive){
        _labelFriendsInGroup.text = [@"ADD FRIENDS TO GROUP: " stringByAppendingString:_theGroup.title];
        
        _noResults.hidden = [_searchResults count] > 0;
        
        return [_searchResults count];
    }else{
        _labelFriendsInGroup.text = [@"FRIENDS IN GROUP: " stringByAppendingString:_theGroup.title];
    }
    
    _noResults.hidden = [_items count] > 0;
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    

    AppPlansInviteTableViewCell *cell = (AppPlansInviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppPlansInviteTableViewCell];
    if (cell == nil) {
        cell = [[AppPlansInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppPlansInviteTableViewCell];
    }
    
    AppContact *c;
    
    if (_searchActive){
        c = [_searchResults objectAtIndex:indexPath.row];
        cell.showTapToAdd = YES;
    }else{
        c = [_items objectAtIndex:indexPath.row];
        cell.showTapToAdd = NO;
    }
    
    cell.showHometown = NO;
    [cell setupWithContact:c andSelected:NO];
    cell.labelCheckOn.hidden = YES;
    cell.labelCheckOff.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.rightButtons = @[
                          [MGSwipeButton buttonWithTitle:@"REMOVE" andIcon:@"h" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:55]
                          ];
    cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppContact *c;
    if (_searchActive){
        
        c = [_searchResults objectAtIndex:indexPath.row];
        
        if([_theGroup.usersIds containsObject:c.userId]){
            
            [self searchBarCancelButtonClicked:_searchBar];
            return;
        }else{
            [_theGroup.usersIds addObject:c.userId];
        }
        
        [_items insertObject:c atIndex:0];
        [_tableView reloadData];
        
        NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
        [dict setObject:_theGroup.groupId forKey:@"group_id"];
        [dict setObject:c.userId forKey:@"user_id"];
        
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [manager POST:[AppAPIBuilder APIForAddToGroup:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            responseObject = [VTUtils processResponse:responseObject];
            if([VTUtils isResponseSuccessful:responseObject]){
                
                
            }else{
            
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
        [self searchBarCancelButtonClicked:_searchBar];
        
        
    }else{
        c = [_items objectAtIndex:indexPath.row];
    }
}



#pragma search

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton: YES animated: YES];
    _searchShowing = YES;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton: NO animated: YES];
    _searchShowing = NO;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    

    _searchActive = YES;
    if([searchText isEmpty]){
        _searchActive = NO;
        [_tableView reloadData];
    }else{
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"( (name BEGINSWITH[cd] %@) OR (name CONTAINS[cd] %@) OR (lastName BEGINSWITH[cd] %@) OR (firstName BEGINSWITH[cd] %@))", searchText,[NSString stringWithFormat:@" %@",searchText],searchText,searchText];
        
        
        _searchResults = [NSMutableArray arrayWithArray:[[AppController sharedInstance].currentUser.friends filteredArrayUsingPredicate:p]];
        [_tableView reloadData];
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [[AppController sharedInstance] hideKeyboard];
    _searchBar.text = @"";
    _searchActive = NO;
    [_tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
}








-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{

    _pathInQuestion = [_tableView indexPathForCell:cell];
    
    AppContact *c = [_items objectAtIndex:_pathInQuestion.row];
    [_items removeObjectAtIndex:_pathInQuestion.row];
    [_tableView deleteRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationLeft];

    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:c.userId forKey:@"user_id"];
    [dict setObject:_theGroup.groupId forKey:@"id"];
    
    if([_theGroup.usersIds containsObject:c.userId]){
        [_theGroup.usersIds removeObject:c.userId];
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForRemoveFromGroup:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
    return YES;
    
}








@end
