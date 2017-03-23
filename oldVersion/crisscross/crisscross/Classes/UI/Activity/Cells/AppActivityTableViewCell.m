//
//  AppActivityTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppActivityTableViewCell.h"
#import "AppBeenThereDetailViewController.h"
#import "AppBeenThereViewController.h"

@implementation AppActivityTableViewCell

- (void)awakeFromNib {
    _itemImage.layer.cornerRadius = _itemImage.width/2;
    _itemImage.clipsToBounds = YES;
    _itemImage.backgroundColor = [UIColor colorWithHexString:@"F2f2f2"];
    _itemDescription.numberOfLines = 0;
    
    _itemTimeAgo.layer.cornerRadius = _itemTimeAgo.width/2;
    _itemTimeAgo.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.5].CGColor;
    _itemTimeAgo.layer.borderWidth = 0.5;
    
    _cityBgImageView = [[UIImageView alloc] init];
    _cityBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _cityBgImageView.clipsToBounds = YES;
    _cityBgImageView.alpha = 0.1;
    
    _cityFriendsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _citySuggestionsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    [_cityFriendsBtn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_citySuggestionsBtn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _thinLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.5, 1)];
    _thinLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.5, 1)];
    
    _thinLine1.backgroundColor = _thinLine2.backgroundColor = [[UIColor colorWithHexString:@"#CCCCCC"] colorWithAlphaComponent:0.5];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setupWithActivity:(AppActivity *)activity{
    _activity = activity;
    int descSize = 14;
    NSString *startingColor = COLOR_CC_GREEN;
    NSString *endingColor = COLOR_CC_BLUE_BG;
    int screenWidth = [AppController sharedInstance].screenBoundsSize.width;
    [_cityBgImageView cancelImageRequestOperation];
    _cityBgImageView.image = nil;
    
    _itemDescription.numberOfLines = 0;
    _theActivity = activity;
    _labelSwipe.hidden = YES;
    [_itemImage cancelImageRequestOperation];
    _itemImage.image = nil;
    [_itemImage setImageWithURL:[NSURL URLWithString:_theActivity.img] placeholderImage:[AppController sharedInstance].personImageIcon];
    _lineOne.numberOfLines = 1;
    _lineOne.x = _itemDescription.x;
    _lineTwo.x = _lineOne.x;
    _itemDescription.width = self.width - _itemDescription.x - 10;
    _lineOne.text = _theActivity.line1;
    _lineTwo.text = _theActivity.line2;
    [_cityBgImageView removeFromSuperview];
    [_cityFriendsBtn removeFromSuperview];
    [_citySuggestionsBtn removeFromSuperview];
    [_thinLine1 removeFromSuperview];
    [_thinLine2 removeFromSuperview];
    _lineOne.adjustsFontSizeToFitWidth = YES;
    
    if(_theActivity.isSearchResult){
        
        _itemTimeAgo.hidden = YES;
        
        if(_theActivity.activityType == AppActivityTypePlan){
            _lineOne.hidden = YES;
            _itemDescription.hidden = NO;
            _lineTwo.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:descSize];
            _lineTwo.textColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
            descSize = 14;
            _itemDescription.numberOfLines = 1;
            endingColor = COLOR_CC_GREEN;
            startingColor = COLOR_CC_BLUE_BG;

        }else if(_theActivity.activityType == AppActivityTypeCity){
            [_cityBgImageView setImageWithURL:[NSURL URLWithString:activity.img] placeholderImage:nil];
            [self insertSubview:_cityBgImageView atIndex:0];
            _cityBgImageView.width = screenWidth;
            _cityBgImageView.height = self.height;
            _lineOne.hidden = NO;
            
            _lineOne.numberOfLines = 2;
            _lineOne.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:17];
            _lineOne.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
            _lineTwo.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:descSize];
            _lineTwo.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
            _itemDescription.hidden = YES;
            _cityFriendsBtn.titleLabel.numberOfLines = 2;
            _citySuggestionsBtn.titleLabel.numberOfLines = 2;
            [self.contentView addSubview:_cityFriendsBtn];
            [self.contentView addSubview:_citySuggestionsBtn];
            [self.contentView addSubview:_thinLine1];
            [self.contentView addSubview:_thinLine2];
            
            
            NSString *str = [NSString stringWithFormat:@"%d~~||~~\nFriend%@",activity.usersTotal,(activity.usersTotal == 1) ? @"" : @"s"];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.minimumLineHeight = 8.f;
            paragraphStyle.maximumLineHeight = 19.f;
            paragraphStyle.alignment = NSTextAlignmentCenter;
        
            NSDictionary *subAttrsTop = @{
                                          NSForegroundColorAttributeName:[UIColor colorWithHexString:COLOR_CC_BLUE_BG],
                                          NSFontAttributeName : [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:18],
                                          NSParagraphStyleAttributeName : paragraphStyle};
            
            NSDictionary *subAttrs = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:COLOR_CC_BLUE_BG],
                                       NSFontAttributeName : [UIFont fontWithName:FONT_HELVETICA_NEUE size:10],
                                       NSParagraphStyleAttributeName : paragraphStyle};
            
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:str attributes:subAttrs];
            
            
            NSRange range = [str rangeOfString:@"~~||~~"];
            
            if(range.location == NSNotFound){
                [_cityFriendsBtn setAttributedTitle:attributedText forState:UIControlStateNormal];
            }else{
                
                NSString *newString = [str stringByReplacingOccurrencesOfString:@"~~||~~" withString:@""];
                NSRange range1 = NSMakeRange(0,range.location);
                attributedText = [[NSMutableAttributedString alloc] initWithString:newString attributes:subAttrs];
                [attributedText setAttributes:subAttrsTop range:range1];
                [_cityFriendsBtn setAttributedTitle:attributedText forState:UIControlStateNormal];
            }
            
            if(activity.suggestionsTotal == 0){
                str = @"Add\nSuggestion";

            }else{
                str = [NSString stringWithFormat:@"%d~~||~~\nSuggestion%@",activity.suggestionsTotal,(activity.suggestionsTotal == 1) ? @"" : @"s"];
            }
            
            attributedText = [[NSMutableAttributedString alloc] initWithString:str attributes:subAttrs];
            range = [str rangeOfString:@"~~||~~"];
            
            if(range.location == NSNotFound){
                [_citySuggestionsBtn setAttributedTitle:attributedText forState:UIControlStateNormal];
            }else{
                
                NSString *newString = [str stringByReplacingOccurrencesOfString:@"~~||~~" withString:@""];
                NSRange range1 = NSMakeRange(0,range.location);
                attributedText = [[NSMutableAttributedString alloc] initWithString:newString attributes:subAttrs];
                [attributedText setAttributes:subAttrsTop range:range1];
                [_citySuggestionsBtn setAttributedTitle:attributedText forState:UIControlStateNormal];
            }

            
            
            
        }else{
            _lineOne.hidden = NO;
            _lineOne.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:17];
            _lineOne.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
            _lineTwo.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:descSize];
            _lineTwo.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
            _itemDescription.hidden = YES;
        }

    }else{
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_theActivity.created];
        _itemTimeAgo.text = [NSString stringWithFormat:@"%@",[date timeAgoShort]];
        _itemTimeAgo.hidden = NO;
        _lineOne.text = _theActivity.line1;
        _lineTwo.text = _theActivity.line2;
    }
    
    
    NSRange boldRange = [_theActivity.line2 rangeOfString:@"{{"];
    
    if(boldRange.location != NSNotFound){
        
        NSRange boldEndRange = [_theActivity.line2 rangeOfString:@"}}"];
        
        NSRange theRange = NSMakeRange(boldRange.location, boldEndRange.location - boldRange.location - 2);
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.minimumLineHeight = 12.f;
        paragraphStyle.maximumLineHeight = 16.f;

        NSDictionary *subAttrsTop = @{
                                      NSForegroundColorAttributeName:[[UIColor colorWithHexString:endingColor] colorWithAlphaComponent:1],
                                      NSFontAttributeName : [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:descSize],
                                      NSParagraphStyleAttributeName : paragraphStyle};
        
        NSDictionary *subAttrs = @{NSForegroundColorAttributeName:[[UIColor colorWithHexString:endingColor] colorWithAlphaComponent:1],
                                   NSFontAttributeName : [UIFont fontWithName:FONT_HELVETICA_NEUE size:descSize],
                                   NSParagraphStyleAttributeName : paragraphStyle};
        
       
        NSString *newString = [_theActivity.line2 stringByReplacingOccurrencesOfString:@"{{" withString:@""];
        newString = [newString stringByReplacingOccurrencesOfString:@"}}" withString:@""];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:newString attributes:subAttrs];
        [attributedText setAttributes:subAttrsTop range:theRange];
        _lineTwo.attributedText = attributedText;
    }

    
    
    
    
    _itemDescription.tintColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 12.f;
    paragraphStyle.maximumLineHeight = 16.f;
    
    _itemDescription.text = @"";
    
    NSDictionary *subAttrsTop = @{
                                  NSForegroundColorAttributeName:[[UIColor colorWithHexString:startingColor] colorWithAlphaComponent:1],
                                  NSFontAttributeName : [UIFont fontWithName:FONT_HELVETICA_NEUE size:descSize],
                                  NSParagraphStyleAttributeName : paragraphStyle};
    
    NSDictionary *subAttrs = @{NSForegroundColorAttributeName:[[UIColor colorWithHexString:endingColor] colorWithAlphaComponent:1],
                               NSFontAttributeName : [UIFont fontWithName:FONT_HELVETICA_NEUE size:descSize],
                               NSParagraphStyleAttributeName : paragraphStyle};
    

    
    NSDictionary *attrBold = @{
                               NSForegroundColorAttributeName:[[UIColor colorWithHexString:endingColor] colorWithAlphaComponent:1],
                               NSFontAttributeName : [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:descSize],
                               NSParagraphStyleAttributeName : paragraphStyle};

    
    NSDictionary *attrLightBlue = @{
                               NSForegroundColorAttributeName:[[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:1],
                               NSFontAttributeName : [UIFont fontWithName:FONT_HELVETICA_NEUE size:descSize],
                               NSParagraphStyleAttributeName : paragraphStyle};


    
    
    NSRange range = [_theActivity.line3 rangeOfString:@"~~||~~"];
    NSString *newString = [_theActivity.line3 stringByReplacingOccurrencesOfString:@"~~||~~" withString:@""];
    
    boldRange = [newString rangeOfString:@"{{"];
    NSRange boldEndRange = [newString rangeOfString:@"}}"];
    
    newString = [newString stringByReplacingOccurrencesOfString:@"{{" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"}}" withString:@""];
    
    
    NSRange lightBlueRange = [newString rangeOfString:@"|b|"];
    NSRange lightBlueRangeEnd = [newString rangeOfString:@"|eb|"];
    
    newString = [newString stringByReplacingOccurrencesOfString:@"|b|" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"|eb|" withString:@""];
    

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:newString attributes:subAttrs];
    
    
    if(range.location != NSNotFound){
        NSRange range1 = NSMakeRange(0,range.location);
        [attributedText setAttributes:subAttrsTop range:range1];
    }
    
    if(boldRange.location != NSNotFound){
        
        NSRange theRange = NSMakeRange(boldRange.location, boldEndRange.location - boldRange.location - 2);
        [attributedText setAttributes:attrBold range:theRange];
    }
    
    if(lightBlueRange.location != NSNotFound){
        
        NSRange theRange = NSMakeRange(lightBlueRange.location, lightBlueRangeEnd.location - lightBlueRange.location - 3);
        [attributedText setAttributes:attrLightBlue range:theRange];
    }

    
    
    _itemDescription.attributedText = attributedText;
    
    
    if(activity.userAcceptRejectOptions)
        _labelSwipe.hidden = NO;
    else if(activity.swipeOptionMissJoin)
        _labelSwipe.hidden = NO;
    else if(activity.swipeOptionMissUpdatePlans)
        _labelSwipe.hidden = NO;
    else if(activity.userRejectOptions)
        _labelSwipe.hidden = NO;
    
    [self readjustLayout];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self readjustLayout];
    });
   
}

-(void)btnTapped:(UIButton *)btn{
    
    if(btn == _citySuggestionsBtn){
        
        if(_activity.suggestionsTotal == 0){
        
            AppBeenThereDetailViewController *vc = [[AppBeenThereDetailViewController alloc] initWithNibName:@"AppBeenThereDetailViewController" bundle:nil];
            vc.isFromSearch = YES;
            vc.isOwner = YES;
            vc.searchActivity = _activity;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }else{
            AppBeenThereViewController *vc = [[AppBeenThereViewController alloc] initWithNibName:@"AppBeenThereViewController" bundle:nil];
            vc.thisUser = [AppController sharedInstance].currentUser;
            vc.communityView = YES;
            vc.searchActivity = _activity;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
    }else if(btn == _cityFriendsBtn){
        
        if(_activity.usersTotal > 0){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FOR_FIND_SHOW_HERE object:_activity];
        }
    }
}

-(void)readjustLayout{
    
    [_lineOne sizeToFit];
    [_lineTwo sizeToFit];
    _itemDescription.adjustsFontSizeToFitWidth = YES;
    _itemDescription.width = self.width - _itemDescription.x - 10;
    [_itemDescription sizeToFit];
    _itemDescription.width = self.width - _itemDescription.x - 10;
    _itemDescription.height += 4;
    _itemImage.hidden = NO;
    _lineOne.width = self.width - _lineOne.x - 10;
    _lineTwo.width = self.width - _lineTwo.x - 10;
    _lineOne.adjustsFontSizeToFitWidth = YES;
    _lineTwo.adjustsFontSizeToFitWidth = YES;
    
    
    if(_theActivity.isSearchResult){
        
        _labelSwipe.hidden = YES;
        _itemTimeAgo.hidden = YES;
        _itemImage.y = self.height/2 - _itemImage.height/2;
        
        if(_theActivity.activityType == AppActivityTypeCity){
            
            _cityBgImageView.width = self.width;
            _cityBgImageView.height = self.height;
            _itemImage.hidden = YES;
            _lineOne.x = _itemImage.x;
            _lineOne.hidden = NO;
            _lineOne.y = self.height/2 - _lineOne.height/2;
            
            _cityFriendsBtn.height = _citySuggestionsBtn.height = self.height;
            
            _cityFriendsBtn.width = roundf(self.width * 0.18);
            _citySuggestionsBtn.width = roundf(self.width * 0.20);
            
            _citySuggestionsBtn.x = self.width - _citySuggestionsBtn.width;
            _cityFriendsBtn.x = _citySuggestionsBtn.x - _cityFriendsBtn.width;
            
            _lineOne.width = _cityFriendsBtn.x - _lineOne.x - 5;
            _thinLine1.height = _thinLine2.height = self.height;
            _thinLine1.x = _cityFriendsBtn.x;
            _thinLine2.x = _citySuggestionsBtn.x;
            
        }else if(_theActivity.activityType == AppActivityTypePlan){
            _itemDescription.y = _itemImage.y - 2;
            _lineTwo.y = _itemDescription.maxY + 2;
        }else{
            if([_lineTwo.text isEmpty]){
                _lineOne.y = self.height/2 - _lineOne.height/2;
                _lineTwo.y = _lineOne.maxY + 2;
            }else{
                _lineOne.y = self.height/2 - _lineOne.height;
                _lineTwo.y = _lineOne.maxY + 2;
            }
        }
    }else{
       
        if([_itemDescription.text isEmpty]){
            _lineOne.y = self.height/2 - _lineOne.height;
            _lineTwo.y = _lineOne.maxY + 2;
        }else{
            _lineOne.y = _itemImage.y + _itemImage.height/4;
            _lineTwo.y = _lineOne.maxY + 2;
            _itemDescription.y = _lineTwo.maxY + 1;
            
        }
        

    }
    

    
    
}

@end
