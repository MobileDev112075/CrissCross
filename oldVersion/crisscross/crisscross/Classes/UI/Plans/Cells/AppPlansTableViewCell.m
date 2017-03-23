//
//  AppPlansTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppPlansTableViewCell.h"



@implementation AppPlansTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    _conflictLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _conflictLabel.text = @"8";
    _conflictLabel.font = [UIFont fontWithName:FONT_ICONS size:22];
    _conflictLabel.textColor = [UIColor redColor];
    [_conflictLabel sizeToFit];
    [self.contentView addSubview:_conflictLabel];
    
    _conflictLabelByline = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    _conflictLabelByline.text = @"CONFLICT\nSWIPE TO EDIT";
    _conflictLabelByline.textAlignment = NSTextAlignmentCenter;
    _conflictLabelByline.numberOfLines = 2;
    _conflictLabelByline.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:8];
    _conflictLabelByline.textColor = [UIColor redColor];
    [_conflictLabelByline sizeToFit];
    _conflictLabelByline.x = roundf([AppController sharedInstance].screenBoundsSize.width - _conflictLabelByline.width - 10);
    [self.contentView addSubview:_conflictLabelByline];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupWithPlan:(AppPlan *)plan andSelected:(BOOL)selected isOwner:(BOOL)owner{
    
    _itemTitle.text = plan.title;
    _itemCountTitle.text = plan.dayNum;
    _itemByline.text = plan.byline;
    
    
    if(selected){
        _itemByline.text = @"PLANNING ON BEING THERE";
        if([plan.overlappedUsers count] == 1){
            _itemTitle.text = @"1 PERSON";
        }else{
            _itemTitle.text = [NSString stringWithFormat:@"%d PEOPLE",(int)[plan.overlappedUsers count]];
        }
        _itemTitle.textColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
    }else{
        _itemTitle.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    }
    
    if(owner && plan.markAsConflict){
        _conflictLabel.hidden = NO;
        _conflictLabelByline.hidden = NO;
        _swipeText.hidden = YES;
        
        _conflictLabelByline.y = roundf(self.contentView.height/2);
        _conflictLabel.x = roundf(_conflictLabelByline.x + (_conflictLabelByline.width/2 - _conflictLabel.width/2));
        _conflictLabel.y = roundf(_conflictLabelByline.y - _conflictLabel.height);
        
    }else{
        _swipeText.hidden = NO;
        _conflictLabel.hidden = YES;
        _conflictLabelByline.hidden = YES;
    }

    
    
}



@end
