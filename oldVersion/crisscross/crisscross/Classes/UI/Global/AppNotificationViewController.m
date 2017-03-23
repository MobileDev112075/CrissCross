//
//  AppNotificationViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 8/25/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppNotificationViewController.h"

@interface AppNotificationViewController ()

@end

@implementation AppNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heardPush:) name:NOTIFICATION_PUSH_RECEIVED object:nil];
    self.view.hidden = YES;
    self.view.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.8];
    self.view.height = 68;
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetected)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    _message = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _message.numberOfLines = 2;
    _subMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.view addSubview:_message];
    [self.view addSubview:_subMessage];
    _message.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:12];
    _message.adjustsFontSizeToFitWidth = YES;
    
    _message.textColor = _subMessage.textColor = [UIColor whiteColor];
    
    _iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
    _iconImage.contentMode = UIViewContentModeScaleAspectFill;

    [self.view addSubview:_iconImage];
    _btnHitArea = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_btnHitArea addTarget:self action:@selector(doTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnHitArea];
}


-(void)swipeDetected{
    [self hideSelf];
}

-(void)heardPush:(NSNotification *)note{
    NSString *msg = [NSString stringWithFormat:@"%@",[[note.object objectForKey:@"aps"] objectForKey:@"alert"]];
    msg = [NSString removeNull:msg];
    
    if([msg isEmpty]){
        return;
    }
    
    
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_sound1);
    self.view.width = [AppController sharedInstance].screenBoundsSize.width;

    _iconImage.height = _iconImage.width = roundf((self.view.height - 20) * 0.50);
    _iconImage.x = 10;
    _iconImage.y = ((self.view.height-20)/2 + 20 - _iconImage.height/2);
    _iconImage.layer.cornerRadius = 5;
    _iconImage.clipsToBounds = YES;
    _subMessage.hidden = YES;
    _message.x = _iconImage.maxX + 8;
    _message.width = self.view.width - _message.x - 40;
    _message.y = 20;
    _message.height = self.view.height - _message.y;
    _btnHitArea.width = self.view.width;
    _btnHitArea.height = self.view.height;
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(_sound1);

    [self.view.layer removeAllAnimations];
   
    
    
    if([[note.object objectForKey:@"aps"] objectForKey:@"badge"]){
        int badgeNumber = [[NSString stringWithFormat:@"%@",[[note.object objectForKey:@"aps"] objectForKey:@"badge"]] intValue];
        [[RAVNPush sharedInstance] setBadgeToNumber:badgeNumber];
    }
    
    _pushNote = note.object;
    _message.text = msg;
    self.view.y = -self.view.height;
    self.view.hidden = NO;
    
    [UIView animateWithDuration:0.50 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.y = 0;
                     } completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [self hideSelf];
                         });
                     }];
    
    
    
}

-(void)hideSelf{
    [self.view.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.y = -self.view.height;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)doTap {
    
    [[AppController sharedInstance] handlePushExtra:[_pushNote valueForKey:@"EXTRA"]];
    [self hideSelf];

}

+(UIView *)buildHintViewWithText:(NSString *)str andOffset:(int)offset{
    int topOffset = 58;
    UIView *hintView = [[UIView alloc] initWithFrame:CGRectMake(0, topOffset, [AppController sharedInstance].screenBoundsSize.width, [AppController sharedInstance].screenBoundsSize.height - topOffset)];
    hintView.clipsToBounds = NO;
    hintView.userInteractionEnabled = NO;
    hintView.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.8];
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, roundf(hintView.width * 0.75), 20)];
    
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    style.firstLineHeadIndent = 16.0f;
    style.headIndent = 16.0f;
    style.tailIndent = -16.0f;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:str attributes:@{ NSParagraphStyleAttributeName : style}];

    int fontSize = roundf([AppController sharedInstance].screenBoundsSize.width * 0.055);
    msg.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:fontSize];
    msg.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.numberOfLines = 0;
    msg.attributedText = attrText;
    msg.layer.cornerRadius = 8;
    msg.layer.borderColor = [UIColor colorWithHexString:COLOR_CC_TEAL].CGColor;
    msg.layer.borderWidth = 1;
    msg.adjustsFontSizeToFitWidth = YES;
    [msg sizeToFit];
    msg.width = roundf(hintView.width * 0.75);
    msg.height += 30;
    msg.x = hintView.width/2 - msg.width/2;
    msg.y = offset;
    [hintView addSubview:msg];
    
    float distanceFromEdge = hintView.width - 29;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(msg.maxX, msg.y + msg.height/2)];
    [path addLineToPoint:CGPointMake(distanceFromEdge, msg.y + msg.height/2)];
    [path addLineToPoint:CGPointMake(distanceFromEdge, -2)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] CGColor];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [hintView.layer addSublayer:shapeLayer];

    return hintView;
}


@end
