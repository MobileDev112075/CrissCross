//
//  AppAddCustomGroupTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/22/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface AppAddCustomGroupTableViewCell : MGSwipeTableCell{

    UILabel *_iconCircleBg;
    UILabel *_byline;
    AppGroup *_group;
    
    UILabel *_iconStone;
    
}
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemExtraTitle;

@property (strong, nonatomic) IBOutlet UILabel *swipeMessage;
@property (strong, nonatomic) IBOutlet UILabel *divLine;

-(void)setupWithGroup:(AppGroup *)group andSelected:(BOOL)selected;

@end
