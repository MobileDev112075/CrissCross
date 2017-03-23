//
//  AppFindViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppFindViewController.h"
#import "AppActivityTableViewCell.h"
#import "AppPlansInviteTableViewCell.h"
#import "AppFindFriendViewController.h"

#define kAppPlansInviteTableViewCell @"AppPlansInviteTableViewCell"
#define kAppActivityTableViewCell @"AppActivityTableViewCell"
#define kAppFindActivityTableViewCell @"kAppFindActivityTableViewCell"

@interface AppFindViewController ()

@end

@implementation AppFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _items = [[NSMutableArray alloc] init];
    _usersThere = [[NSMutableArray alloc] init];
    _previousResults = [[NSMutableDictionary alloc] init];
    [_topnav clearBackView];
    _topnav.theTitle.hidden = NO;
    _topnav.theTitle.text = @"Find";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFriendView:) name:NOTIFICATION_FOR_FIND_SHOW_HERE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFind) name:NOTIFICATION_FOR_REFRESH_FIND object:nil];
    
    _tableThere = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _tableThere.delegate = self;
    _tableThere.dataSource = self;
    _tableThere.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:kAppActivityTableViewCell bundle:nil] forCellReuseIdentifier:kAppActivityTableViewCell];
    [_tableThere registerNib:[UINib nibWithNibName:kAppPlansInviteTableViewCell bundle:nil] forCellReuseIdentifier:kAppPlansInviteTableViewCell];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;

        _topView.alpha = 0;
        _topView.height = _inputSearch.maxY;
        _topView.y = self.view.height/2 - _topView.height/2;
        [_inputSearch addSubview:_btnFind];
        [_inputSearch addBottomBorderWithHeight:1 andColor:[UIColor colorWithHexString:COLOR_CC_GREEN]];
        _btnFind.y = 5;
        _btnFind.x = _inputSearch.width - _btnFind.width;
        
        _inputSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Friends & Plans" attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE size:_inputSearch.font.pointSize], NSForegroundColorAttributeName : [[UIColor colorWithHexString:COLOR_CC_GREEN] colorWithAlphaComponent:0.8 ] }];
        
        [UIView animateWithDuration:0.5 delay:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _topView.alpha = 1;
            _topView.y -= 10;
        } completion:^(BOOL finished) {
            
        }];
        
        _bottomView.alpha = 0;
        _bottomView.y = self.view.height;
        
        _btnAddAndInviteFriends = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width, roundf(self.view.height * 0.10))];
        _btnAddAndInviteFriends.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        [_btnAddAndInviteFriends setTitle:@"Add and Invite Friends" forState:UIControlStateNormal];
        [_btnAddAndInviteFriends setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnAddAndInviteFriends.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:roundf(_btnAddAndInviteFriends.height * 0.28)];
        _btnAddAndInviteFriends.y = self.view.height - _btnAddAndInviteFriends.height;
        [_btnAddAndInviteFriends addTarget:self action:@selector(doAddFriends) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnAddAndInviteFriends];
    }
}

-(void)doAddFriends{
    AppFindFriendViewController *vc = [[AppFindFriendViewController alloc] initWithNibName:@"AppFindFriendViewController" bundle:nil];
    vc.fromProfile = YES;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}



-(void)processSearchResult:(NSDictionary *)dict overrideTicket:(BOOL)override{
    
    NSString *ticket = [NSString returnStringObjectForKey:@"ticket" withDictionary:dict];
    
    if(override || [ticket isEqualToString:[NSString stringWithFormat:@"%d",_lastTicket]]){
        [_items removeAllObjects];
        for(NSDictionary *d in [dict objectForKey:@"data"]){
            AppActivity *a = [[AppActivity alloc] initWithDictionary:d];
            a.isSearchResult = YES;
            [_items addObject:a];
        }
        [_tableView reloadData];
    }
    
}

-(void)refreshFind{
    [self performStringGeocode:_inputSearch.text];
}

- (void)performStringGeocode:(NSString *)str{
    
    if(_searchManager){
        [_searchManager.operationQueue cancelAllOperations];
    }
    if([_previousResults objectForKey:str] != nil){
        [self processSearchResult:[_previousResults objectForKey:str] overrideTicket:YES];
    }else{
        
        NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
        [dict setValue:str forKey:@"query"];
        [dict setValue:[NSString stringWithFormat:@"%d",++_lastTicket] forKey:@"ticket"];

        _searchManager = [AFHTTPRequestOperationManager manager];
        _searchManager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [_searchManager POST:[AppAPIBuilder APIForFind:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            responseObject = [VTUtils processResponse:responseObject];
            if([VTUtils isResponseSuccessful:responseObject]){
                NSString *term = [NSString returnStringObjectForKey:@"term" withDictionary:responseObject];
                [_previousResults setObject:responseObject forKey:term];
                [self processSearchResult:responseObject overrideTicket:NO];
            }else{
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.01);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [self performStringGeocode:textField.text];
    });
    return YES;
}




#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == _tableThere)
        return [_usersThere count];
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(tableView == _tableThere)
        return 45.0;
    float size = _tableView.height/( (IS_IPHONE_SMALL_WIDTH) ? 4 : 5);
    if(size > 80)
        size = 80;
    return size;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == _tableThere){
        
        AppPlansInviteTableViewCell *cell = (AppPlansInviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppPlansInviteTableViewCell];
        if (cell == nil) {
            cell = [[AppPlansInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppPlansInviteTableViewCell];
        }
        
        AppContact *c = [_usersThere objectAtIndex:indexPath.row];
        [cell setupWithContact:c andSelected:NO];
        cell.itemTextRight.hidden = YES;
        [cell showMinimal];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
    AppActivityTableViewCell *cell = (AppActivityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppActivityTableViewCell];
    if (cell == nil) {
        cell = [[AppActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppActivityTableViewCell];
    }
    AppActivity *a = [_items objectAtIndex:indexPath.row];
    [cell setupWithActivity:a];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if(tableView == _tableThere){
        AppContact *c = [_usersThere objectAtIndex:indexPath.row];
        [[AppController sharedInstance] routeToUserProfile:c.userId];
        return;
    }
    
    AppActivity *a = [_items objectAtIndex:indexPath.row];
    
    if(a.activityType == AppActivityTypeUser){
        [[AppController sharedInstance] routeToUserProfile:a.usersId];
    }else if(a.activityType == AppActivityTypePlan){
        if([a.usersId isNotEmpty])
            [[AppController sharedInstance] routeToUserProfile:a.usersId];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification{
    _kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float newHeight = self.view.height - _kbSize.height - (68 + _topView.height) + 1;
    
    
    [UIView animateWithDuration: 0.15
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _bottomView.alpha = 1;
                         _bottomView.y = 68 + _topView.height - 1;
                         _bottomView.height = newHeight;
                     }
                     completion:^(BOOL finished){}];
    
}

- (void)keyboardWillHide:(NSNotification*)aNotification{
    [UIView animateWithDuration: 0.15
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _bottomView.height = self.view.height - _bottomView.y;
                     }
                     completion:^(BOOL finished){}];
    
}


- (IBAction)doCloseFriendView {
    [UIView animateWithDuration:0.3 animations:^{
        _viewThere.alpha = 0;
    }];
}

- (void)showFriendView:(NSNotification *)note{
    
    if(!_viewThere){
        _viewThere = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _viewTableThereInner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _viewTableThereInner.layer.shadowColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG].CGColor;
        _viewTableThereInner.layer.shadowOffset = CGSizeMake(0,0);
        _viewTableThereInner.layer.shadowOpacity = 1;
        _viewTableThereInner.layer.shadowRadius = 12;
        _viewTableThereInner.layer.cornerRadius = 20;
        
        _btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_btnClose setTitle:@"A" forState:UIControlStateNormal];
        _btnClose.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:32];

        [_btnClose addTarget:self action:@selector(doCloseFriendView) forControlEvents:UIControlEventTouchDown];
        
        [_viewThere addSubview:_viewTableThereInner];
        [_viewTableThereInner addSubview:_tableThere];
        [_viewThere addSubview:_btnClose];
    }
    
    AppActivity *activity = (AppActivity *)note.object;
    
    _usersThere = activity.usersThere;
    [_tableThere reloadData];
    
    [[AppController sharedInstance] hideKeyboard];
    
    _viewThere.width = self.view.width;
    _viewThere.height = self.view.height;
    [self.view addSubview:_viewThere];
    _viewThere.alpha = 0;
    _viewThere.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.65];
    
    _viewTableThereInner.alpha = 0;
    if([_usersThere count] > 3){
        _viewTableThereInner.height = _viewThere.height - 140;
    }else{
        _viewTableThereInner.height = [_usersThere count] * 45;
    }
    
    _viewTableThereInner.width = _viewThere.width - 50;
    _viewTableThereInner.x = _viewThere.width/2 - _viewTableThereInner.width/2;
    _viewTableThereInner.y = _viewThere.height/2 - _viewTableThereInner.height/2;
    _tableThere.width = _viewTableThereInner.width;
    _tableThere.height = _viewTableThereInner.height;
    
    
    _btnClose.alpha = 0;
    _btnClose.x = _viewThere.width/2 - _btnClose.width/2;
    _btnClose.y = _viewTableThereInner.y - _btnClose.height - 10;
    _viewTableThereInner.y += 100;
    [UIView animateWithDuration:0.2 animations:^{
        _viewThere.alpha = 1;
    }];
    
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _viewTableThereInner.alpha = 1;
        _viewTableThereInner.y -= 100;
        _btnClose.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}



-(void)animateResultsUp{
    

}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration: 0.15
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _topView.y = 68;
                     }
                     completion:^(BOOL finished){
                     
                     }];
}

- (IBAction)doSearchNextStep {
    [_inputSearch becomeFirstResponder];
}





@end
