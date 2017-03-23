//
//  AppMyPlansTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 5/4/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppMyPlansTableViewCell.h"

@implementation AppMyPlansTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setupWithPlan:(AppPlan *)plan{
    
    _plan = plan;
    _planTitle.text = plan.title;
    _planTitle.adjustsFontSizeToFitWidth = YES;
    
    _fromNumber.text = plan.dayNum;
    _toNumber.text = plan.dayNumEnd;

    _fromDate.text = plan.dateTitleStart;
    _toDate.text = plan.dateTitleEnd;
    
    if(_plan.planType == AppPlanTypeIf){
        _sureIf.text = @"If";
        _labelIcon.text = @",";
    }else{
        _sureIf.text = @"Sure";
        _labelIcon.text = @"b";
    }

    
}

@end
