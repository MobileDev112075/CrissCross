//
//  AppMyPlansTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 5/4/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface AppMyPlansTableViewCell : MGSwipeTableCell{
    AppPlan *_plan;
}
@property (strong, nonatomic) IBOutlet THLabel *labelIcon;
@property (strong, nonatomic) IBOutlet UILabel *fromNumber;
@property (strong, nonatomic) IBOutlet UILabel *fromDate;
@property (strong, nonatomic) IBOutlet UILabel *toNumber;
@property (strong, nonatomic) IBOutlet UILabel *toDate;
@property (strong, nonatomic) IBOutlet UILabel *sureIf;
@property (strong, nonatomic) IBOutlet UILabel *planTitle;

-(void)setupWithPlan:(AppPlan *)plan;

@end
