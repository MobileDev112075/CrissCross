//
//  AppUserFeedbackTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 10/1/15.
//  Copyright © 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppUserFeedbackTableViewCell : UITableViewCell<UITextViewDelegate>{
    UIImageView *_imageView;
    UIButton *_userName;
    UITextView *_comment;
    NSDictionary *_item;
    UIButton *_btnViewPhoto;
    UIView *_prices;
    UILabel *_line;
}


-(void)setupWithDictionary:(NSDictionary *)dict andWidth:(int)width;
+(float)calculateHeight:(NSDictionary *)dict withWidth:(float)width;

@end
