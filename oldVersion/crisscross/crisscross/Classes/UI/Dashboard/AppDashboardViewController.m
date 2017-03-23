//
//  AppDashboardViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/18/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppDashboardViewController.h"
#import "AppPlanPlanViewController.h"
#import "AppFindViewController.h"
#import "AppActivityViewController.h"

#import "AppDreamingOfViewController.h"
#import "AppPlansViewController.h"
#import "AppPlanAddViewController.h"
#import "AppBeenThereViewController.h"
#import "AppAddGroupsViewController.h"


#import "AppUserProfileViewController.h"
#import "AppMyPlansViewController.h"
#import "AppBeenThereDetailViewController.h"
#import "AppSettingsViewController.h"
#import "AppDashboardTableViewCell.h"
#import "AppCustomGroupsViewController.h"
#import "AppFindFriendViewController.h"
#import <Crashlytics/Crashlytics.h>

//#import "AppsFlyerTracker.h"

@interface AppDashboardViewController ()

@end

@implementation AppDashboardViewController

-(void)viewDidLoad{
    [super viewDidLoad];
  

    _sections = @[
                  @{@"img":[NSString stringWithFormat:@"%@stock/ticket.jpg",IMAGE_PATH],@"title":@"Plan Your Plan", @"byline": @"Plan a trip, Cross with friends",@"icon":@"z"},
                  @{@"img":[NSString stringWithFormat:@"%@stock/nyc.jpg",IMAGE_PATH],@"title":@"Activity", @"byline": @"Recent Updates, Travel Tracker",@"icon":@"x",@"isActivity":@"Y"},
                  @{@"img":[NSString stringWithFormat:@"%@stock/seattle.jpg",IMAGE_PATH],@"title":@"Been There Done That", @"byline": @"Friends Recommendations",@"icon":@"/"},
                  @{@"img":[AppController sharedInstance].currentUser.img,@"title":@"My Profile", @"byline": [AppController sharedInstance].currentUser.name,@"icon":@"c",@"isUser":@"Y"},
                  @{@"img":[NSString stringWithFormat:@"%@stock/map.jpg",IMAGE_PATH],@"title":@"Find", @"byline": @"Friends, plans, and more",@"icon":@"v"}
                  ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated:) name:NOTIFICATION_USER_INFO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:NOTIFICATION_ENTERED_FOREGROUND object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateTilesIn) name:NOTIFICATION_DASH_ANIMATE_IN object:nil];
    self.canLeaveWithSwipe = NO;

    self.automaticallyAdjustsScrollViewInsets = NO;

    
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)layoutUI{
    
    _activityViewBg.alpha = 0;
    
    if(!_didLayout){
    
        _didLayout = YES;
        

        
        _welcomeVC = [[AppWelcomeViewController alloc] initWithNibName:@"AppWelcomeViewController" bundle:nil];
        _welcomeVC.view.width = self.view.width;
        _welcomeVC.view.height = self.view.height;

        
        [_topnav.view removeFromSuperview];
        

        _sectionsHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _sectionsHolder.bounces = YES;
        _sectionsHolder.showsVerticalScrollIndicator = NO;
        _sectionsHolder.showsHorizontalScrollIndicator = NO;
        _sectionsHolder.delegate = self;
        
        [self.view addSubview:_sectionsHolder];
        int startingY = 0;
        int rowHeight = roundf((self.view.height + self.view.height * 0.12)/[_sections count]);
        int count = 0;
        
        int fontSizeTitle = round(rowHeight*.18);
        int fontSizeByline = round(rowHeight*.11);
        
        for(NSDictionary *dict in _sections){
            UIButton *row = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _sectionsHolder.width, rowHeight)];
            UIImageView *iv = [[UIImageView alloc] initWithFrame:row.frame];
            [iv setImageWithURL:[NSURL URLWithString:[NSString returnStringObjectForKey:@"img" withDictionary:dict]] placeholderImage:nil];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            
            iv.tag = 100;
            
            iv.alpha = kImageAlpha;
            iv.clipsToBounds = YES;
            [row addSubview:iv];
            
            [row addTarget:self action:@selector(doGoToSection:) forControlEvents:UIControlEventTouchUpInside];
            [row addTarget:self action:@selector(doHighlighRow:) forControlEvents:UIControlEventTouchDown ];
            [row addTarget:self action:@selector(doUnHighlighRow:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit | UIControlEventTouchDragOutside];
            row.tag = count++;
            
            UILabel *label = [[UILabel alloc] initWithFrame:row.frame];
            label.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
            label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSizeTitle];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            [label sizeToFit];
            label.width = row.width;
            label.y = row.height/2 - label.height/2 - label.height/4;
            label.tag = 99;
            [row addSubview:label];
            
            
            UILabel *byline = [[UILabel alloc] initWithFrame:row.frame];
            byline.text = [NSString returnStringObjectForKey:@"byline" withDictionary:dict];
            byline.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSizeByline];
            byline.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
            byline.adjustsFontSizeToFitWidth = YES;
            [byline sizeToFit];
            byline.textAlignment = NSTextAlignmentCenter;
            byline.width = row.width;
            byline.tag = 98;
            byline.y = label.maxY + 2;
            [row addSubview:byline];
            
            if([[NSString returnStringObjectForKey:@"isActivity" withDictionary:dict] isEqualToString:@"Y"]){
                _activityViewBtn = row;
                
                _activityViewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, row.width,row.height)];
                _activityViewBg.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:1];
                _activityViewBg.userInteractionEnabled = NO;
                [row insertSubview:_activityViewBg aboveSubview:iv];
                _activityViewBg.alpha = 0;
            }
            
            
            UIView *highlightOnTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, row.width,row.height)];
            highlightOnTapView.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:1];
            highlightOnTapView.userInteractionEnabled = NO;
            [row insertSubview:highlightOnTapView aboveSubview:iv];
            highlightOnTapView.alpha = 0;
            highlightOnTapView.tag = 999;
            
            
            [_sectionsHolder addSubview:row];
            row.y = startingY;
            startingY += row.height;
            if([[NSString returnStringObjectForKey:@"isUser" withDictionary:dict] isEqualToString:@"Y"]){
                _theUserButton = row;
            }

            
        }
        float newHeight = count * rowHeight;
        [self.view addSubview:_welcomeVC.view];
        [_welcomeVC doLayout];
        
        [_sectionsHolder setContentSize:CGSizeMake(_sectionsHolder.width,newHeight)];

        UILabel *personImageIcon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        personImageIcon.text = @"p";
        personImageIcon.font = [UIFont fontWithName:FONT_ICONS size:200];
        personImageIcon.textColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2];
        [personImageIcon sizeToFit];
        personImageIcon.width += 140;
        personImageIcon.height += 140;
        personImageIcon.textAlignment = NSTextAlignmentCenter;
        UIGraphicsBeginImageContext(personImageIcon.bounds.size);
        [personImageIcon.layer renderInContext:UIGraphicsGetCurrentContext()];
        [AppController sharedInstance].personImageIcon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        _btnCC = [[CCButton alloc] initWithFrame:CGRectMake(0, 18, 70, 70)];
        _btnCC.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:32];
        [_btnCC setTitle:@"1" forState:UIControlStateNormal];
        [_btnCC addTarget:self action:@selector(doShowWelcomeScreen) forControlEvents:UIControlEventTouchUpInside];
        [_btnCC resetDefaults];
        [self.view insertSubview:_btnCC belowSubview:_welcomeVC.view];
        
        
//        [[AppsFlyerTracker sharedTracker] setUserEmails:@[[AppController sharedInstance].currentUser.email] withCryptType:EmailCryptTypeSHA1];
    }
}

-(void)doShowWelcomeScreen{
    [self.view addSubview:_welcomeVC.view];
    _welcomeVC.view.x = _welcomeVC.view.y = 0;
    [_welcomeVC appEnteredForeground];
    [_welcomeVC doLayout];
    _welcomeVC.view.x = self.view.width;
    _welcomeVC.view.y = 0;
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _welcomeVC.view.x = 0;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    for(UIView *v in _sectionsHolder.subviews){
        UIView *highlightView = [v viewWithTag:999];
        highlightView.alpha = 0;
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
    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkIfActivityShouldBlink];
}

-(void)checkIfActivityShouldBlink{
    [_timerActivity invalidate];
    _activityViewBg.alpha = 0;
    if([AppController sharedInstance].currentUser.hasNewActivity || [UIApplication sharedApplication].applicationIconBadgeNumber > 0 ){
        _timerActivity = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(fadeInAndOut) userInfo:nil repeats:YES];
    }
}

-(void)fadeInAndOut{
    float newAlpha = 0.1;
    if(_activityViewBg.alpha >= 0.1){
        newAlpha = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        _activityViewBg.alpha = newAlpha;
    } completion:^(BOOL finished) {
        
    }];
}


-(void)animateTilesIn{
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

-(void)appEnteredForeground{
    
    if((1)) return;
    
    float diff = [[NSDate date] timeIntervalSince1970] - [AppController sharedInstance].startedBackgroundTime;
    
    if(fabsf(diff) > 60){
        for(UIViewController *vc in [AppController sharedInstance].navController.viewControllers){
            if([vc isKindOfClass:[self class]]){
                [[AppController sharedInstance].navController popToViewController:vc animated:NO];
            }
        }
        

            [self.view addSubview:_welcomeVC.view];
            _welcomeVC.view.x = _welcomeVC.view.y = 0;
            [_welcomeVC appEnteredForeground];
            [_welcomeVC doLayout];

    }
}



-(void)userInfoUpdated:(NSNotification *)note{
    
    for(UIView *v in _theUserButton.subviews){
        if(v.tag == 100){
            UIImageView *iv = (UIImageView *)v;
            if([AppController sharedInstance].currentUser.imgData != nil){
                iv.image = [[UIImage alloc] initWithData:[AppController sharedInstance].currentUser.imgData];
            }else{
                [iv setImageWithURL:[NSURL URLWithString:[AppController sharedInstance].currentUser.img] placeholderImage:[AppController sharedInstance].personImageIcon];
            }
        }else if(v.tag == 98){
            UILabel *iv = (UILabel *)v;
            iv.width = self.view.width;
            iv.text = [AppController sharedInstance].currentUser.name;
            [iv sizeToFit];
            iv.x = self.view.width/2 - iv.width/2;
        }
    }
}

-(void)doGoToSection:(UIButton *)btn{
    int idx = (int)btn.tag;
    
    switch (idx) {
        case 0:{
            AppPlanPlanViewController *vc = [[AppPlanPlanViewController alloc] initWithNibName:@"AppPlanPlanViewController" bundle:nil];
            vc.doAnimateIn = YES;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
        
        case 1:{
            AppActivityViewController *vc = [[AppActivityViewController alloc] initWithNibName:@"AppActivityViewController" bundle:nil];
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
            [AppController sharedInstance].currentUser.hasNewActivity = NO;
            [_timerActivity invalidate];
            _activityViewBg.alpha = 0;
        }
            break;
        case 2:{
            AppBeenThereViewController *vc = [[AppBeenThereViewController alloc] initWithNibName:@"AppBeenThereViewController" bundle:nil];
            vc.thisUser = [AppController sharedInstance].currentUser;
            vc.communityView = YES;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
        case 3:{
            [[AppController sharedInstance] routeToUserProfile:nil];
        }
            break;
        case 4:{
            AppFindViewController *vc = [[AppFindViewController alloc] initWithNibName:@"AppFindViewController" bundle:nil];
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
        
        default:
            break;
    }
}



@end
