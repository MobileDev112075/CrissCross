//
//  AppNotificationViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 8/25/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


@interface AppNotificationViewController : UIViewController{
    SystemSoundID _sound1;
    NSDictionary *_pushNote;
    UILabel *_message;
    UILabel *_subMessage;
    UIImageView *_iconImage;
    UIButton *_btnHitArea;
}


+(UIView *)buildHintViewWithText:(NSString *)str andOffset:(int)offset;

@end
