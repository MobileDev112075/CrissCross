//
//  AppPlansInviteTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/24/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppPlansInviteTableViewCell.h"
#import "UIView+Additions.h"
#import "UIColor+Additions.h"
#import "AppConstants.h"

@implementation AppPlansInviteTableViewCell

- (void)awakeFromNib {
    _itemImage.layer.cornerRadius = roundf(_itemImage.width/2);
    _itemImage.layer.borderWidth = 1;
    _itemImage.layer.borderColor = [[UIColor colorWithHexString:@"CCCCCC"] colorWithAlphaComponent:0.3].CGColor;
    _itemImage.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupWithContact:(AppContact *)contact andSelected:(BOOL)selected{
    _contact = contact;
    _tapToAdd.hidden = YES;
//    [_itemImage cancelImageRequestOperation];
//    [_itemImage setImageWithURL:[NSURL URLWithString:contact.img] placeholderImage:[AppController sharedInstance].personImageIcon];
    _itemTitle.text = contact.name;
    _itemTextRight.hidden = NO;
    
    if(selected){
        _labelCheckOff.hidden = YES;
        _labelCheckOn.hidden = NO;
    }else{
        _labelCheckOn.hidden = YES;
        _labelCheckOff.hidden = NO;
    }
    
    if(_showTapToAdd){
         _tapToAdd.hidden = NO;
    }
    
    if(_showHometown){
        _itemTextRight.hidden = NO;
        _itemTextRight.text = _contact.showCity;
        _itemTextRight.alpha = 0.6;
        _itemTextRight.textAlignment = NSTextAlignmentLeft;
        _itemTextRight.adjustsFontSizeToFitWidth = YES;
        _labelCheckOff.hidden = _labelCheckOn.hidden = YES;
        _itemTextRight.width = roundf(self.contentView.width - _itemTitle.width - 10);

        [_itemTitle sizeToFit];
        if([_contact.showCity length] == 0){
            _itemTitle.y = roundf(self.contentView.height/2 - _itemTitle.height/2);
            _itemTextRight.hidden = YES;
        }else{
            _itemTitle.y = roundf(self.contentView.height/2 - _itemTitle.height);
            _itemTextRight.y = roundf(self.contentView.height/2);
            _itemTextRight.x = roundf(_itemTitle.x);
        }
    }else{
        _itemTextRight.hidden = YES;
    }
    [self adjustLayout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustLayout];
    });
}

-(void)showMinimal{
    _hitarea = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, self.contentView.height)];
    _labelCheckOn.hidden = _labelCheckOff.hidden = YES;
    _itemTextRight.hidden = YES;
    _itemTitle.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    [self.contentView addSubview:_hitarea];
    [_hitarea addTarget:self action:@selector(doTap) forControlEvents:UIControlEventTouchUpInside];
    [self adjustLayout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustLayout];
    });
}

-(void)adjustLayout{
    _bottomLine.y = roundf(self.contentView.height - 1);
}
-(void)doTap{

//    [[AppController sharedInstance] routeToUserProfile:_contact.userId];

}


@end
