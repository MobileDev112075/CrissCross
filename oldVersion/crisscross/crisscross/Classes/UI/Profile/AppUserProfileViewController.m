//
//  AppUserProfileViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppUserProfileViewController.h"
#import "AppDreamingOfViewController.h"
#import "AppSettingsViewController.h"
#import "AppBeenThereViewController.h"
#import "AppProfileDetailsViewController.h"
#import "MGSwipeButton.h"
#import "AppCustomGroupsViewController.h"
#import "AppFindFriendViewController.h"

#import "AppPlansViewController.h"
#import "AppPlansInviteTableViewCell.h"
#import "AppActivityTableViewCell.h"
#import "MGSwipeButton.h"
#import "AppBeenThereDetailViewController.h"

#define kAppActivityTableViewCell @"AppActivityTableViewCell"
#define kAppPlansInviteTableViewCell @"AppPlansInviteTableViewCell"
#define kAppStaticCellName @"kAppStaticCellName"


@interface AppUserProfileViewController ()

@end

@implementation AppUserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_topnav clearBackView];
    _searchResults = [[NSMutableArray alloc] init];
    _bottomSectionRows = [[NSMutableArray alloc] init];
    if(_thisUser == nil)
        _thisUser = [[AppUser alloc] initWithDictionary:nil];
    
    _isOwner = NO;
    if(_mainContactId != nil){
        _topnav.btnLogo.hidden = YES;
        _topnav.btnBack.hidden = NO;
        _btnSettings.hidden = YES;
        if([_mainContactId isEqualToString:[AppController sharedInstance].currentUser.userId]){
            _isOwner = YES;
        }
    }else{
        _isOwner = YES;
    }
    
    if(_isOwner){
        _mainContactId = [AppController sharedInstance].currentUser.userId;
    }else{
        _btnAddFriends.hidden = YES;
    }
    
    _buttons = [[NSMutableArray alloc] init];
    
    _labelNoFriends.hidden = YES;
    _btnChangeBg.theLabel.numberOfLines = 2;
    _btnChangeBg.theLabel.text = @"Change\nBackground";
    _btnChangeBg.theLabel.height = _btnChangeBg.height;
    _btnChangeBg.theLabel.y = 0;
    _doAnimateIn = YES;
    _sections = @[
                  @{@"title":@"Timeline"},
                  @{@"title":@"Friends"}
                  ];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated) name:NOTIFICATION_USER_INFO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchData) name:NOTIFICATION_RELOAD_USER_INFO object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildBottomSections) name:NOTIFICATION_PLANS_UPDATED object:nil];
    
    [_tableViewFriends registerNib:[UINib nibWithNibName:kAppPlansInviteTableViewCell bundle:nil] forCellReuseIdentifier:kAppPlansInviteTableViewCell];
    [_tableViewTimeline registerNib:[UINib nibWithNibName:kAppActivityTableViewCell bundle:nil] forCellReuseIdentifier:kAppActivityTableViewCell];

    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:FONT_HELVETICA_NEUE size:13], NSFontAttributeName, nil]
     forState:UIControlStateNormal];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self resetAllHighlights];
}

-(void)userInfoUpdated{
    _topImage.alpha = 0.3;
    _topImage.image = nil;
    _labelNoActivity = [[UILabel alloc] initWithFrame:_labelNoFriends.frame];
    _labelNoActivity.font = _labelNoFriends.font;
    _labelNoActivity.text = @"No Activity";
    _labelNoActivity.textColor = _labelNoFriends.textColor;
    
    if(_isOwner){
        
        
        _thisUser = [AppController sharedInstance].currentUser;
        
        if([AppController sharedInstance].currentUser.imgData != nil){
            _topImage.image = [[UIImage alloc] initWithData:[AppController sharedInstance].currentUser.imgData];
        }else{
            [_topImage setImageWithURL:[NSURL URLWithString:[AppController sharedInstance].currentUser.img] placeholderImage:[AppController sharedInstance].personImageIcon];
        }
        
        
        _userName.text = [AppController sharedInstance].currentUser.name;
        [_userName sizeToFit];
        _userName.x = _topView.width/2 - _userName.width/2;
        _userLocation.text = [AppController sharedInstance].currentUser.showCity;
        [_userLocation sizeToFit];
        _userLocation.x = _topView.width/2 - _userLocation.width/2;
        
    }else{
        [_topImage setImageWithURL:[NSURL URLWithString:_thisUser.img] placeholderImage:[AppController sharedInstance].personImageIcon];
        _userName.text = _thisUser.name;
        [_userName sizeToFit];
        _userName.x = _topView.width/2 - _userName.width/2;
        _userLocation.text = _thisUser.showCity;
        [_userLocation sizeToFit];
        _userLocation.x = _topView.width/2 - _userLocation.width/2;
        
        if(_thisUser.friendsBlocked){
            _friendsPrivateView.width = _bottomViewFriends.width;
            _friendsPrivateView.height = _bottomViewFriends.height;
            [_bottomViewFriends addSubview:_friendsPrivateView];
            
        }
    }
    [self checkfriendsView];
    
    int fontSizeTitle = round(_topImage.height*.14);
    int fontSizeByline = round(_topImage.height*.085);
    if(fontSizeTitle > 32)
        fontSizeTitle = 32;
    
    if(fontSizeByline > 28)
        fontSizeByline = 28;
    
    
    
    _userName.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSizeTitle];
    _userLocation.font = [UIFont fontWithName:_userLocation.font.familyName size:fontSizeByline];
    
    _userName.y = _mastheadView.height/2 - _userName.height;
    _userLocation.y = _mastheadView.height/2;
    [_tableViewTimeline reloadData];
    [_tableViewFriends reloadData];
    
}


-(void)fetchData{
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    if(_isOwner)
        [dict setObject:[AppController sharedInstance].currentUser.userId forKey:@"user_id"];
    else
        [dict setObject:_mainContactId forKey:@"user_id"];
    
    [self.view addSubview:_loadingScreen];

    [self showNotFriends:nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetUser:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            NSDictionary *userData = [responseObject objectForKey:@"user"];
            if(_isOwner){

                _thisUser = [AppController sharedInstance].currentUser;
                [[AppController sharedInstance].currentUser addKeyValueFromDictionary:userData];

            }else{
                AppUser *u = [[AppUser alloc] initWithDictionary:userData];
                _thisUser = u;
                [[AppController sharedInstance].previousFetchedUsersData setObject:u forKey:u.userId];
                
                if([[NSString returnStringObjectForKey:@"not_friends" withDictionary:responseObject] isEqualToString:@"Y"]){
                    [self showNotFriends:@"Y"];
                }else if([[NSString returnStringObjectForKey:@"not_friends" withDictionary:responseObject] isEqualToString:@"P"]){
                    [self showNotFriends:@"Pending"];
                }else if([[NSString returnStringObjectForKey:@"not_friends" withDictionary:responseObject] isEqualToString:@"A"]){
                    [self showNotFriends:@"Accept"];
                }
            }
            
            
            [_tableViewTimeline reloadData];
            [_tableViewFriends reloadData];
            
           
            [self userInfoUpdated];
            [self rebuildBottomSections];
            
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
    
}

-(void)showNotFriends:(NSString *)val{
    
    _areFriends = NO;
    
    if([val isEqualToString:@"Y"]){
        for(UIButton *b in _buttons){
            b.enabled = NO;
            b.alpha = 0.4;
        }
        _btnFriendRequest.tag = 1;
        _viewNotFriends.width = _bottomView.width;
        _viewNotFriends.height = _bottomView.height;
        [_bottomView addSubview:_viewNotFriends];
    }else if([val isEqualToString:@"Pending"]){
        for(UIButton *b in _buttons){
            b.enabled = NO;
            b.alpha = 0.4;
        }
        _viewNotFriends.width = _bottomView.width;
        _viewNotFriends.height = _bottomView.height;
        [_bottomView addSubview:_viewNotFriends];
        
        [_btnFriendRequest setTitle:@"Friend Request Sent" forState:UIControlStateNormal];
        [_btnFriendRequest setTitleColor:_btnFriendRequest.backgroundColor forState:UIControlStateNormal];
        _btnFriendRequest.backgroundColor = [UIColor whiteColor];
        _btnFriendRequest.enabled = NO;
    
        
    }else if([val isEqualToString:@"Accept"]){
        for(UIButton *b in _buttons){
            b.enabled = NO;
            b.alpha = 0.4;
        }
        _viewNotFriends.width = _bottomView.width;
        _viewNotFriends.height = _bottomView.height;
        [_bottomView addSubview:_viewNotFriends];
    
        [_btnFriendRequest setTitle:@"Accept Friend Request" forState:UIControlStateNormal];
        _btnFriendRequest.tag = 100;
        
    }else{
        _areFriends = YES;
        [_viewNotFriends removeFromSuperview];
        for(UIButton *b in _buttons){
            b.enabled = YES;
            b.alpha = 1;
        }
        
    }
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;

        
        int fontSizeTitle = round(_topImage.height*.15);
        int fontSizeByline = round(_topImage.height*.13);
        
        float ratio = 320.0/150.0;
        _mastheadView.height = self.view.width/ratio + 36;
        _topView.y = _mastheadView.maxY - _topView.height;
        
        _userName.font = [UIFont fontWithName:_userName.font.familyName size:fontSizeTitle];
        _userName.text = [AppController sharedInstance].currentUser.name;
        _userLocation.text = @"user Location";
        _userLocation.font = [UIFont fontWithName:_userLocation.font.familyName size:fontSizeByline];
        
        if([AppController sharedInstance].currentUser.imgData != nil){
            _topImage.image = [[UIImage alloc] initWithData:[AppController sharedInstance].currentUser.imgData];
        }else{
            [_topImage setImageWithURL:[NSURL URLWithString:[AppController sharedInstance].currentUser.img] placeholderImage:[AppController sharedInstance].personImageIcon];
        }
        [self.view addSubview:_btnHitArea];
        
        _bottomView.clipsToBounds = YES;
        _addFriendsHolder.layer.shadowColor = [UIColor colorWithHexString:@"#CCCCCC"].CGColor;
        _addFriendsHolder.layer.shadowOffset = CGSizeMake(0,0);
        _addFriendsHolder.layer.shadowOpacity = 0.5;
        _addFriendsHolder.layer.shadowRadius = 12;
        
        int startingX = 0;
        int count = 0;
        int fontSize = round(_topImage.height*0.09);
        if(fontSize > 17)
            fontSize = 17;
        

        
        for(NSDictionary *dict in _sections){
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, _topView.width/[_sections count], _topView.height)];
            b.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSize];
            [b setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
            b.tag = count;
            b.backgroundColor = [UIColor clearColor];
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
            [b addTarget:self action:@selector(sectionTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            startingX += b.maxX;
            [_topView addSubview:b];
            if(count++ == 0){

                UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(b.width-1, 8, 1, b.height - 16)];
                lb.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
                [b addSubview:lb];
            }
            
    
            
            [_buttons addObject:b];
        }
       

        _bottomView.y = _topView.maxY;
        _bottomView.height = self.view.height - _bottomView.y;
        
        
        [_topView addBottomBorderWithHeight:1 andColor:[UIColor colorWithHexString:@"#2B356F"]];
       
        
        _sectionsHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, _bottomView.height)];
        _sectionsHolder.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        _sectionsHolder.showsHorizontalScrollIndicator = NO;
        
        [_bottomView addSubview:_sectionsHolder];
        [self rebuildBottomSections];
        [self.view addSubview:_topnav.view];
        [self.view addSubview:_btnSettings];
        [self userInfoUpdated];
        
        _highlightOn = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.height-3, 100, 20)];
        _highlightOn.backgroundColor = [UIColor whiteColor];
        _highlightOn.layer.cornerRadius = 35;
        _highlightOn.alpha = 0.8;
        [_topView addSubview:_highlightOn];
        _topView.clipsToBounds = YES;
        
        _btnFriendRequest.layer.cornerRadius = 8;
        
        _highlightOn.x = -_highlightOn.width;
        [self fetchData];
        
        int offset = 50;
        int topOffset = _btnAddFriends.maxY;
        _hintView = [[UIView alloc] initWithFrame:CGRectMake(0, topOffset, [AppController sharedInstance].screenBoundsSize.width, _bottomViewFriends.height - topOffset)];
        _hintView.clipsToBounds = NO;
        _hintView.userInteractionEnabled = NO;
        _hintView.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_GREEN] colorWithAlphaComponent:0];
        UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
        fontSize = roundf(_hintView.width * 0.055);
        msg.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSize];

        msg.text = @"Add friends to coordinate plans and see your friend's suggestions!";
        msg.textColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
        msg.textAlignment = NSTextAlignmentCenter;
        msg.numberOfLines = 5;
        msg.layer.cornerRadius = 8;
        msg.layer.borderColor = [UIColor colorWithHexString:COLOR_CC_GREEN].CGColor;
        msg.layer.borderWidth = 1;
        msg.adjustsFontSizeToFitWidth = YES;
        [msg sizeToFit];
        msg.width = roundf(_hintView.width * 0.70);
        msg.x = roundf(_hintView.width/2 - msg.width/2);
        msg.y = offset;
        [_hintView addSubview:msg];
        
        float distanceFromEdge = roundf(_hintView.width - 29);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(msg.maxX, msg.y + msg.height/2)];
        [path addLineToPoint:CGPointMake(distanceFromEdge, msg.y + msg.height/2)];
        [path addLineToPoint:CGPointMake(distanceFromEdge, -2)];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor colorWithHexString:COLOR_CC_GREEN] CGColor];
        shapeLayer.lineWidth = 1.0;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        [_hintView.layer addSublayer:shapeLayer];
        
        [_bottomViewFriends addSubview:_hintView];
        _hintView.hidden = YES;
        
        if(_isOwner){
            _searchBar.width = _btnAddFriends.x - _searchBar.y;
        }else{
            _searchBar.width = self.view.width - _searchBar.y;
        }
        
        
        
    }else{
        [self rebuildBottomSections];
    }
}


-(void)doHighlighRow:(UIButton *)btn{
    
    UIView *highlightView = [btn viewWithTag:999];
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction animations:^{
        highlightView.alpha = 0.2;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doUnHighlighRow:btn];
        });
    }];
    
}

-(void)doUnHighlighRow:(UIButton *)btn{
    
    UIView *highlightView = [btn viewWithTag:999];
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction animations:^{
        highlightView.alpha = 0;
    } completion:^(BOOL finished) {
        [self resetAllHighlights];
    }];
}

-(void)resetAllHighlights{
    for(UIView *v in _bottomSectionRows){
        UIView *highlightView = [v viewWithTag:999];
        [UIView animateWithDuration:0 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction animations:^{
            highlightView.alpha = 0;
        } completion:^(BOOL finished) {
        }];
    }
}

-(void)rebuildBottomSections{
    _bottomSections = [[NSMutableArray alloc] init];
    
    AppPlan *upcomingPlan = [_thisUser getFirstUpcomingPlanType:AppPlanTypeSure];
    
    if(upcomingPlan){
        [_bottomSections addObject:@{@"img":upcomingPlan.img,@"title":@"Sure Plans", @"byline": upcomingPlan.title,@"icon":@"b"}];
    }else{
        [_bottomSections addObject:@{@"img":[NSString stringWithFormat:@"%@stock/santa-monica.jpg",IMAGE_PATH],@"title":@"Sure Plans", @"byline": @"No Upcoming Plans Yet",@"icon":@"b"}];
        if(!_isOwner){

        }
    }
    
    upcomingPlan = [_thisUser getFirstUpcomingPlanType:AppPlanTypeIf];
    
    if(upcomingPlan){
        [_bottomSections addObject:@{@"img":upcomingPlan.img,@"title":@"If Plans", @"byline": upcomingPlan.title,@"icon":@","}];
    }else{
        [_bottomSections addObject:@{@"img":[NSString stringWithFormat:@"%@stock/boston.jpg",IMAGE_PATH],@"title":@"If Plans", @"byline": @"No Upcoming Plans Yet",@"icon":@","}];
        if(!_isOwner){

        }
    }
    
    [_bottomSections addObject:@{@"img":[NSString stringWithFormat:@"%@stock/seattle.jpg",IMAGE_PATH],@"title":@"Been There, Done That",@"byline": @"My Recommendations", @"icon":@"/"}];
    
    
    
    [_bottomSections addObject:@{@"img":[NSString stringWithFormat:@"%@stock/greece",IMAGE_PATH],@"title":@"Dreaming Of", @"icon":@"d"}];
    [_sectionsHolder removeAllSubviews];
    [_bottomSectionRows removeAllObjects];
    
    int startingY = 0;
    int rowHeight = roundf((_bottomView.height + _bottomView.height * 0.14)/[_bottomSections count]);
    int count = 0;
    
    int fontSizeTitle = round(rowHeight*.18);
    int fontSizeByline = round(rowHeight*.13);

    
    for(NSDictionary *dict in _bottomSections){
        UIButton *row = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _sectionsHolder.width, rowHeight)];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:row.frame];
        [iv setImageWithURL:[NSURL URLWithString:[NSString returnStringObjectForKey:@"img" withDictionary:dict]] placeholderImage:nil];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.alpha = kImageAlpha;
        iv.clipsToBounds = YES;
        [row addSubview:iv];
        
        [row addTarget:self action:@selector(doGoToSection:) forControlEvents:UIControlEventTouchUpInside];
        row.tag = count++;
        
        UILabel *label = [[UILabel alloc] initWithFrame:row.frame];
        label.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSizeTitle];
        label.textColor = [UIColor whiteColor];
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        label.width = row.width;
        label.y = row.height/2 - label.height/2 - label.height/4;
        [row addSubview:label];
        
        THLabel *icon = [[THLabel alloc] initWithFrame:row.frame];
        icon.text = [NSString returnStringObjectForKey:@"icon" withDictionary:dict];
        icon.font = [UIFont fontWithName:FONT_ICONS size:20];
        icon.textColor = [UIColor whiteColor];
        icon.adjustsFontSizeToFitWidth = YES;
        [icon sizeToFit];
        
        icon.y = label.y - icon.height;
        icon.x = row.width/2 - icon.width/2;

        
        UILabel *byline = [[UILabel alloc] initWithFrame:row.frame];
        byline.text = [NSString returnStringObjectForKey:@"byline" withDictionary:dict];
        byline.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSizeByline];
        byline.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
        byline.adjustsFontSizeToFitWidth = YES;
        byline.textAlignment = NSTextAlignmentCenter;
        [byline sizeToFit];
        byline.width = row.width;
        byline.y = label.maxY + 2;
        
        
        [row addTarget:self action:@selector(doHighlighRow:) forControlEvents:UIControlEventTouchDown ];
        [row addTarget:self action:@selector(doUnHighlighRow:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit | UIControlEventTouchDragOutside | UIControlEventTouchUpOutside];
        
        UIView *highlightOnTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, row.width,row.height)];
        highlightOnTapView.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:1];
        highlightOnTapView.userInteractionEnabled = NO;
        [row insertSubview:highlightOnTapView aboveSubview:iv];
        highlightOnTapView.alpha = 0;
        highlightOnTapView.tag = 999;


        [row addSubview:byline];
        
        if([byline.text length] == 0){
            label.y = row.height/2 - label.height/2;
        }
        [_bottomSectionRows addObject:row];
        [_sectionsHolder addSubview:row];
        row.y = startingY;
        startingY += row.height;
    }
    float totalHeight = startingY;
    [_sectionsHolder setContentSize:CGSizeMake(_sectionsHolder.width,totalHeight)];
    [self animateTilesIn];
    
}


-(void)animateTilesIn{
    if(!_doAnimateIn) return;
    _doAnimateIn = NO;
    float delay = 0.2;
    for(UIView *v in _sectionsHolder.subviews){
        v.alpha = 0;
        v.x += 150;
        [UIView animateWithDuration:0.6 delay:delay usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction animations:^{
            v.alpha = 1;
            v.x = 0;
        } completion:^(BOOL finished) {
            
        }];
        
        delay += 0.1;
    }
}


-(void)sectionTapped:(UIButton *)btn{
    
    
    if(btn.selected){
        _highlightOn.hidden = YES;
        btn.selected = NO;
        _tableViewTimeline.hidden = NO;
        _bottomViewFriends.hidden = YES;
        _sectionsHolder.hidden = NO;
        [self searchBarCancelButtonClicked:_searchBar];
        for(UIButton *b in _buttons){
            b.selected = NO;
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
        }
        return;
    }
    
    for(UIButton *b in _buttons){
        b.selected = NO;
        [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
    }
    
    btn.selected = YES;
    [btn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    _highlightOn.hidden = NO;
    
    int idx = (int)btn.tag;
    
   
    [_labelNoActivity removeFromSuperview];
    if(idx == 0){
        _tableViewTimeline.hidden = NO;
        _bottomViewFriends.hidden = YES;
        _sectionsHolder.hidden = YES;
        [self searchBarCancelButtonClicked:_searchBar];
        if([_thisUser.timelineItems count] == 0){
            [_labelNoActivity sizeToFit];
            _labelNoActivity.x = self.view.width/2 - _labelNoActivity.width/2;
            _labelNoActivity.y = self.view.height/2 - _labelNoActivity.height/2;
            [self.view addSubview:_labelNoActivity];
        }else{
            [_labelNoActivity removeFromSuperview];
        }

    }else{
        _tableViewTimeline.hidden = YES;
        _bottomViewFriends.hidden = NO;
        _sectionsHolder.hidden = YES;
    }
    
    _highlightOn.x = btn.x + btn.width/2 - _highlightOn.width/2;

    
}


-(void)doGoToSection:(UIButton *)btn{
    int idx = (int)btn.tag;
    
    switch (idx) {
            
            
        case 0:{
            if(!_blockSurePlan){
                AppPlansViewController *vc = [[AppPlansViewController alloc] initWithNibName:@"AppPlansViewController" bundle:nil];
                vc.planType = AppPlanTypeSure;
                vc.mainContactId = _thisUser.userId;
                [[AppController sharedInstance].navController pushViewController:vc animated:YES];
            }
        }
            break;
            
        case 1:{
            if(!_blockIfPlan){
                AppPlansViewController *vc = [[AppPlansViewController alloc] initWithNibName:@"AppPlansViewController" bundle:nil];
                vc.planType = AppPlanTypeIf;
                vc.mainContactId = _thisUser.userId;
                [[AppController sharedInstance].navController pushViewController:vc animated:YES];
            }
        }
            break;
            
        case 2:{
            AppBeenThereViewController *vc = [[AppBeenThereViewController alloc] initWithNibName:@"AppBeenThereViewController" bundle:nil];
            vc.thisUser = _thisUser;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
            
        case 3:{
            AppDreamingOfViewController *vc = [[AppDreamingOfViewController alloc] initWithNibName:@"AppDreamingOfViewController" bundle:nil];
            vc.mainContactId = _thisUser.userId;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
            
            
        default:
            break;
    }
}





#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView == _tableViewFriends){
        if (_searchActive)
            return [_searchResults count];
            
        return [_thisUser.friends count];
    }

    return [_thisUser.timelineItems count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _tableViewFriends)
        return 65.0;
    
    return 95.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if(tableView == _tableViewFriends){
        
        AppPlansInviteTableViewCell *cell = (AppPlansInviteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppPlansInviteTableViewCell];
        if (cell == nil) {
            cell = [[AppPlansInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppPlansInviteTableViewCell];
        }
        
        AppContact *c;
        
        if (_searchActive){
            c = [_searchResults objectAtIndex:indexPath.row];
        }else{
            c = [_thisUser.friends objectAtIndex:indexPath.row];
        }
        
        cell.showHometown = YES;
        [cell setupWithContact:c andSelected:NO];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.rightButtons = @[];
        
        if(_isOwner){

            cell.rightButtons = @[
                              [MGSwipeButton buttonWithTitle:@"REMOVE\nFRIEND" andIcon:@"h" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:65],
                              [MGSwipeButton buttonWithTitle:@"CHANGE\nGROUP" andIcon:@"o" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:65]
                              ];
            cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }else{

        }
        return cell;
        
    }
    
    
    
    AppActivityTableViewCell *cell = (AppActivityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppActivityTableViewCell];
    if (cell == nil) {
        cell = [[AppActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppActivityTableViewCell];
    }
    
    
    AppActivity *a = [_thisUser.timelineItems objectAtIndex:indexPath.row];
    [cell setupWithActivity:a];
     cell.rightButtons = @[];
    
    if(_isOwner){
        

        if(a.userAcceptRejectOptions){

            cell.rightButtons = @[
                                  [MGSwipeButton buttonWithTitle:@"ACCEPT\nFRIEND" andIcon:@"f" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:95],
                                  [MGSwipeButton buttonWithTitle:@"DENY\nFRIEND" andIcon:@"h" backgroundColor:[UIColor colorWithHexString:COLOR_CC_BLUE] withHeight:95]
                                  ];
            cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }else if(a.userRejectOptions){
            cell.labelSwipe.hidden = YES;
            cell.rightButtons = @[];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
    }else{
        cell.labelSwipe.hidden = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == _tableViewFriends){
        AppContact *c;
        if (_searchActive){
            c = [_searchResults objectAtIndex:indexPath.row];
        }else{
            c = [_thisUser.friends objectAtIndex:indexPath.row];
        }
        
        if([c.userId isEqualToString:_thisUser.userId]){
            return;
        }else if([c.userId isEqualToString:[AppController sharedInstance].currentUser.userId]){
            return;
        }
        
        [[AppController sharedInstance] routeToUserProfile:c.userId];
    }else if(tableView == _tableViewTimeline){
        
        AppActivity *a = [_thisUser.timelineItems objectAtIndex:indexPath.row];
        
        if(a.activityType == AppActivityTypeBTDT){
            
            AppBeenThereDetailViewController *vc = [[AppBeenThereDetailViewController alloc] initWithNibName:@"AppBeenThereDetailViewController" bundle:nil];
            vc.beenThere = a.btItem;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }else if(a.activityType == AppActivityTypeStatic){
            
            
        }else{
        
            if([a.usersId isNotEmpty]){
                if([a.usersId isEqualToString:_thisUser.userId]){
                    return;
                }else if([a.usersId isEqualToString:[AppController sharedInstance].currentUser.userId]){
                    return;
                }
                
                [[AppController sharedInstance] routeToUserProfile:a.usersId];
            }
        }
    }else{
        

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
        [_tableViewFriends reloadData];
    }else{
        
        NSPredicate *p = [NSPredicate predicateWithFormat:@"( (name BEGINSWITH[cd] %@) OR (name CONTAINS[cd] %@) OR (lastName BEGINSWITH[cd] %@) OR (firstName BEGINSWITH[cd] %@))", searchText,[NSString stringWithFormat:@" %@",searchText],searchText,searchText];

        _searchResults = [NSMutableArray arrayWithArray:[_thisUser.friends filteredArrayUsingPredicate:p]];
        [_tableViewFriends reloadData];
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [[AppController sharedInstance] hideKeyboard];
    _searchBar.text = @"";
    _searchActive = NO;
    [_tableViewFriends reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

}








-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    _activityInQuestion = nil;
    
    if(!_tableViewTimeline.hidden){
        _pathInQuestion = [_tableViewTimeline indexPathForCell:cell];
        _activityInQuestion = [_thisUser.timelineItems objectAtIndex:_pathInQuestion.row];
    }else{
        _pathInQuestion = [_tableViewFriends indexPathForCell:cell];
    }
    
    
    
    if(_activityInQuestion.userAcceptRejectOptions){
        
        
        if(index == 1) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to deny this friend request?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
            alert.tag = 38;
            [alert show];
            return NO;
        }else if(index == 0) {
            
                NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
                [dict setObject:_activityInQuestion.usersId forKey:@"user_id"];
                [dict setObject:@"Y" forKey:@"accept"];
            
                _activityInQuestion.line2 = @"Accepted friend request";
                _activityInQuestion.userAcceptRejectOptions = NO;
                _activityInQuestion.userRejectOptions = YES;

                [_tableViewTimeline reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationRight];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
                [manager POST:[AppAPIBuilder APIForUpdateFriendToFriend:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    responseObject = [VTUtils processResponse:responseObject];
                    if([VTUtils isResponseSuccessful:responseObject]){
                        
                        [[AppController sharedInstance].currentUser refreshUserDataFromServer];
                    }else{
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                }];
        }
    }else if(_activityInQuestion.userRejectOptions){
        
        if(index == 0) {
            return NO;
        }
    }else{
        
        
        if(index == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to remove this friend?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove",nil];
            alert.tag = 32;
            [alert show];
            return NO;
        }else if(index == 1) {
            AppCustomGroupsViewController *vc = [[AppCustomGroupsViewController alloc] initWithNibName:@"AppCustomGroupsViewController" bundle:nil];
            if (_searchActive){
                vc.contact = [_searchResults objectAtIndex:_pathInQuestion.row];
            }else{
                vc.contact = [_thisUser.friends objectAtIndex:_pathInQuestion.row];
            }
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
    }
    return YES;
}

-(void)checkfriendsView{
    if([_thisUser.friends count] == 0){
        _labelNoFriends.hidden = YES;
        _hintView.hidden = NO;
        _searchBar.hidden = YES;
    }else{
        _labelNoFriends.hidden = YES;
         _hintView.hidden = YES;
        _searchBar.hidden = NO;

    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    int idx =(int)buttonIndex;
    if(alertView.tag == 33){
        if(idx == 1){
            
        }
    }else if(alertView.tag == 32 || alertView.tag == 38){
        if(idx == 1){
            
            if (_searchActive){
                AppContact *c = [_searchResults objectAtIndex:_pathInQuestion.row];
                [_searchResults removeObjectAtIndex:_pathInQuestion.row];
                [_thisUser.friends removeObject:c];
                [_tableViewFriends deleteRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationLeft];
                
            }else{
                NSString *userId;
                UITableView *tv;
                if(alertView.tag == 38){
                    userId = _activityInQuestion.usersId;
                    tv = _tableViewTimeline;
                }else{
                    AppContact *c = [_thisUser.friends objectAtIndex:_pathInQuestion.row];
                    userId = c.userId;
                    tv = _tableViewFriends;
                }
                

                
                [self checkfriendsView];
                
                NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
                [dict setObject:userId forKey:@"user_id"];
                [dict setObject:@"N" forKey:@"accept"];
                
                [tv reloadRowsAtIndexPaths:@[_pathInQuestion] withRowAnimation:UITableViewRowAnimationLeft];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
                [manager POST:[AppAPIBuilder APIForUpdateFriendToFriend:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    responseObject = [VTUtils processResponse:responseObject];
                    if([VTUtils isResponseSuccessful:responseObject]){
                        [[AppController sharedInstance].currentUser refreshUserDataFromServer];
                    }else{
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
                    
        
            }
        }
    }

}



































- (IBAction)doLogoPressed {
    [[AppController sharedInstance] goBack];
}

- (IBAction)doSettings {
    AppSettingsViewController *vc = [[AppSettingsViewController alloc] initWithNibName:@"AppSettingsViewController" bundle:nil];
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

- (IBAction)doAddFriends{
    
    AppFindFriendViewController *vc = [[AppFindFriendViewController alloc] initWithNibName:@"AppFindFriendViewController" bundle:nil];
    vc.fromProfile = YES;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    

}




- (IBAction)doPhotoLargerView{

    
    if(!_isOwner){
        if(!_areFriends) return;
    }
    
    
        AppProfileDetailsViewController *vc = [[AppProfileDetailsViewController alloc] initWithNibName:@"AppProfileDetailsViewController" bundle:nil];
        vc.mainContactId = _thisUser.userId;
        vc.thisUser = _thisUser;
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    

}


- (IBAction)doChangeBackground {
    if(!_imagePicker){
        _imagePicker = [[VTImagePicker alloc] init];
        _imagePicker.delegateViewController = self;
    }
    [_imagePicker presentPhotoPicker];
}

- (IBAction)doSendFriendRequest {
    
    if(_btnFriendRequest.tag == 100){
        
        NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
        [dict setObject:_thisUser.userId forKey:@"user_id"];
        [dict setObject:@"Y" forKey:@"accept"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [manager POST:[AppAPIBuilder APIForUpdateFriendToFriend:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            responseObject = [VTUtils processResponse:responseObject];
            if([VTUtils isResponseSuccessful:responseObject]){
                [self fetchData];
            }else{
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
        return;
        
        
    }
    
    [_btnFriendRequest setTitle:@"Friend Request Sent" forState:UIControlStateNormal];
    [_btnFriendRequest setTitleColor:_btnFriendRequest.backgroundColor forState:UIControlStateNormal];
    _btnFriendRequest.backgroundColor = [UIColor whiteColor];
    _btnFriendRequest.enabled = NO;
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    NSString *based = _thisUser.userId;
    [dict setObject:[NSString base64Encode:based] forKey:@"ids"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForPairFriends:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){

        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}



- (void)imagePickedForAvatarPreview:(UIImage *)image{
    _topImage.image = image;
}

- (void)imagePickedForAvatar:(UIImage *)image{
    


}



- (void)keyboardWillShow:(NSNotification*)aNotification{
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _tableViewFriends.height = _bottomViewFriends.height - _tableViewFriends.y - kbSize.height;
                         
                     } completion:^(BOOL finished) {}];
    
}

-(void)keyboardWillHide:(NSNotification*)aNotification{
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _tableViewFriends.height = _bottomViewFriends.height - _tableViewFriends.y;
                         
                     } completion:^(BOOL finished) {}];
    
    
}




@end
