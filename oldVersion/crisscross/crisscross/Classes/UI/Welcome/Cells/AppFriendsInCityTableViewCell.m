//
//  AppFriendsInCityTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppFriendsInCityTableViewCell.h"

@implementation AppFriendsInCityTableViewCell

- (void)awakeFromNib {
    _itemImage.layer.cornerRadius = _itemImage.width/2;
    _itemImage.clipsToBounds = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.contentView addTopBorderWithHeight:0.5 andColor:[[UIColor colorWithHexString:COLOR_CC_GREEN] colorWithAlphaComponent:0.1]];
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setupWithContact:(AppContact *)contact{
    _itemTitle.text = contact.name;
    [_itemImage setImageWithURL:[NSURL URLWithString:contact.img] placeholderImage:[AppController sharedInstance].personImageIcon];
}
@end
