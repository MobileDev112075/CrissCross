//
//  AppDelegate.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppDelegate.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>
//#import "GAI.h"
//#import "AppsFlyerTracker.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
//    [Fabric with:@[[Crashlytics class]]];
    [[AppController sharedInstance] initialize];
    [[RAVNPush sharedInstance] setAccountId:@"CRISSCROSS"];
    
//    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-62465103-2"];
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
//    tracker.allowIDFACollection = YES;
//    
//    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"tX2xHV9Tx8HqphCkJRCQi";
//    [AppsFlyerTracker sharedTracker].appleAppID = @"1040051489";
    
    [[AppController sharedInstance] routeToIntro];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [[[AppController sharedInstance] navController].interactivePopGestureRecognizer setDelegate:[AppController sharedInstance]];
    self.window.rootViewController = [[AppController sharedInstance] navController];
    [self.window makeKeyAndVisible];
    return YES;
}


-(void)applicationDidBecomeActive:(UIApplication *)application{
//    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    [AppController sharedInstance].startedBackgroundTime = [[NSDate date] timeIntervalSince1970];
}

-(void)applicationWillEnterForeground:(UIApplication *)application{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENTERED_FOREGROUND object:nil];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    [[RAVNPush sharedInstance] setDeviceToken:deviceToken];
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    [[RAVNPush sharedInstance] checkRemoteStatus:nil];
}
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [[RAVNPush sharedInstance] checkRemoteStatus:notificationSettings];
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[RAVNPush sharedInstance] notificationReceived:userInfo];
}

@end
