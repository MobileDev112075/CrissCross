//
//  AppPlansInviteTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/24/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface AppPlansInviteTableViewCell : MGSwipeTableCell{
    UIButton *_hitarea;
    AppContact *_contact;
}
@property (strong, nonatomic) IBOutlet UILabel *labelCheckOff;
@property (strong, nonatomic) IBOutlet UILabel *labelCheckOn;
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemTextRight;
@property (assign, nonatomic) BOOL showHometown;
@property (assign, nonatomic) BOOL showTapToAdd;
@property (strong, nonatomic) IBOutlet UILabel *tapToAdd;

-(void)showMinimal;
@property (strong, nonatomic) IBOutlet UILabel *bottomLine;

-(void)setupWithContact:(AppContact *)contact andSelected:(BOOL)selected;

@end
