//
//  AppController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppIntroViewController.h"
#import <MessageUI/MessageUI.h>
#import "AppDashboardViewController.h"
#import "AppNotificationViewController.h"

@interface AppController : NSObject<MFMessageComposeViewControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate>{
    AppIntroViewController *_introVC;
    MFMessageComposeViewController *_smsController;
    MFMailComposeViewController *_mailComposeViewController;
    UIView *_loadingScreen;
    AppDashboardViewController *_dashVC;
    NSMutableArray *_sendWithOptions;
    AppNotificationViewController *_appNotificationPanel;
    NSString *_inviteSentToContactEmail;
    UILabel *_versionLabel;
    UIView *_toastView;

}
@property(nonatomic,assign) BOOL isIPad;
@property(nonatomic,assign) CGSize screenBoundsSize;
@property(nonatomic,strong) UINavigationController *navController;
@property(nonatomic,strong) AppUser *currentUser;

@property(nonatomic,strong) UIImage *personImageIcon;
@property(nonatomic,strong) UIImage *logoImageIcon;
@property(nonatomic,strong) NSMutableArray *contactsSectionKeys;
@property(nonatomic,strong) NSMutableDictionary *contactsSectionData;
@property(nonatomic,strong) NSMutableDictionary *shareValues;
@property(nonatomic,strong) NSMutableDictionary *storedUploadedImages;
@property(nonatomic,assign) BOOL centerCalDayText;
@property(nonatomic,assign) NSTimeInterval startedBackgroundTime;
@property(nonatomic,strong) NSMutableDictionary *previousFetchedUsersData;
@property(nonatomic,strong) NSDictionary *passedShareValues;

+ (AppController *)sharedInstance;
-(void)initialize;
-(void)routeToIntro;
-(void)routeToDashboard;
-(void)routeToAddGroups;
-(void)routeToFirstStepAddContacts;
-(void)showFullScreenImage:(NSString *)imageURL withTitle:(NSString *)title;
-(void)hideKeyboard;
-(UIView *)buildHideKeyboardView;
-(void)routeToUserProfile:(NSString *)userId;
-(void)routeToPlans:(AppPlanType)type;

-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
-(void)logout;
-(void)goBack;
-(void)alertWithServerResponse:(NSDictionary *)dict;
-(void)inviteViaSMSOrEmail:(AppContact *)contact;
-(void)handlePushExtra:(NSDictionary *)dict;
-(void)showAlphaMessage;
-(void)showToastMessage:(NSString *)msg;
-(void)showWebBrowserWithURLString:(NSString *)urlString;

@end
