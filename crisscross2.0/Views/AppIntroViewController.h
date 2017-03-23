//
//  AppIntroViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "THLabel.h"
#import "CCButton.h"

@interface AppIntroViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>{
    UIImageView *_longLoadingScreen;
    BOOL _loginWithTokenAttempt;
}



@property (strong, nonatomic) IBOutlet UITextField *inputEmail;
@property (strong, nonatomic) IBOutlet UITextField *inputPass;
@property (strong, nonatomic) IBOutlet UIButton *btnForgot;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *p2;
@property (strong, nonatomic) IBOutlet UILabel *p1;
@property (strong, nonatomic) IBOutlet UIButton *btnJoin;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *loginView;

@property (strong, nonatomic) IBOutlet CCButton *btnEye2;
@property (strong, nonatomic) IBOutlet CCButton *btnEye;
@property (strong, nonatomic) IBOutlet THLabel *logo;
@property (strong, nonatomic) IBOutlet THLabel *tagline;

- (IBAction)doJoin;
- (IBAction)doLoginView;
- (IBAction)doForgot:(id)sender;
- (IBAction)doBack;
- (IBAction)doShowPass:(id)sender;


@end
