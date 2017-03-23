//
//  RAVNPush.m
//  JustPray
//
//  Created by Vincent Tuscano on 11/19/14.
//  Copyright (c) 2014 RAVN. All rights reserved.
//

#import "RAVNPush.h"

static RAVNPush *_instance;

@implementation RAVNPush


+ (RAVNPush *)sharedInstance {
    @synchronized(self){
        if (_instance == nil) {
            _instance = [[self alloc] init];
            [_instance getUserLocationDetails];
        }
    }
    return _instance;
}



-(void)setDeviceToken:(NSData *)token{
    NSString *deviceTokenAsString = [[[[token description]
                                       stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                      stringByReplacingOccurrencesOfString: @">" withString: @""]
                                     stringByReplacingOccurrencesOfString: @" " withString: @""];
    _deviceToken = deviceTokenAsString;
    [self sendUpdatedDeviceToken];
}

-(void)requestPushAccess{
    
   
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
}

-(void)setUserId:(NSString *)userId{
    _userId = userId;
    [self sendUpdatedDeviceToken];
}

-(void)resetBadgeToZero{
    if([UIApplication sharedApplication].applicationIconBadgeNumber > 0){
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

-(void)setBadgeToNumber:(int)val{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:val];
}

-(void)notificationReceived:(NSDictionary*)userInfo{
    
    NSString *alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"badge"];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PUSH_RECEIVED object:userInfo];
    }else{
        if([userInfo valueForKey:@"EXTRA"]){
            [[AppController sharedInstance] handlePushExtra:[userInfo valueForKey:@"EXTRA"]];
        }
    }

}

-(void)checkRemoteStatus:(UIUserNotificationSettings *)notificationSettings{
    
    if(notificationSettings == nil){
        
    }else{

        if(notificationSettings.types == UIUserNotificationTypeNone){
            if(_alertViewPushNotice == nil){
                _alertViewPushNotice = [[UIAlertView alloc] initWithTitle:@"Push Notifications Are Off" message:@"You will need to enable push notifcations to receive alerts. Please enable them in your device settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Manage Settings", nil];
                _alertViewPushNotice.tag = 2;
                [_alertViewPushNotice show];
            }
        }
    }
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 2){
        if(buttonIndex == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        _alertViewPushNotice = nil;
    }else if(alertView.tag == 99){
        NSString *url = [NSString returnStringObjectForKey:@"url" withDictionary:_responseObject];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

-(void)getUserLocationDetails{

    
    _locationDetails = @{};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:@"http://ip-api.com/json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @try{
            _locationDetails = responseObject;
        }@catch(NSException *e){
        _locationDetails = @{};
        }
        [self sendUpdatedDeviceToken];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
    
}


-(void)sendUpdatedDeviceToken{
    if(!_deviceToken){
        return;
    }

    if(_locationDetails == nil){
        _locationDetails = @{};
    }

    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:_deviceToken forKey:@"device_token"];
    [dict setObject:_locationDetails forKey:@"loc"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForUpdateDeviceId:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            _responseObject = responseObject;
            if([[NSString returnStringObjectForKey:@"new" withDictionary:responseObject] isEqualToString:@"Y"]){
                NSString *title = [NSString returnStringObjectForKey:@"title" withDictionary:responseObject];
                NSString *msg = [NSString returnStringObjectForKey:@"msg" withDictionary:responseObject];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Download" otherButtonTitles:nil];
                av.tag = 99;
                [av show];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {}];
}




@end
