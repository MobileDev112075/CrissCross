//
//  AppController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppController.h"
#import "AppFindFriendViewController.h"
#import "AppActivityViewController.h"
#import "AppBeenThereViewController.h"
#import "AppFullScreenViewController.h"
#import "AppPlansViewController.h"
#import "AppMyPlansViewController.h"
#import "AppJoinViewController.h"
#import "AppCustomGroupsViewController.h"
//#import "AppsFlyerTracker.h"

static AppController *_instance;

@implementation AppController



#pragma mark - Singleton

+ (AppController *)sharedInstance {
    @synchronized(self)
    {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

-(void)initialize{
    _screenBoundsSize = [[UIScreen mainScreen] bounds].size;
    _navController = [[UINavigationController alloc] init];
    _navController.navigationBarHidden = YES;
    _currentUser = [[AppUser alloc] initWithDictionary:nil];
    [_currentUser loadStoredUserData];
    _shareValues = [[NSMutableDictionary alloc] init];
    _previousFetchedUsersData = [[NSMutableDictionary alloc] init];
    _appNotificationPanel = [[AppNotificationViewController alloc] initWithNibName:@"AppNotificationViewController" bundle:nil];
    [_navController.view addSubview:_appNotificationPanel.view];
    _storedUploadedImages = [[NSMutableDictionary alloc] init];
    
    if(kTestingMode){
        _versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
        _versionLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        _versionLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        _versionLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:8];
        [_versionLabel sizeToFit];
        _versionLabel.x = roundf(_screenBoundsSize.width * 0.60);
        _versionLabel.y = 2;
        [_navController.view addSubview:_versionLabel];
    }


    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
        _isIPad = YES;
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{

    UIViewController *topVC = [_navController.viewControllers lastObject];
    if(topVC != nil){
        if([topVC superclass] == [AppViewController class]){
            AppViewController *topVCC = (AppViewController *)topVC;
            return topVCC.canLeaveWithSwipe;
        }
    }
    return NO;
}

-(void)routeToIntro{
    _introVC = [[AppIntroViewController alloc] initWithNibName:@"AppIntroViewController" bundle:nil];
    [_navController pushViewController:_introVC animated:NO];
}

-(void)routeToAddGroups{
    AppCustomGroupsViewController *vc = [[AppCustomGroupsViewController alloc] initWithNibName:@"AppCustomGroupsViewController" bundle:nil];
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(void)routeToFirstStepAddContacts{
    
    AppFindFriendViewController *vc = [[AppFindFriendViewController alloc] initWithNibName:@"AppFindFriendViewController" bundle:nil];
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(void)routeToDashboard{
    
    
    if((1)){
        if([[AppController sharedInstance].currentUser.firstname isEmpty]
            || [[AppController sharedInstance].currentUser.lastname isEmpty]

           ){

            AppJoinViewController *vc = [[AppJoinViewController alloc] initWithNibName:@"AppJoinViewController" bundle:nil];
            vc.isResuming = YES;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        return;
        }
    }
    
    
    _dashVC = [[AppDashboardViewController alloc] initWithNibName:@"AppDashboardViewController" bundle:nil];
    [_navController pushViewController:_dashVC animated:NO];
}


-(void)showFullScreenImage:(NSString *)imageURL withTitle:(NSString *)title{
    AppFullScreenViewController *vc = [[AppFullScreenViewController alloc] initWithNibName:@"AppFullScreenViewController" bundle:nil];
    vc.imageURL = imageURL;
    vc.pageTitle = title;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(void)routeToUserProfile:(NSString *)userId{
    AppUserProfileViewController *vc = [[AppUserProfileViewController alloc] initWithNibName:@"AppUserProfileViewController" bundle:nil];
    vc.mainContactId = userId;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(void)routeToPlans:(AppPlanType)type{
    
    if(type == AppPlanTypeUpdate){
        AppMyPlansViewController *vc = [[AppMyPlansViewController alloc] initWithNibName:@"AppMyPlansViewController" bundle:nil];
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    }else{
        
        if(_dashVC != nil)
            [_navController popToViewController:_dashVC animated:NO];
        AppPlansViewController *vc = [[AppPlansViewController alloc] initWithNibName:@"AppPlansViewController" bundle:nil];
        vc.planType = type;
        vc.mainContactId = [AppController sharedInstance].currentUser.userId;
        [[AppController sharedInstance].navController pushViewController:vc animated:NO];
    }
}

-(void)goBack{
    [_navController popViewControllerAnimated:YES];
}

-(void)hideKeyboard{
    UITextField *tempT = [[UITextField alloc] init];
    [_navController.view addSubview:tempT];
    [tempT becomeFirstResponder];
    [tempT resignFirstResponder];
    [tempT removeFromSuperview];
    tempT = nil;
}

-(UIView *)buildHideKeyboardView{
    UIView *keyboardHelper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 48)];
    keyboardHelper.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UIButton *hideKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, keyboardHelper.height)];
    hideKeyboard.backgroundColor = [UIColor clearColor];
    [hideKeyboard setTitle:@"Hide Keyboard" forState:UIControlStateNormal];
    [hideKeyboard setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    hideKeyboard.titleLabel.font = [UIFont fontWithName:hideKeyboard.titleLabel.font.fontName size:13];
    [hideKeyboard addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchDown];
    [hideKeyboard sizeToFit];
    hideKeyboard.width += 5;
    hideKeyboard.height = keyboardHelper.height;
    hideKeyboard.x = keyboardHelper.width - hideKeyboard.width - 5;
    [keyboardHelper addSubview:hideKeyboard];
    return keyboardHelper;
}


-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)alertWithServerResponse:(NSDictionary *)dict{
    
    
    if([[dict objectForKey:@"message"] isNotEmpty]){
        if([[NSString returnStringObjectForKey:@"status" withDictionary:dict] isEqualToString:@"-1"]){
            
        }else{
            NSString *title = [[dict objectForKey:@"title"] isNotEmpty] ? [dict objectForKey:@"title"] : @"Error";
            [[AppController sharedInstance] showAlertWithTitle:title andMessage:[dict objectForKey:@"message"]];
        }
    }else{
        
    }
}



-(void)inviteViaSMSOrEmail:(AppContact *)contact{
    
    
    int numEmails = (int)[contact.emails count];
    int numPhones = (int)[contact.phoneNumbers count];
    BOOL doAsk = true;
    
    if(numEmails == 0 && numPhones == 0){
        [[AppController sharedInstance] showAlertWithTitle:@"No Contact Info" andMessage:@"Your contact does not have a phone or email address"];
        return;
    }
    
    _sendWithOptions = [[NSMutableArray alloc] init];
    
    
    if(numEmails >= 1 && numPhones >= 1){
        
        [_sendWithOptions addObjectsFromArray:contact.emails];
        [_sendWithOptions addObjectsFromArray:contact.phoneNumbers];
    }else if(numEmails >= 1){
        
    if(numEmails == 1){
        doAsk = NO;
        [self smsCompose:[contact.emails firstObject]];
    }else{
        [_sendWithOptions addObjectsFromArray:contact.emails];
    }
}else{
    
    if(numPhones == 1){
        doAsk = NO;
        [self smsCompose:[contact.phoneNumbers firstObject]];
    }else{
        [_sendWithOptions addObjectsFromArray:contact.phoneNumbers];
    }
}

if(doAsk){
    [[AppController sharedInstance] hideKeyboard];
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Invite %@",contact.name] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
    for( NSString *title in _sendWithOptions)  {
        [as addButtonWithTitle:title];
    }
    [as showInView:[AppController sharedInstance].navController.view];
}
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    int idx = (int)buttonIndex - 1;
    if(idx < 0){
        return;
    }
    
    NSString *val = [_sendWithOptions objectAtIndex:idx];
    [self smsCompose:val];
}

-(void)showAlphaMessage{
    [[AppController sharedInstance] showAlertWithTitle:@"Alpha" andMessage:@"Currenly working on this section, Alpha"];
}

-(void)smsCompose:(NSString *)val{
    

    
    if([val isEmail]){
        
        if([MFMailComposeViewController canSendMail]){
            
            NSString *eMailBody = [NSString stringWithFormat:@"Check out CrissCross for your phone. Download now to coordinate plans with the friends you love and get suggestions from those you trust! <a href=\"http://bit.ly/crisscrosstheapp\" style=\"color:#A394B2\">http://bit.ly/crisscrosstheapp</a>"];
            NSString *override = [NSString returnStringObjectForKey:@"share_email" withDictionary:[AppController sharedInstance].shareValues];
            
            if(_passedShareValues != nil){
                override = [NSString returnStringObjectForKey:@"body" withDictionary:_passedShareValues];
            }
            
            if([override length] > 5){
                eMailBody = override;
            }
            
            _inviteSentToContactEmail = val;
            _mailComposeViewController = [[MFMailComposeViewController alloc] init];
            _mailComposeViewController.mailComposeDelegate = self;
            [_mailComposeViewController setToRecipients:@[val]];
            
            _mailComposeViewController.view.tag = 2;
            [_mailComposeViewController setMessageBody:eMailBody isHTML:YES];
            _mailComposeViewController.subject = @"Let's CrissCross!";
            
            NSString *overrideSubject = [NSString returnStringObjectForKey:@"share_subject" withDictionary:[AppController sharedInstance].shareValues];
            if([overrideSubject length] > 2){
                _mailComposeViewController.subject = overrideSubject;
            }
            [[AppController sharedInstance].navController presentViewController:_mailComposeViewController animated:YES completion:nil];
        }else{
            [[AppController sharedInstance] showAlertWithTitle:@"No Email Account" andMessage:@"Your device does not have an email account for sending."];
        }
    }else{
        _smsController = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText]){
            _smsController.recipients = @[val];
            _smsController.body = @"Check out CrissCross for your phone. Download now to coordinate plans with the friends you love and get suggestions from those you trust! http://bit.ly/crisscrosstheapp";
            NSString *overrideSMS = [NSString returnStringObjectForKey:@"share_sms" withDictionary:[AppController sharedInstance].shareValues];
            
            if(_passedShareValues != nil){
                overrideSMS = [NSString returnStringObjectForKey:@"smsbody" withDictionary:_passedShareValues];
            }
            
            if([overrideSMS length] > 2){
                _smsController.body = overrideSMS;
            }
            
            _smsController.messageComposeDelegate = self;
            [[AppController sharedInstance].navController presentViewController:_smsController animated:YES completion:nil];
        }else{
            [[AppController sharedInstance] showAlertWithTitle:@"Device Settings" andMessage:@"Your device is not currently configured to send SMS"];
        }
    }
}


-(void)logout{
    
    [[AppController sharedInstance].currentUser removeAllData];
    if(_introVC){ _introVC = nil; }
    _currentUser = [[AppUser alloc] init];
    _introVC = [[AppIntroViewController alloc] initWithNibName:@"AppIntroViewController" bundle:nil];
    [_navController setViewControllers:@[_introVC] animated:YES];
    
}



#pragma mark - MFMessageComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    if(result == MFMailComposeResultSent){
        
        if([_inviteSentToContactEmail isNotEmpty]){
            NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
            [dict setObject:_inviteSentToContactEmail forKey:@"invite_email"];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
            [manager POST:[AppAPIBuilder APIForTrackInviteSent:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                responseObject = [VTUtils processResponse:responseObject];
                if([VTUtils isResponseSuccessful:responseObject]){
                }else{
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            }];
        }
    }
    
//    [[AppsFlyerTracker sharedTracker] trackEvent:@"tutorialCompleted" withValue:@"tutorialCompleted"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EMAIL_OR_SMS_INVITE_SENT object:nil];
    
    
    [_mailComposeViewController dismissViewControllerAnimated:YES completion:^{}];
}



-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    
    
    
    switch (result) {
        case MessageComposeResultCancelled:
            
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
            
        case MessageComposeResultFailed:
            
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
            
        case MessageComposeResultSent:
            
            //track
//            [[AppsFlyerTracker sharedTracker] trackEvent:@"tutorialCompleted" withValue:@"tutorialCompleted"];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EMAIL_OR_SMS_INVITE_SENT object:nil];
            
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
    }
    
    
}

-(void)handlePushExtra:(NSDictionary *)dict{

    
    
    if(dict != nil){
        
        NSString *extraType = [NSString returnStringObjectForKey:@"type" withDictionary:dict];
        NSString *extraId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
        
        if([extraType isEqualToString:@"BLOCKED"]){
            
        }else{
            
            if([extraType isEqualToString:@"AVIEW"]){
            
                BOOL haveView = NO;
                for(UIViewController *vc in _navController.viewControllers){
                    if([vc isKindOfClass:[AppActivityViewController class]]){
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH_ACTIVITY object:nil];
                        [_navController popToViewController:vc animated:YES];
                        haveView = YES;
                        break;
                    }
                }
                if(!haveView){
                    for(UIViewController *vc in _navController.viewControllers){
                        if([vc isKindOfClass:[AppDashboardViewController class]]){
                            [_navController popToViewController:vc animated:NO];
                        }
                    }
                    AppActivityViewController *vc = [[AppActivityViewController alloc] initWithNibName:@"AppActivityViewController" bundle:nil];
                    [[AppController sharedInstance].navController pushViewController:vc animated:NO];
                }
                
            }else if([extraType isEqualToString:@"USER"]){
                for(UIViewController *vc in _navController.viewControllers){
                    if([vc isKindOfClass:[AppDashboardViewController class]]){
                        [_navController popToViewController:vc animated:NO];
                    }
                }
                [self routeToUserProfile:extraId];
                
            }else if([extraType isEqualToString:@"BTDT"]){
                
                BOOL haveView = NO;
                for(UIViewController *vc in _navController.viewControllers){
                    if([vc isKindOfClass:[AppDashboardViewController class]]){
                        [_navController popToViewController:vc animated:NO];
                        haveView = YES;
                        break;
                    }
                }

                    AppBeenThereViewController *vc = [[AppBeenThereViewController alloc] initWithNibName:@"AppBeenThereViewController" bundle:nil];
                    vc.thisUser = [AppController sharedInstance].currentUser;
                    [[AppController sharedInstance].navController pushViewController:vc animated:YES];

                
                
            }else if([extraType isEqualToString:@"BTDT_COM"]){
                
                BOOL haveView = NO;
                for(UIViewController *vc in _navController.viewControllers){
                    if([vc isKindOfClass:[AppDashboardViewController class]]){
                        [_navController popToViewController:vc animated:NO];
                        haveView = YES;
                        break;
                    }
                }

                    AppBeenThereViewController *vc = [[AppBeenThereViewController alloc] initWithNibName:@"AppBeenThereViewController" bundle:nil];
                    vc.thisUser = [AppController sharedInstance].currentUser;
                    vc.communityView = YES;
                    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
                
                
            }else if([extraType isEqualToString:@"CONFIRM"]){
                
            }
        }
    }

}






-(void)showToastMessage:(NSString *)msg{
    if(_toastView == nil){
        _toastView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenBoundsSize.width, roundf(_screenBoundsSize.height * 0.20))];
        _toastView.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.8];
        UILabel *msg = [[UILabel alloc] initWithFrame:_toastView.frame];
        msg.tag = 100;
        msg.textAlignment = NSTextAlignmentCenter;
        msg.textColor = [UIColor blackColor];
        [_toastView addSubview:msg];
    }
    _toastView.y = _screenBoundsSize.height;
    UILabel *label = [_toastView viewWithTag:100];
    label.text = msg;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:roundf(label.height * 0.20)];
    
    [_navController.view addSubview:_toastView];
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
        _toastView.y = _screenBoundsSize.height - _toastView.height;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:1.8 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
            _toastView.y = _screenBoundsSize.height;
        } completion:^(BOOL finished) {
            
        }];
    }];
    
}



-(void)showWebBrowserWithURLString:(NSString *)urlString{
    
    if([urlString rangeOfString:@"mailto:"].location != NSNotFound){
        [self handleMailTo:urlString];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

- (void)handleMailTo:(NSString *)mailto{
    
    NSString *regexString = @"([A-Za-z0-9_\\-\\.\\+])+\\@([A-Za-z0-9_\\-\\.])+\\.([A-Za-z]+)";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    if (!error) {
        
        NSArray *matches = [regex matchesInString:mailto options:0 range:NSMakeRange(0, mailto.length)];
        
        if([matches count] > 0){
            NSTextCheckingResult *match = matches[0];
            NSString *matchText = [mailto substringWithRange:match.range];
            _mailComposeViewController = [[MFMailComposeViewController alloc] init];
            if([MFMailComposeViewController canSendMail]){
                [_mailComposeViewController setToRecipients:@[matchText]];
                _mailComposeViewController.mailComposeDelegate = self;
                _mailComposeViewController.navigationBar.tintColor = [UIColor blackColor];
                [[AppController sharedInstance].navController presentViewController:_mailComposeViewController animated:YES completion:nil];
            }
        }
    }
}








@end
