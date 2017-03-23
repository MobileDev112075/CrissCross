//
//  AppViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
//#import "GAI.h"
//#import "GAITracker.h"
//#import "GAIDictionaryBuilder.h"
//#import "GAIFields.h"

@interface AppViewController ()

@end

@implementation AppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _topnav = [[AppTopNavViewController alloc] initWithNibName:@"AppTopNavViewController" bundle:nil];
//    [self.view addSubview:_topnav.view];
//    _canLeaveWithSwipe = YES;
      self.view.clipsToBounds = YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//- (void)wantsToLeaveWithSwipe{
//    if(_canLeaveWithSwipe)
//        [[AppController sharedInstance].navController popViewControllerAnimated:YES];
//}


@end
