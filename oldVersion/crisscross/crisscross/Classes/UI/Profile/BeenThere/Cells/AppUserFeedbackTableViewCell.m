//
//  AppUserFeedbackTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 10/1/15.
//  Copyright © 2015 RAVN. All rights reserved.
//

#import "AppUserFeedbackTableViewCell.h"

#define kFeedbackImagePercent 0.10
#define kFeedbackPricePercent 0.18

@implementation AppUserFeedbackTableViewCell

- (void)awakeFromNib {

    _imageView = [[UIImageView alloc] init];
    _userName = [[UIButton alloc] init];
    [_userName addTarget:self action:@selector(userTapped) forControlEvents:UIControlEventTouchUpInside];
    _userName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _comment = [[UITextView alloc] init];
    _comment.scrollEnabled = NO;

    _comment.tintColor  = [UIColor colorWithHexString:COLOR_CC_TEAL];
    _comment.selectable = YES;
    _comment.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber | UIDataDetectorTypeAddress;
    _comment.editable = NO;
    _comment.delegate = self;
    
    _line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 1)];
    _line.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:tap];
    
    [_userName setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];

    _btnViewPhoto = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_btnViewPhoto setTitle:@"Photo >" forState:UIControlStateNormal];
    [_btnViewPhoto setTitleColor:[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [_btnViewPhoto addTarget:self action:@selector(showPhoto) forControlEvents:UIControlEventTouchDown];
    _prices = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    
    [self.contentView addSubview:_imageView];
    [self.contentView addSubview:_userName];
    [self.contentView addSubview:_comment];
    [self.contentView addSubview:_btnViewPhoto];
    [self.contentView addSubview:_prices];
    [self.contentView addSubview:_line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    return YES;
}

+(float)calculateHeight:(NSDictionary *)dict withWidth:(float)width{
    
    int spaceForUsername = 40;
    float imageHeight = roundf(width * kFeedbackImagePercent);
    float imageSpace = imageHeight;
    float spaceForPrices = roundf(width * kFeedbackPricePercent);
    int fontSize = roundf(width * 0.038);
    imageSpace += 20.0;
    imageSpace += spaceForPrices;
    UITextView *customMessage = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 1000)];
    NSString *msg = [NSString returnStringObjectForKey:@"comment" withDictionary:dict];
    if([msg length] == 0)
        msg = @"No Comment";
    customMessage.text = msg;
    customMessage.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:fontSize];
    customMessage.width = width - 10 - imageSpace;
    [customMessage sizeToFit];
    customMessage.width = width - 10 - imageSpace;
    return MAX(imageHeight + 30, spaceForUsername + customMessage.height - 5);
}


-(void)setupWithDictionary:(NSDictionary *)dict andWidth:(int)width{
    _item = dict;
    [self adjustAfter];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustAfter];
    });

}

-(void)adjustAfter{
    
    float imageSpace = roundf(self.width * kFeedbackImagePercent);
    float spaceForPrices = roundf(self.width * kFeedbackPricePercent);
    int fontSize = roundf(self.width * 0.038);
    _imageView.y = 10;
    _imageView.x = 10;
    _imageView.width = imageSpace;
    imageSpace += 10;
    
    _userName.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:roundf(fontSize + fontSize * 0.1)];
    _btnViewPhoto.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:roundf(fontSize * 0.9)];
    
    NSString *str = @"Photo N";
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.8], NSForegroundColorAttributeName,nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:FONT_ICONS size:9],NSFontAttributeName,nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
    [attributedText setAttributes:subAttrs range: NSMakeRange([str length]-1,1)];
    
    
    [_btnViewPhoto setAttributedTitle:attributedText forState:UIControlStateNormal];
    [_btnViewPhoto sizeToFit];
    _btnViewPhoto.width += 5;
    _btnViewPhoto.height += 5;
    
    _imageView.height = _imageView.width;
    _imageView.layer.cornerRadius = _imageView.width/2;
    _imageView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    _imageView.clipsToBounds = YES;
    [_imageView cancelImageRequestOperation];
    [_imageView setImageWithURL:[NSURL URLWithString:[NSString returnStringObjectForKey:@"users_image_url" withDictionary:_item]]];
    
    float pricesBoxWidth = spaceForPrices;
    imageSpace += pricesBoxWidth;
    
    _userName.y = _imageView.y;
    _userName.x = _imageView.maxX + 10;
    
    [_prices removeAllSubviews];
    _prices.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0];
    _prices.width = pricesBoxWidth;
    _prices.height = 60;
    int priceSize = pricesBoxWidth/5;
    int startingX = _prices.width - priceSize;
    int rating = [[NSString returnStringObjectForKey:@"rating" withDictionary:_item] intValue];
    
    for(int i=5; i>0; i--){
        UILabel *p = [[UILabel alloc] initWithFrame:CGRectMake(startingX, 0, priceSize, _prices.height)];
        p.text = @"$";
        p.font = [UIFont fontWithName:FONT_ICONS size:priceSize * 1];
        p.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        [p sizeToFit];
        if(i > rating){
            p.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        }
        p.width = priceSize;
        [_prices addSubview:p];
        startingX -= priceSize;
        _prices.height = p.height;
    }
    
    if([[NSString returnStringObjectForKey:@"custom_img" withDictionary:_item] length] > 10){
        _btnViewPhoto.hidden = NO;
    }else{
        _btnViewPhoto.hidden = YES;
    }
    
    
    _userName.width = self.width - _userName.x - pricesBoxWidth;
    [_userName sizeToFit];
    _userName.width = self.width - _userName.x - pricesBoxWidth;
    [_userName setTitle:[NSString returnStringObjectForKey:@"users_name" withDictionary:_item] forState:UIControlStateNormal];
    _userName.titleLabel.adjustsFontSizeToFitWidth = YES;

    _userName.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
    
    _prices.x = self.width - _prices.width - 5;
    _prices.y = _userName.maxY + 2;
    
    _btnViewPhoto.y = _userName.y - 2;
    _btnViewPhoto.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0];
    _btnViewPhoto.x = self.width - _btnViewPhoto.width - 5;
    
    
    _comment.x = _userName.x - 5;
    _comment.y = _userName.maxY - 8;
    _comment.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    
    NSString *msg = [NSString returnStringObjectForKey:@"comment" withDictionary:_item];
    if([msg length] == 0){
        msg = @"No Comment";
        _comment.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    }
    _comment.text = msg;
    _comment.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:fontSize];
    
    _comment.width = self.width - 10 - imageSpace;
    [_comment sizeToFit];
    _comment.width = self.width - 10 - imageSpace;
    _comment.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
    _line.width = self.width;
    _line.y = self.height - _line.height;
    
}

-(void)userTapped{
    [[AppController sharedInstance] routeToUserProfile:[NSString returnStringObjectForKey:@"users_id" withDictionary:_item]];
}

-(void)showPhoto{
    [[AppController sharedInstance] showFullScreenImage:[NSString returnStringObjectForKey:@"custom_img" withDictionary:_item] withTitle:[NSString returnStringObjectForKey:@"item_title" withDictionary:_item]];
}

@end
