//
//  AppContactsTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppContactsTableViewCell.h"

@implementation AppContactsTableViewCell

- (void)awakeFromNib {
    self.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setupWithContact:(AppContact *)contact andSelected:(BOOL)selected{
    
    _itemByline.hidden = YES;
    _itemTitle.text = contact.name;
    
    if(contact.hasAppInstalled){
        
        _iconAdd.hidden = YES;
        _iconCheckmark.hidden = YES;
        _iconEmail.hidden = YES;
        [self setSelected:selected animated:YES];
        if(selected){
            _iconAdd.hidden = YES;
            _iconCheckmark.hidden = NO;
        }else{
            _iconCheckmark.hidden = YES;
            _iconAdd.hidden = NO;
        }
        if(contact.pendingInvite){
            _itemByline.hidden = NO;
            _itemByline.text = @"PENDING FRIEND REQUEST";
            _iconAdd.hidden = YES;
            _iconCheckmark.hidden = YES;
            _iconEmail.hidden = YES;
        }else if(contact.acceptedInvite){
            _itemByline.hidden = NO;
            _itemByline.text = @"ACCEPTED FRIEND REQUEST";
            _iconAdd.hidden = YES;
            _iconCheckmark.hidden = YES;
            _iconEmail.hidden = YES;
        }
        
    }else{
        _iconAdd.hidden = YES;
        _iconCheckmark.hidden = YES;
        _iconEmail.hidden = NO;
    }
    


}

@end
