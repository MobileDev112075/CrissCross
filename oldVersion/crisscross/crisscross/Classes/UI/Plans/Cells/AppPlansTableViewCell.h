//
//  AppPlansTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface AppPlansTableViewCell : MGSwipeTableCell{
    UILabel *_conflictLabel;
    UILabel *_conflictLabelByline;
}

@property (strong, nonatomic) IBOutlet UILabel *itemCountTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UILabel *itemByline;
@property (strong, nonatomic) IBOutlet UILabel *swipeText;

-(void)setupWithPlan:(AppPlan *)plan andSelected:(BOOL)selected isOwner:(BOOL)owner;



@end
