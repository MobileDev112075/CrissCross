//
//  AppJoinViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppJoinViewController.h"
#import "AppFindFriendViewController.h"

#define kAppStaticCellNameHomeTown @"kAppStaticCellNameHomeTown"

@interface AppJoinViewController ()

@end

@implementation AppJoinViewController


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)layoutUI{
    
    if(!_didLayout){
        
        self.view.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        
        _didLayout = YES;
        _avatarChanged = NO;
        _previousResults = [[NSMutableDictionary alloc] init];
        _topnav.view.backgroundColor = [UIColor clearColor];
        _topnav.theTitle.textColor = [UIColor whiteColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _topnav.view.height, self.view.width, self.view.height - _topnav.view.height)];
        _scrollView.backgroundColor = [UIColor clearColor];
        
        _locationSelectionView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _locationSelectionView.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];

        UIView *viewUpper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, roundf(self.view.height * 0.20))];
        viewUpper.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        
        _inputSearch = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, roundf(viewUpper.height * 0.60) - 20)];
        _inputSearch.delegate = self;
        _inputSearch.textAlignment = NSTextAlignmentCenter;
        _inputSearch.textColor = [UIColor whiteColor];
        _inputSearch.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:roundf(_inputSearch.height * 0.50)];
        _inputSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter City" attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:_inputSearch.font.pointSize], NSForegroundColorAttributeName : [[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.5]}];
        
        _inputSearch.x = 20;
        _inputSearch.width = viewUpper.width - 40;
        _inputSearch.y = viewUpper.height - _inputSearch.height;
        _inputSearch.adjustsFontSizeToFitWidth = YES;
        [viewUpper addSubview:_inputSearch];
        [_locationSelectionView addSubview:viewUpper];
        
        _tableViewSearch = [[UITableView alloc] initWithFrame:CGRectMake(0, viewUpper.maxY, self.view.width, self.view.height - viewUpper.maxY)];
        _tableViewSearch.backgroundColor = [UIColor clearColor];
        _tableViewSearch.delegate = self;
        _tableViewSearch.dataSource = self;
        _tableViewSearch.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIButton *btnCancelCityView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [btnCancelCityView setTitle:@"Cancel" forState:UIControlStateNormal];
        btnCancelCityView.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:12];
        [btnCancelCityView sizeToFit];
        btnCancelCityView.x = viewUpper.width - btnCancelCityView.width - 10;
        btnCancelCityView.y = 30;
        [btnCancelCityView addTarget:self action:@selector(doSearchCancel) forControlEvents:UIControlEventTouchDown];
        [viewUpper addSubview:btnCancelCityView];
        
        
        [_locationSelectionView addSubview:_tableViewSearch];
        
        _inputEmail = [[UITextField alloc] init];
        _inputPass = [[UITextField alloc] init];
        _inputPass2 = [[UITextField alloc] init];
        
        _inputPass.secureTextEntry = _inputPass2.secureTextEntry = YES;
        
        _inputPhone = [[UITextField alloc] init];
        _btnContinue = [[UIButton alloc] init];
        _topImage = [[UIImageView alloc] init];
        _inputUsername = [[UITextField alloc] init];
        _inputFirstName = [[UITextField alloc] init];
        _inputLastName = [[UITextField alloc] init];
        _inputHomeCity = [[UITextField alloc] init];
        
        _viewFirstStep = [[UIView alloc] init];
        _viewSecondStep = [[UIView alloc] init];
        
        
        float ratio = 320.0/150.0;
        _topImage.width = self.view.width;
        _topImage.height = _topImage.width/ratio;
        [self.view addSubview:_topImage];
        _topImage.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0];
        _topImage.alpha = 1;
        
        
        UIView *viewGradient = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _topImage.height)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = viewGradient.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0] CGColor],
                           (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.5] CGColor],
                           (id)[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] CGColor], nil];
        [viewGradient.layer insertSublayer:gradient atIndex:0];
        
        UIView *viewGradient2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, _topImage.height)];
        CAGradientLayer *gradient2 = [CAGradientLayer layer];
        gradient2.frame = viewGradient2.bounds;
        gradient2.colors = [NSArray arrayWithObjects:
                            (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.2] CGColor],
                            (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.1] CGColor],
                            nil];
        [viewGradient2.layer insertSublayer:gradient2 atIndex:0];

        
        [self.view addSubview:viewGradient];
        [self.view addSubview:viewGradient2];
        
        
        
        [self.view addSubview:_scrollView];
        [self.view addSubview:_topnav.view];
        
        _btnCam = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _btnCam.titleLabel.font = [UIFont fontWithName:FONT_ICONS size:roundf(_btnCam.height * 0.50)];
        _btnCam.width += 100;
        _btnCam.x = roundf(self.view.width/2 - _btnCam.width/2);
        [_btnCam setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
        [_btnCam setTitle:@"C" forState:UIControlStateNormal];
        _btnCam.contentEdgeInsets = UIEdgeInsetsMake(-_btnCam.height/2, 0, 0, 0);
        [_btnCam addTarget:self action:@selector(changePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:_btnCam];
        
        _btnCamLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _btnCam.width, 20)];
        _btnCamLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:11];
        _btnCamLabel.text = @"Add Photo";
        _btnCamLabel.textAlignment = NSTextAlignmentCenter;
        [_btnCamLabel sizeToFit];
        _btnCamLabel.width = _btnCam.width;
        _btnCamLabel.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
        _btnCamLabel.x = roundf(_btnCam.width/2 - _btnCamLabel.width/2);
        _btnCamLabel.y = roundf(_btnCam.height/2);
        _btnCamLabel.userInteractionEnabled = NO;
        
        [_btnCam addSubview:_btnCamLabel];
        
        NSArray *sections = @[
                              @{@"page":@"Yes",@"children":@[
                                  
                                  @{@"title":@"Email",@"obj":_inputEmail},
                                  @{@"title":@"Password",@"obj":_inputPass},
                                  @{@"title":@"Confirm Password",@"obj":_inputPass2},
                                  ]
                                },
                              @{@"page":@"Yes",@"children":@[
                                        
                                        @{@"title":@"First Name",@"obj":_inputFirstName},
                                        @{@"title":@"Last Name",@"obj":_inputLastName},
                                        @{@"title":@"Phone Number|(optional)",@"obj":_inputPhone},
                                        @{@"title":@"What city do you live in?",@"obj":_inputHomeCity},
                                        @{@"title":@"Username",@"obj":_inputUsername},
                                        ]
                                }
                              ];
        
        
        float rowHeight = roundf((self.view.height/2.0)/6.0);
        int startingY = 0;
        int startingX = 0;
        float rowWidth = roundf(self.view.width * 0.90);
        NSArray *views = @[_viewFirstStep,_viewSecondStep];
        int count = 0;
        
        for(NSDictionary *topD in sections){

            UIView *currentView = [views objectAtIndex:count];
            
            for(NSDictionary *d in [topD objectForKey:@"children"]){
                UIView *row = [[UIView alloc] initWithFrame:CGRectMake(startingX, startingY, rowWidth, rowHeight)];
                [currentView addSubview:row];
                
                UITextField *input = [d objectForKey:@"obj"];
                input.width = rowWidth;
                input.height = rowHeight;
                input.tintColor = [UIColor whiteColor];
                input.textColor = [UIColor whiteColor];
                
                input.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:roundf(input.height * 0.35)];
                
                if(input == _inputEmail) {
                    input.keyboardType = UIKeyboardTypeEmailAddress;
                }
                
                if(input == _inputPhone) {
                    input.keyboardType = UIKeyboardTypePhonePad;
                    
                    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:input.font.pointSize], NSFontAttributeName,
                                           [[UIColor colorWithHexString:@"#CCCCCC"] colorWithAlphaComponent:0.8 ], NSForegroundColorAttributeName, nil];
                    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:input.font.pointSize - 8], NSFontAttributeName,
                                              [[UIColor colorWithHexString:@"CCCCCC"] colorWithAlphaComponent:1], NSForegroundColorAttributeName,nil];
                    NSString *str = [d objectForKey:@"title"];
                    NSRange range = [str rangeOfString:@"|"];
                    str = [str stringByReplacingOccurrencesOfString:@"|" withString:@" "];
                    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:str attributes:attrs];
                    [attributedText setAttributes:subAttrs range: NSMakeRange(range.location,str.length - range.location)];
                    input.attributedPlaceholder = attributedText;
                    
                }else{
                
                    input.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[d objectForKey:@"title"] attributes:@{ NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:input.font.pointSize], NSForegroundColorAttributeName : [[UIColor colorWithHexString:@"#CCCCCC"] colorWithAlphaComponent:0.8 ] }];
                }
                
                input.delegate = self;
                input.autocorrectionType = UITextAutocorrectionTypeNo;
                row.x = roundf(self.view.width/2 - row.width/2);
                
                if(input == _inputHomeCity){
                    UIButton *btnHitArea = [[UIButton alloc] initWithFrame:input.frame];
                    [btnHitArea addTarget:self action:@selector(doChangeHomeTown) forControlEvents:UIControlEventTouchUpInside];
                    [row addSubview:btnHitArea];
                }
                
                if(input == _inputFirstName){
                    row.width = roundf(rowWidth/2);
                    startingX = roundf(rowWidth/2);
                    input.width = roundf(rowWidth/2) - 10;
                    row.x = roundf((self.view.width - rowWidth)/2);
                }else{
                    
                    if(input == _inputLastName){
                        row.width = rowWidth/2;
                        startingX = rowWidth/2;
                        input.width = rowWidth/2;
                        row.x = roundf(self.view.width/2);
                    }
                    startingX = 0;
                    startingY += rowHeight;
                }
                
                
                UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, rowHeight - 0.5, input.width, 0.5)];
                line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
                [row addSubview:line];
                [row addSubview:input];
            }
            
            UIButton *btnContinue = [[UIButton alloc] initWithFrame:CGRectMake(0, startingY, rowWidth, rowHeight)];
            [btnContinue setTitle:@"Continue" forState:UIControlStateNormal];
            [btnContinue setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnContinue.tag = count;
            [btnContinue addTarget:self action:@selector(doGoToPage:) forControlEvents:UIControlEventTouchUpInside];
            btnContinue.x = roundf(self.view.width/2 - btnContinue.width/2);
            [currentView addSubview:btnContinue];
            
            [_scrollView addSubview:currentView];
            currentView.width = _scrollView.width;
            currentView.height = btnContinue.maxY;
            currentView.y = _btnCam.height;
            currentView.x = self.view.width  * count++;
            startingY = 0;
        }
        
        if(_isResuming){
            [self gotoSecondStep];
            _inputFirstName.text = [AppController sharedInstance].currentUser.firstname;
            _inputLastName.text = [AppController sharedInstance].currentUser.lastname;
            if([AppController sharedInstance].currentUser.imgData != nil){
                _topImage.image = [[UIImage alloc] initWithData:[AppController sharedInstance].currentUser.imgData];
            }else{
                [_topImage setImageWithURL:[NSURL URLWithString:[AppController sharedInstance].currentUser.img]];
            }
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Welcome Back!" message:@"Please complete your profile" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [av show];
        }else{
            [_inputEmail becomeFirstResponder];
        }

    }
    
}

-(void)doGoToPage:(UIButton *)btn{
    int idx = (int) btn.tag;
    if(idx == 0){
        [self doContinue];
    }else if(idx == 1){
        [self doSave];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == _inputHomeCity){
        [self doChangeHomeTown];
        return;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == _inputSearch){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doSearchWithTerm:_inputSearch.text];
        });
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(textField == _inputEmail){
        [_inputPass becomeFirstResponder];
    }else if(textField == _inputPass){
        [_inputPass2 becomeFirstResponder];
    }else if(textField == _inputUsername){
        [[AppController sharedInstance] hideKeyboard];
        [self doSave];
    }else if(textField == _inputFirstName){
        [_inputLastName becomeFirstResponder];
    }else if(textField == _inputLastName){
        [_inputPhone becomeFirstResponder];
    }else if(textField == _inputPhone){
        [self doChangeHomeTown];
        return NO;
    }else if(textField == _inputPass2){
        [[AppController sharedInstance] hideKeyboard];
        [self doContinue];
    }else if(textField == _inputHomeCity){
        [self doChangeHomeTown];
        return NO;
    }
    return YES;
    return NO;
    
}

- (IBAction)changePhoto:(id)sender {
    if(!_imagePicker){
        _imagePicker = [[VTImagePicker alloc] init];
        _imagePicker.delegateViewController = self;
    }
    
    [_imagePicker presentPhotoPicker];
}

- (IBAction)doContinue {
    [self sendToServer];
}

- (IBAction)doSave {
    [self updateUserProfile];
}


- (void)imagePickedForAvatarPreview:(UIImage *)image{
    
    if(_imageCropController != nil){
        _imageCropController = nil;
    }
    _imageCropController = [[ImageCropViewController alloc] initWithImage:image];
    _imageCropController.delegate = self;
    _imageCropController.blurredBackground = YES;
    [[self navigationController] pushViewController:_imageCropController animated:NO];
    
}

- (void)imagePickedForAvatar:(UIImage *)image{

}

- (void)ImageCropViewController:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    UIImage *im = croppedImage;
    _topImage.image = im;
    _avatarChanged = YES;
    _btnCamLabel.text = @"Change Photo";
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    [[self navigationController] popViewControllerAnimated:YES];
}




-(void)sendToServer{
    
    if(![_inputEmail.text isEmail]){
        [[AppController sharedInstance] showAlertWithTitle:@"Email required" andMessage:@"Please enter a valid email address"];
        [_inputEmail becomeFirstResponder];
        return;
    }
    
    if([_inputPass.text length] < 6){
        [[AppController sharedInstance] showAlertWithTitle:@"Password Length" andMessage:@"Please enter a password of 6 or more characters"];
        [_inputPass becomeFirstResponder];
        return;
    }
    
    if(![_inputPass.text isEqualToString:_inputPass2.text]){
        [[AppController sharedInstance] showAlertWithTitle:@"Password do not match" andMessage:@"Please re-enter your password"];
        [_inputPass becomeFirstResponder];
        return;
    }
    
    if(!_avatarChanged){
        [[AppController sharedInstance] showAlertWithTitle:@"You forgot to add a photo!" andMessage:@"Add a photo to continue"];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    
    
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Sending" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    [[AppController sharedInstance] hideKeyboard];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"email":_inputEmail.text,@"pass":_inputPass.text}];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForSignUp:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [AppController sharedInstance].currentUser = [[AppUser alloc] initWithDictionary:[responseObject objectForKey:@"user"]];
            [AppController sharedInstance].currentUser.token = [[responseObject objectForKey:@"user"] objectForKey:@"token"];
            [[AppController sharedInstance].currentUser saveUserData];
            [self gotoSecondStep];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
}

-(void)updateUserProfile{
    
    
    if([_inputUsername.text isEmpty] || [_inputUsername.text length] < 1){
        [[AppController sharedInstance] showAlertWithTitle:@"Username Required" andMessage:@"Please enter a username"];
        [_inputUsername becomeFirstResponder];
        return;
    }
    if([_inputHomeCity.text isEmpty] || [_inputHomeCity.text length] < 1){
        [[AppController sharedInstance] showAlertWithTitle:@"Where you live is Required" andMessage:@"Please enter a city"];
        return;
    }
    if([_inputFirstName.text isEmpty] || [_inputFirstName.text length] < 1){
        [[AppController sharedInstance] showAlertWithTitle:@"First Name Required" andMessage:@"Please enter your first name"];
        [_inputFirstName becomeFirstResponder];
        return;
    }
    if([_inputLastName.text isEmpty] || [_inputLastName.text length] < 1){
        [[AppController sharedInstance] showAlertWithTitle:@"Last Name Required" andMessage:@"Please enter your last name"];
        [_inputLastName becomeFirstResponder];
        return;
    }
    
    if([_inputPhone.text isEmpty]){
        if(!_didPhonePrompt){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Phone Number" message:@"Adding your phone number is the best way to connect with your friends!" delegate:self cancelButtonTitle:@"Add Number" otherButtonTitles:@"Continue Without Adding", nil];
            av.tag = 333;
            [av show];
            [[AppController sharedInstance] hideKeyboard];
            _didPhonePrompt = YES;
            return;
        }
    }
    
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Sending" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    [[AppController sharedInstance] hideKeyboard];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                   @"token":[AppController sharedInstance].currentUser.token,
                                   @"username":_inputUsername.text,
                                   @"phone":_inputPhone.text,
                                   @"hometown_obj":_selectedHomeTown,
                                   @"firstname":_inputFirstName.text,
                                   @"lastname":_inputLastName.text}];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    NSData *data = UIImageJPEGRepresentation(_topImage.image, 1.0f);
    
    [AppController sharedInstance].currentUser.imgData = data;
    [manager POST:[AppAPIBuilder APIForPostAvatarAndInfo:nil] parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if(_avatarChanged)
            [formData appendPartWithFileData:data name:@"file" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){

            [AppController sharedInstance].currentUser.firstname = _inputFirstName.text;
            [AppController sharedInstance].currentUser.lastname = _inputLastName.text;
            [AppController sharedInstance].currentUser.phone = _inputPhone.text;
            [AppController sharedInstance].currentUser.name = [NSString stringWithFormat:@"%@ %@",_inputFirstName.text,_inputLastName.text];
            [[AppController sharedInstance].currentUser saveUserData];
            [[AppController sharedInstance] routeToFirstStepAddContacts];
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _topImage.image = nil;
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to save Photo, please try again."];
    }];
}

-(void)gotoSecondStep{

    _viewSecondStep.x = _scrollView.width;
    _topnav.btnBack.hidden = YES;
    [_inputFirstName becomeFirstResponder];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _viewFirstStep.x = -self.view.width;
                         _viewSecondStep.x = 0;
                     } completion:^(BOOL finished) {
                         
                     }];
}










#pragma mark search



-(void)doSearchWithTerm:(NSString *)searchText{
    
    _searchActive = YES;
    
    if([searchText isEmpty]){
        _searchActive = NO;
        [_tableViewSearch reloadData];
    }else{
        [self performStringGeocode:searchText];
    }
}

- (void)doSearchCancel{
    [[AppController sharedInstance] hideKeyboard];
    _inputSearch.text = @"";
    _searchActive = NO;
    [_tableViewSearch reloadData];
    [self hideSearchView];
}







-(void)showSearchView{
    self.canLeaveWithSwipe = NO;
    _topnav.btnBack.hidden = YES;

    _locationSelectionView.width = self.view.width;
    _locationSelectionView.y = 0;
    _locationSelectionView.height = self.view.height;
    _locationSelectionView.alpha = 0;
    [self.view addSubview:_locationSelectionView];
    
    
    [UIView animateWithDuration:0.2 animations:^{
        _locationSelectionView.alpha = 1;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_inputSearch becomeFirstResponder];
    });
    
}
-(void)hideSearchView{
    _topnav.btnBack.hidden = NO;
    self.canLeaveWithSwipe = YES;
    [[AppController sharedInstance] hideKeyboard];
    [_locationSelectionView removeFromSuperview];
    [_scrollView setContentOffset:CGPointMake(0, 0)];
}

-(void)processSearchResult:(NSDictionary *)dict overrideTicket:(BOOL)override{
    
    NSString *ticket = [NSString returnStringObjectForKey:@"ticket" withDictionary:dict];
    
    if(override || [ticket isEqualToString:[NSString stringWithFormat:@"%d",_lastTicket]]){
        [_searchItems removeAllObjects];
        _searchItems = [NSMutableArray arrayWithArray:[dict objectForKey:@"data"]];
        [_tableViewSearch reloadData];
    }
    
}

- (void)performStringGeocode:(NSString *)str{
    
    if(_searchManager){
        [_searchManager.operationQueue cancelAllOperations];
    }
    if([_previousResults objectForKey:str] != nil){
        [self processSearchResult:[_previousResults objectForKey:str] overrideTicket:YES];
    }else{
        NSDictionary *dict = @{@"query":str,@"ticket":[NSString stringWithFormat:@"%d",++_lastTicket]};
        _searchManager = [AFHTTPRequestOperationManager manager];
        _searchManager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [_searchManager POST:[AppAPIBuilder APIForSearchCity:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            responseObject = [VTUtils processResponse:responseObject];
            if([VTUtils isResponseSuccessful:responseObject]){
                NSString *term = [NSString returnStringObjectForKey:@"term" withDictionary:responseObject];
                [_previousResults setObject:responseObject forKey:term];
                [self processSearchResult:responseObject overrideTicket:NO];
            }else{
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }
}


- (IBAction)doChangeHomeTown{
    [self showSearchView];
}
- (IBAction)doClose{
    [self hideSearchView];
}


#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_searchItems count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppStaticCellNameHomeTown];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppStaticCellNameHomeTown];
    }
    
    NSDictionary *dict = [_searchItems objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:15];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == _tableViewSearch){
        _selectedHomeTown = [_searchItems objectAtIndex:indexPath.row];
        _inputHomeCity.text = [NSString returnStringObjectForKey:@"title" withDictionary:_selectedHomeTown];
        [self hideSearchView];
        [_inputUsername becomeFirstResponder];
        [_searchItems removeAllObjects];
        [_tableViewSearch reloadData];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification{
    CGSize kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if([self.view.subviews containsObject:_locationSelectionView]){
        float newHeight = self.view.height - kbSize.height - _tableViewSearch.y;
        [UIView animateWithDuration: 0.15
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             _tableViewSearch.height = newHeight;
                         }
                         completion:^(BOOL finished){}];
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 333){
        if(buttonIndex == 1){
            [[AppController sharedInstance] hideKeyboard];
            [self updateUserProfile];
        }else{
            [_inputPhone becomeFirstResponder];
        }
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification{
}




@end