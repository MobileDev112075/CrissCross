//
//  AppFriendsInCityTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppFriendsInCityTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;


-(void)setupWithContact:(AppContact *)contact;

@end
