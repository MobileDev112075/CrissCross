//
//  AppContactsTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THLabel.h"
#import "AppContact.h"


@interface AppContactsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *itemTitle;

@property (strong, nonatomic) IBOutlet THLabel *iconAdd;
@property (strong, nonatomic) IBOutlet THLabel *iconEmail;
@property (strong, nonatomic) IBOutlet UILabel *iconCheckmark;
@property (strong, nonatomic) IBOutlet UILabel *itemByline;

-(void)setupWithContact:(AppContact *)contact andSelected:(BOOL)selected;
@end
