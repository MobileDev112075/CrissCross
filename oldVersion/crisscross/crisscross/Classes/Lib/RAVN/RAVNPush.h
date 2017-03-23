//
//  RAVNPush.h
//  JustPray
//
//  Created by Vincent Tuscano on 11/19/14.
//  Copyright (c) 2014 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface RAVNPush : NSObject<UIAlertViewDelegate,UIAlertViewDelegate>{
    NSString *_deviceToken;
    NSString *_accountId;
    NSDictionary *_locationDetails;
    UIAlertView *_alertViewPushNotice;
    NSDictionary *_responseObject;
}


+(RAVNPush *)sharedInstance;



@property(strong,nonatomic) NSString *accountId;
@property(strong,nonatomic) NSString *userId;

-(void)requestPushAccess;
-(void)setAccountId:(NSString *)token;
-(void)setUserId:(NSString *)userId;
-(void)setDeviceToken:(NSData *)token;
-(void)sendUpdatedDeviceToken;
-(void)resetBadgeToZero;
-(void)setBadgeToNumber:(int)val;
-(void)checkRemoteStatus:(UIUserNotificationSettings *)notificationSettings;
-(void)notificationReceived:(NSDictionary*)userInfo;

@end
