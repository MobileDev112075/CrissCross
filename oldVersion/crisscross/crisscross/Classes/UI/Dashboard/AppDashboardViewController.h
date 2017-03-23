//
//  AppDashboardViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/18/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import "AppWelcomeViewController.h"
#import "AppUserProfileViewController.h"

@interface AppDashboardViewController : AppViewController<UIScrollViewDelegate>{

    AppWelcomeViewController *_welcomeVC;
    NSArray *_sections;
    UIScrollView *_sectionsHolder;
    UIButton *_theUserButton;
    
    CGFloat                         _previousVerticalVelocity;
    UITapGestureRecognizer          *_tapGestureRecognizer;
    UILongPressGestureRecognizer    *_longPressGestureRecognizer;
    UIPanGestureRecognizer          *_panGestureRecognizer;
    CGFloat                         _verticalVelocity;
    UIButton *_activityViewBtn;
    UIView *_activityViewBg;
    NSTimer *_timerActivity;
    
    
    UIView *_imageCropCurtain;
    UIScrollView *_imageCropScrollView;
    UIImageView *_imageCropImageView;
    
    CCButton *_btnCC;
    
    
    
}

@property (strong, nonatomic) IBOutlet UIButton *btnTemp;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
