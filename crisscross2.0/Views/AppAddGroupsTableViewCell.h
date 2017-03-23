//
//  AppAddGroupsTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MGSwipeTableCell.h"
#import "AppContact.h"

@interface AppAddGroupsTableViewCell : MGSwipeTableCell

@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemByline;
@property (strong, nonatomic) IBOutlet UILabel *divLine;

-(void)setupWithContact:(AppContact *)contact;

@end
