//
//  AppAddCustomGroupTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/22/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppAddCustomGroupTableViewCell.h"
#import "AppConstants.h"
#import "UIView+Additions.h"
#import "UIColor+Additions.h"

@implementation AppAddCustomGroupTableViewCell

- (void)awakeFromNib {
    
    _byline = [[UILabel alloc] init];
    _byline.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
    _iconCircleBg = [[UILabel alloc] init];
    _iconCircleBg.backgroundColor = [UIColor clearColor];
    _iconCircleBg.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
    _iconCircleBg.layer.borderWidth = 2;
    _iconCircleBg.textColor = [UIColor whiteColor];
    _iconCircleBg.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_iconCircleBg];
    
    _iconStone = [[UILabel alloc] init];
    _iconStone.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
    _iconStone.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_iconStone];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setupWithGroup:(AppGroup *)group andSelected:(BOOL)selected{

    _group = group;

    if(group.isTopBlock){
        _itemExtraTitle.hidden = NO;
        _itemTitle.hidden = YES;
        _itemExtraTitle.text = group.title;
        _swipeMessage.hidden = YES;
    }else{
        _itemTitle.hidden = NO;
        _itemExtraTitle.hidden = YES;
        _itemTitle.text = group.title;
        _swipeMessage.hidden = NO;

        if(selected){
            _iconCircleBg.backgroundColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
            _iconCircleBg.text = @"3";
        }else{
            _iconCircleBg.backgroundColor = [UIColor clearColor];
            _iconCircleBg.text = @"";
        }
        
        if(group.isManageView){
            _itemTitle.x = 20;
            _iconCircleBg.hidden = YES;
        }else{
            _iconCircleBg.hidden = NO;
        }
    }
    _itemTitle.adjustsFontSizeToFitWidth = NO;
    [_byline removeFromSuperview];
    _iconStone.hidden = YES;

    
    
    if((1)){
        self.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        _itemTitle.textColor = [UIColor whiteColor];
        _iconCircleBg.font = [UIFont fontWithName:FONT_ICONS size:14];
        
        if([_group.groupId isEqualToString:@"STONE"]){
            _swipeMessage.hidden = YES;
            _iconStone.hidden = NO;
        }
        
        [self.contentView addSubview:_byline];
        _divLine.alpha = 0.2;
    }
    
    
    if(group.isAll){
        
    }
    [self adjustAfter];
       
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustAfter];
    });

}

-(void)adjustAfter{
    
    int fontSizeTitle = round(self.height*.28);
    _itemTitle.font = [UIFont fontWithName:_itemTitle.font.familyName size:fontSizeTitle];
    _itemTitle.width = roundf(_swipeMessage.x - _itemTitle.x);
    [_itemTitle sizeToFit];
    _itemTitle.width = roundf(_swipeMessage.x - _itemTitle.x);
    _itemExtraTitle.font = [UIFont fontWithName:_itemExtraTitle.font.familyName size:round(self.height*.20)];
    _divLine.y = self.height - 1;

    
    if((1)){
        _iconCircleBg.width = _iconCircleBg.height  = 26;
        _iconCircleBg.layer.cornerRadius = _iconCircleBg.width/2;
        _iconCircleBg.clipsToBounds = YES;
        
        _itemTitle.y = roundf(self.contentView.height/2 - _itemTitle.height);
        
        _iconCircleBg.y = roundf(self.contentView.height/2 - _iconCircleBg.height/2);
        _iconCircleBg.x = 15;
        
        _byline.x = _itemTitle.x;
        _byline.font = [UIFont fontWithName:_itemTitle.font.familyName size:fontSizeTitle - 6];
        _byline.text = [NSString stringWithFormat:@"%d Friend%@",(int)[_group.usersIds count],[_group.usersIds count] == 1 ? @"" : @"s"];
        _byline.width = roundf(_swipeMessage.x - _byline.x);
        _byline.height = 20;
        _byline.y = roundf(self.contentView.height/2);
        
        _iconStone.frame = CGRectMake(0, 0, roundf(self.contentView.height), roundf(self.contentView.height));
        _iconStone.font = [UIFont fontWithName:FONT_ICONS size:MIN(roundf(self.contentView.height * 0.50),30)];
        _iconStone.text = @"i";
        _iconStone.x = roundf(self.contentView.width - _iconStone.width - 8);
    }
    
}






@end
