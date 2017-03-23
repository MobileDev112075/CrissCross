//
//  AppAddGroupsTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/21/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppAddGroupsTableViewCell.h"
#import "UIView+Additions.h"
#import "AppGroup.h"
#import "AppContact.h"

@implementation AppAddGroupsTableViewCell

- (void)awakeFromNib {
    _itemImage.layer.cornerRadius = _itemImage.width/2;
    _itemImage.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupWithContact:(AppContact *)contact{
    _itemTitle.text = contact.name;
//    [_itemImage setImageWithURL:[NSURL URLWithString:contact.img] placeholderImage:[AppController sharedInstance].personImageIcon];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int fontSizeTitle = self.height*.24;
        _itemTitle.font = [UIFont fontWithName:_itemTitle.font.familyName size:fontSizeTitle];
        _divLine.y = self.height - 1;
    });

}

@end
