//
//  AppAddFriendsInterstitialViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppAddFriendsInterstitialViewController.h"
#import "AppAddGroupsViewController.h"

@interface AppAddFriendsInterstitialViewController ()

@end

@implementation AppAddFriendsInterstitialViewController

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
        
        _topnav.theTitle.text = @"Find Your Friends";
        _topnav.btnBack.hidden = YES;
        _topnav.view.backgroundColor = [UIColor clearColor];
        [_logo sizeToFit];
        _logo.height += 2;
        _logo.x = self.view.width/2 - _logo.width/2;
        _topLabel.text = [NSString stringWithFormat:@"Friends Added"];
    }
}


- (IBAction)doContinue {
    if(_skipGroups){
        [[AppController sharedInstance] routeToDashboard];
    }else{
        AppAddGroupsViewController *vc = [[AppAddGroupsViewController alloc] initWithNibName:@"AppAddGroupsViewController" bundle:nil];
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    }
}

@end
