//
//  AppIntroViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppIntroViewController.h"
#import "AppJoinViewController.h"


#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface AppIntroViewController ()

@end

@implementation AppIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topView.alpha = 0;
    [_topnav.view removeFromSuperview];
    self.canLeaveWithSwipe = NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)layoutUI{
    
    if(!_didLayout){
        _didLayout = YES;
    
        UILabel *personImageIcon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        personImageIcon.text = @"p";
        personImageIcon.font = [UIFont fontWithName:FONT_ICONS size:200];
        personImageIcon.textColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2];
        [personImageIcon sizeToFit];
        personImageIcon.width += 140;
        personImageIcon.height += 140;
        personImageIcon.textAlignment = NSTextAlignmentCenter;
        UIGraphicsBeginImageContext(personImageIcon.bounds.size);
        [personImageIcon.layer renderInContext:UIGraphicsGetCurrentContext()];
        [AppController sharedInstance].personImageIcon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    
        if([[AppController sharedInstance].currentUser.token isNotEmpty]){
            
            _longLoadingScreen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            _longLoadingScreen.image = [UIImage imageNamed:@"clouds.jpg"];
            _longLoadingScreen.contentMode = UIViewContentModeScaleAspectFill;
            [self.view addSubview:_longLoadingScreen];
            _topView.hidden = NO;
            _topView.alpha = 1;
            _btnBack.hidden = YES;
            UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [act startAnimating];
            act.y = _topView.maxY + 20;
            act.x = self.view.width/2 - act.width/2;
            [_longLoadingScreen addSubview:act];
            [self.view addSubview:_topView];
            _loginWithTokenAttempt = YES;
            [self doLoginWithToken];
            return;
        }

        _topView.y = self.view.height/2 - _topView.height/2;
        _topView.y += 10;
        _topView.alpha = 0;
        
        [UIView animateWithDuration:0.5 delay:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _topView.alpha = 1;
            _topView.y -= 10;
        } completion:^(BOOL finished) {
            
        }];
        
        _btnEye.layer.cornerRadius = _btnEye.width/2;
        _btnEye.layer.borderColor = [UIColor colorWithHexString:@"#0DA7E4"].CGColor;
        _btnEye.layer.borderWidth = 1;
        
        _btnEye2.layer.cornerRadius = _btnEye2.width/2;
        _btnEye2.layer.borderColor = [UIColor colorWithHexString:@"#0DA7E4"].CGColor;
        _btnEye2.layer.borderWidth = 1;
        _btnEye2.hidden = YES;
        
        _bottomView.y += 10;
        _bottomView.alpha = 0;
        
        [UIView animateWithDuration:0.5 delay:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _bottomView.alpha = 1;
            _bottomView.y -= 10;
        } completion:^(BOOL finished) {
            
        }];
        
        _tagline.letterSpacing = 5.5;
        

        _btnBack.hidden = YES;

        _p1.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(245) );
        _p1.x = 0;
        _p1.width = 200;
        _p1.y = self.view.height - 100;
        
        
        _p2.transform = CGAffineTransformRotate(CGAffineTransformIdentity,DEGREES_TO_RADIANS(75) );
        _p2.x = self.view.width - 100;
        _p2.width = 100;
        _p2.y = -100;
        
        [UIView animateWithDuration:60 delay:0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             _p1.x = -100;
                             _p1.y = 0;
                             _p1.alpha = 0;
                             _p2.x = self.view.width;
                             _p2.y = self.view.height;
                             _p2.alpha = 0;
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        [_inputEmail addBottomBorderWithHeight:1 andColor:[UIColor colorWithHexString:COLOR_CC_GREEN]];
        [_inputPass addBottomBorderWithHeight:1 andColor:[UIColor colorWithHexString:COLOR_CC_GREEN]];
        
        
        _inputEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:_inputEmail.font.pointSize], NSForegroundColorAttributeName : [[UIColor colorWithHexString:COLOR_CC_GREEN] colorWithAlphaComponent:0.8 ] }];
        _inputPass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:_inputPass.font.pointSize], NSForegroundColorAttributeName :[[UIColor colorWithHexString:COLOR_CC_GREEN] colorWithAlphaComponent:0.8 ] }];
    
    }

}


- (IBAction)doJoin {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    AppJoinViewController *vc = [[AppJoinViewController alloc] initWithNibName:@"AppJoinViewController" bundle:nil];
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    
}
- (IBAction)doLoginView {
    _btnBack.hidden = NO;
    _btnBack.alpha = 0;
    _btnBack.y = 20;
    _loginView.x = self.view.width/2 - _loginView.width/2;
    _btnBack.x = 10;
    [self.view addSubview:_loginView];
    [self.view addSubview:_btnBack];
    
    _loginView.y = self.view.height;
    _loginView.backgroundColor = [UIColor clearColor];
    [_inputEmail becomeFirstResponder];

#if TARGET_IPHONE_SIMULATOR
    int padding = 30;
    float offset = ((self.view.height - 100)/2) - (_topView.height+_loginView.height + padding)/2;
    float offsetInput = offset + _topView.height + padding;
    [_loginView.layer removeAllAnimations];
    [_topView.layer removeAllAnimations];
    
    [UIView animateWithDuration: 0.15
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         _loginView.y = offsetInput;
                         _topView.y = offset;
                         
                     }
                     completion:^(BOOL finished){}];

#endif
    
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _btnBack.alpha = 1;
                         _loginView.x = self.view.width/2 - _loginView.width/2;
                         _loginView.alpha = 1;

                         _bottomView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [_inputEmail becomeFirstResponder];
                         
                     }];
    
}

- (IBAction)doForgot:(id)sender {
    
    if(![_inputEmail.text isEmail]){
        [[AppController sharedInstance] showAlertWithTitle:@"Email required" andMessage:@"Please enter a valid email address"];
        return;
    }

    
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Sending" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    [[AppController sharedInstance] hideKeyboard];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"email":_inputEmail.text}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForForgotPass:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [[AppController sharedInstance] showAlertWithTitle:@"" andMessage:@"We have emailed your password"];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];

    
    
}
- (IBAction)doBack {
    
    [[AppController sharedInstance] hideKeyboard];
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _btnBack.alpha = 0;
                         _loginView.alpha = 0;
                         _topView.y = self.view.height/2 - _topView.height/2;
                         _bottomView.alpha = 1;
                     } completion:^(BOOL finished) {
                         
                     }];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _inputEmail){
        [_inputPass becomeFirstResponder];
    }else{
        [self sendLoginToServer];
    }
    return NO;
}

-(void)sendLoginToServer{
    if(![_inputEmail.text isEmail]){
        [[AppController sharedInstance] showAlertWithTitle:@"Email required" andMessage:@"Please enter a valid email address"];
        return;
    }
    
    if([_inputPass.text length] < 6){
        [[AppController sharedInstance] showAlertWithTitle:@"Password Length" andMessage:@"Please enter a password of 6 or more characters"];
        return;
    }
    
    
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Sending" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    [[AppController sharedInstance] hideKeyboard];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"email":_inputEmail.text,@"pass":_inputPass.text}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForLogin:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [AppController sharedInstance].currentUser = [[AppUser alloc] initWithDictionary:[responseObject objectForKey:@"user"]];
            [[AppController sharedInstance].currentUser setupPlansWithDictionary:responseObject];
            [AppController sharedInstance].currentUser.token = [[responseObject objectForKey:@"user"] objectForKey:@"token"];
            [[AppController sharedInstance].currentUser saveUserData];
            [[AppController sharedInstance] routeToDashboard];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
    
}



-(void)doLoginWithToken{
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"token":@"31456b616c744762745a56644b5a565a79683356616846617945325678514655754a6c5653646b574756564f776f485a705a6c62536c3361735632566f746d56"}];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForLoginWithToken:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_longLoadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [AppController sharedInstance].currentUser = [[AppUser alloc] initWithDictionary:[responseObject objectForKey:@"user"]];
            [[AppController sharedInstance].currentUser setupPlansWithDictionary:responseObject];
            [AppController sharedInstance].currentUser.token = [[responseObject objectForKey:@"user"] objectForKey:@"token"];
            [[AppController sharedInstance].currentUser saveUserData];
            [[AppController sharedInstance] routeToDashboard];
        }else{
            [[AppController sharedInstance].currentUser removeAllData];
            _didLayout = NO;
            [self layoutUI];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_longLoadingScreen removeFromSuperview];
        UIAlertView  *av = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Unable to connect, please check your network connection." delegate:self cancelButtonTitle:@"Logout" otherButtonTitles:@"Try Again", nil];
        av.tag = 999;
        [av show];
    }];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            [[AppController sharedInstance].currentUser removeAllData];
            _didLayout = NO;
            [self layoutUI];
            }
            break;
        case 1:{
            [self doLoginWithToken];
        }
            break;
            
        default:
            break;
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification{
    
    
        CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        int padding = 30;
        float offset = ((self.view.height - kbSize.height)/2) - (_topView.height+_loginView.height + padding)/2;
        float offsetInput = offset + _topView.height + padding;
        [_loginView.layer removeAllAnimations];
        [_topView.layer removeAllAnimations];
    
        [UIView animateWithDuration: 0.15
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             _loginView.y = offsetInput;
                             _topView.y = offset;

                         }
                         completion:^(BOOL finished){}];

    
}


- (IBAction)doShowPass:(UIButton *)sender{
    
    if(sender == _btnEye){
        _inputPass.secureTextEntry = NO;
        _btnEye.hidden = YES;
        _btnEye2.hidden = NO;
    }else{
        _inputPass.secureTextEntry = YES;
        _btnEye.hidden = NO;
        _btnEye2.hidden = YES;
    }
    [_inputPass becomeFirstResponder];
    
}
@end
