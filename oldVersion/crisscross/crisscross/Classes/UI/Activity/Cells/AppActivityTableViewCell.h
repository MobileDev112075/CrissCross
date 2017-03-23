//
//  AppActivityTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppActivityTableViewCell : MGSwipeTableCell{
    UIImageView *_cityBgImageView;
    UIButton *_citySuggestionsBtn;
    UIButton *_cityFriendsBtn;
    
    UILabel *_thinLine1;
    UILabel *_thinLine2;
    
    AppActivity *_activity;
}

@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemDescription;
@property (strong, nonatomic) IBOutlet UILabel *lineOne;
@property (strong, nonatomic) IBOutlet UILabel *lineTwo;
@property (strong, nonatomic) IBOutlet THLabel *itemTimeAgo;
@property (strong, nonatomic) IBOutlet UILabel *labelSwipe;
@property (strong, nonatomic) AppActivity *theActivity;

@property (assign, nonatomic) BOOL cellTypeTracker;

-(void)setupWithActivity:(AppActivity *)activity;

@end
