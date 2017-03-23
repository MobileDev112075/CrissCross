//
//  AppAddFriendsInterstitialViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppAddFriendsInterstitialViewController : AppViewController
@property (strong, nonatomic) IBOutlet THLabel *logo;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;

@property (assign, nonatomic) int totalAdded;
@property (assign, nonatomic) BOOL skipGroups;
- (IBAction)doContinue;

@end
