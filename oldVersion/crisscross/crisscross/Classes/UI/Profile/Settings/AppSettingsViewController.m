//
//  AppSettingsViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "AppAddGroupsViewController.h"
#import "AppCustomGroupsViewController.h"
#import "AppFriendsInGroupViewController.h"
#import "AppGenericViewController.h"

#define kAppStaticCellNameHomeTown @"kAppStaticCellNameHomeTown"

@interface AppSettingsViewController ()

@end

@implementation AppSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchItems = [[NSMutableArray alloc] init];
    _previousResults = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUpdated) name:NOTIFICATION_USER_INFO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userGroupsUpdated) name:NOTIFICATION_USER_GROUPS_UPDATED object:nil];
    
    self.view.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    
    
    _inputFirstName = [[UITextField alloc] init];
    _inputFirstName.returnKeyType = UIReturnKeyNext;
    _inputLastName = [[UITextField alloc] init];
    _inputLastName.returnKeyType = UIReturnKeyNext;
    
    _inputPhone = [[UITextField alloc] init];
    _inputPhone.returnKeyType = UIReturnKeyNext;
    _inputPhone.keyboardType = UIKeyboardTypePhonePad;
    _inputPhone.delegate = self;
    
    _inputUsername = [[UITextField alloc] init];
    _inputUsername.returnKeyType = UIReturnKeyDone;
    _inputHomeTown = [[UITextField alloc] init];
    _segmentNotifications = [[UISegmentedControl alloc] initWithItems:@[@"On",@"Off"]];
    _segmentVisibility = [[UISegmentedControl alloc] initWithItems:@[@"Private",@"Public"]];
    _segmentDegrees = [[UISegmentedControl alloc] initWithItems:@[@"°C",@"°F"]];

    [_segmentNotifications addTarget:self action:@selector(doSave) forControlEvents:UIControlEventValueChanged];
    [_segmentVisibility addTarget:self action:@selector(doSave) forControlEvents:UIControlEventValueChanged];
    [_segmentDegrees addTarget:self action:@selector(doSave) forControlEvents:UIControlEventValueChanged];
    
    _sectionObjects = @[
                        @[
                            @{@"children":@[
                                      @{@"title":@"First Name",@"input":_inputFirstName},
                                      @{@"title":@"Last Name",@"input":_inputLastName}
                                      ]
                              },
                            
                            
                            @{@"title":@"Phone",@"input":_inputPhone},
                            @{@"title":@"Where do you live?",@"input":_inputHomeTown},
                            @{@"title":@"Username",@"input":_inputUsername},
                            @{@"children":@[
                                        @{@"title":@"Notifications",@"segment":_segmentNotifications},
                                        @{@"title":@"Search Visibility",@"segment":_segmentVisibility},
                                        @{@"title":@"Degrees",@"segment":_segmentDegrees}
                                        ]
                              },
                            @{@"title":@"Manage Groups",@"isLast":@"Y"},
                            @{@"title":@"Change Password",@"isPass":@"Y"}
                            ]
                        
                        ];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[AppController sharedInstance].currentUser refreshUserDataFromServer];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)userGroupsUpdated{
    [self buildGroupsScrollView];
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
        [_topnav.view removeFromSuperview];
        
        float imageRatio = 320/150;
        _userImage.height = self.view.width/imageRatio;
        _userImage.alpha = 0.7;
        
        if([AppController sharedInstance].currentUser.imgData != nil){
            _userImage.image = [[UIImage alloc] initWithData:[AppController sharedInstance].currentUser.imgData];
        }else{
            [_userImage setImageWithURL:[NSURL URLWithString:[AppController sharedInstance].currentUser.img] placeholderImage:[AppController sharedInstance].personImageIcon];
        }
        
        _userImage.clipsToBounds = YES;
        
        _viewGradient = [[UIView alloc] initWithFrame:CGRectMake(0, _userImage.height - 60, _userImage.width, 60)];
        _viewGradient2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _userImage.width, _userImage.height)];
        _viewCurtain = [[UIView alloc] initWithFrame:CGRectMake(0, _userImage.height, _userImage.width, _userImage.height)];
        _viewCurtain.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
        
        
        _viewCurtainAbove = [[UIView alloc] initWithFrame:CGRectMake(0, -200, _userImage.width, 200)];
        _viewCurtainAbove.backgroundColor = [[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.5];
        

        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _viewGradient.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0] CGColor],
                           (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.5] CGColor],
                           (id)[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] CGColor], nil];
        [_viewGradient.layer insertSublayer:gradient atIndex:0];
        
        CAGradientLayer *gradient2 = [CAGradientLayer layer];
        gradient2.frame = _viewGradient2.bounds;
        gradient2.colors = [NSArray arrayWithObjects:
                            (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.5] CGColor],
                           (id)[[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] colorWithAlphaComponent:0.5] CGColor],
                           (id)[[UIColor colorWithHexString:COLOR_CC_BLUE_BG] CGColor], nil];
        [_viewGradient2.layer insertSublayer:gradient2 atIndex:0];
        [self.view insertSubview:_viewGradient2 belowSubview:_scrollView];
        
        _scrollView.delegate = self;
        
        [_scrollView insertSubview:_viewGradient atIndex:0];
        [_scrollView insertSubview:_viewCurtain atIndex:1];
        [_scrollView insertSubview:_viewCurtainAbove atIndex:2];
        [_scrollView insertSubview:_btnHitArea atIndex:3];
        
        
        _inputUsername.adjustsFontSizeToFitWidth = YES;
        _inputFirstName.adjustsFontSizeToFitWidth = YES;
        _inputLastName.adjustsFontSizeToFitWidth = YES;
        _inputHomeTown.adjustsFontSizeToFitWidth = YES;
        _inputPhone.adjustsFontSizeToFitWidth = YES;

        _inputUsername.text = [AppController sharedInstance].currentUser.username;
        _inputFirstName.text = [AppController sharedInstance].currentUser.firstname;
        _inputLastName.text = [AppController sharedInstance].currentUser.lastname;
        _inputHomeTown.text = [AppController sharedInstance].currentUser.homeTown;
        _inputPhone.text = [AppController sharedInstance].currentUser.phone;

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
        
        


        
        [_scrollView setContentSize:CGSizeMake(_scrollView.width,_btnSave.maxY + 30)];
        
        int startingY = _userImage.maxY - _userImage.height*.15;
        int startingX = 20;
        int rowHeight = (self.view.height - startingY)/8;
        for(NSArray *arr in _sectionObjects){
            
                for(NSDictionary *dict in arr){
                    
                        if([dict objectForKey:@"children"] != nil){
                            
                            int subX = startingX;
                            int subWidth = self.view.width/[[dict objectForKey:@"children"] count];
                            for(NSDictionary *subDict in [dict objectForKey:@"children"]){
                                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(subX, startingY, subWidth, rowHeight*.50)];
                                l.text = [NSString returnStringObjectForKey:@"title" withDictionary:subDict];
                                l.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
                                l.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:12];
                                [_scrollView addSubview:l];
                                
                                if([subDict objectForKey:@"segment"] != nil){
                                    UISegmentedControl *segment = [subDict objectForKey:@"segment"];
                                    segment.x = subX;
                                    segment.tintColor = [UIColor whiteColor];
                                    segment.width = roundf(subWidth*.75);
                                    segment.height = rowHeight*.4;
                                    segment.y = startingY + rowHeight/2;
                                    [_scrollView addSubview:segment];
                                    
                                }else if([subDict objectForKey:@"input"] != nil){
                                    UITextField *input = [subDict objectForKey:@"input"];
                                    
                                    input.x = subX;
                                    input.y = startingY;
                                    input.textColor = [UIColor whiteColor];
                                    input.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:24];
                                    input.width = roundf(subWidth*.75);
                                    input.delegate = self;
                                    input.autocorrectionType = UITextAutocorrectionTypeNo;
                                    input.height = rowHeight*1.2;
                                    [_scrollView addSubview:input];
                                }
                                
                                subX += subWidth;
                            }
                            
                        }else if([dict objectForKey:@"isLast"] != nil){
                            
                            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(startingX, startingY, _scrollView.width, rowHeight*.50)];
                            l.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
                            l.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
                            l.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:12];
                            [_scrollView addSubview:l];
                            
                            
                            UIButton *addGroup = [[UIButton alloc] initWithFrame:CGRectMake(0, startingY, 100, rowHeight)];
                            [addGroup setTitle:@"Add Group" forState:UIControlStateNormal];
                            [addGroup setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
                            addGroup.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:12];
                            [addGroup sizeToFit];
                            addGroup.height = rowHeight;
                            addGroup.width += 10;
                            [addGroup setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
                            addGroup.x = _scrollView.width - addGroup.width - 10;
                            [addGroup addTarget:self action:@selector(addGroupTapped) forControlEvents:UIControlEventTouchUpInside];
                            [_scrollView addSubview:addGroup];
                            
                            _groupsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, startingY, addGroup.x - 20, rowHeight)];
                            [_scrollView addSubview:_groupsScrollView];
                            [self buildGroupsScrollView];
                            
                        }else if([dict objectForKey:@"isPass"] != nil){
                            rowHeight -= 10;
                            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(startingX, startingY, 100, rowHeight)];
                            [btn setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
                            [btn setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
                            btn.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:12];
                            [btn sizeToFit];
                            btn.height = rowHeight;
                            btn.width += 10;
                            btn.x = 15;
                            [btn addTarget:self action:@selector(changePassTapped) forControlEvents:UIControlEventTouchUpInside];
                            [_scrollView addSubview:btn];
                            
                            UIButton *btnTerms = [[UIButton alloc] initWithFrame:CGRectMake(startingX, startingY, 100, rowHeight)];
                            [btnTerms setTitle:@"View Terms" forState:UIControlStateNormal];
                            [btnTerms setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
                            btnTerms.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:12];
                            [btnTerms sizeToFit];
                            btnTerms.height = rowHeight;
                            btnTerms.width += 10;
                            btnTerms.x = _scrollView.width - btnTerms.width - 10;
                            [btnTerms addTarget:self action:@selector(doViewTerms) forControlEvents:UIControlEventTouchUpInside];
                            [_scrollView addSubview:btnTerms];
                            
                        }else{
                    
                            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(startingX, startingY, _scrollView.width, rowHeight*.50)];
                            l.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
                            l.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
                            l.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:12];
                            [_scrollView addSubview:l];
                        
                            if([dict objectForKey:@"input"] != nil){
                                UITextField *input = [dict objectForKey:@"input"];
                                
                                input.x = startingX;
                                input.y = startingY;
                                input.textColor = [UIColor whiteColor];
                                input.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:24];
                                input.width = _scrollView.width - startingX;
                                input.delegate = self;
                                input.autocorrectionType = UITextAutocorrectionTypeNo;
                                input.height = rowHeight*1.2;
                                [_scrollView addSubview:input];
                            }
                        }
                    
                        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(startingX, startingY + rowHeight, _scrollView.width, 0.5)];
                        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
                        [_scrollView addSubview:line];
                        startingY += rowHeight;
                    }
                    
            
        }
        
        int playArea = _segmentDegrees.x - _segmentNotifications.maxX;
        _segmentVisibility.width = playArea - 20;
        _segmentVisibility.x = _segmentNotifications.maxX +  playArea/2 - _segmentVisibility.width/2;
        
        
        _btnLogout.y = startingY + 20;
        if((_btnLogout.y + _btnLogout.height + 50) < self.view.height){
            _btnLogout.y = self.view.height - _btnLogout.height;
        }
        _btnLogout.x = _scrollView.width/2 - _btnLogout.width/2;
        [_scrollView setContentSize:CGSizeMake(self.view.width, _btnLogout.maxY)];
        
        _btnSave.hidden = YES;
        _btnSave.y = _scrollView.height - _btnSave.height;
        
        _viewCurtain.height = _scrollView.contentSize.height;
        
        _scrollView.width = self.view.width;
        _btnHitArea.x = self.view.width - _btnHitArea.width;
        _btnHitArea.y = 28;
        [_scrollView addSubview:_btnHitArea];
        
        _btnBack.x = 0;
        _btnBack.y = 30;
        [_scrollView addSubview:_btnBack];
        
        [_segmentVisibility setSelectedSegmentIndex:([AppController sharedInstance].currentUser.isPrivate) ? 0 : 1];
        [_segmentNotifications setSelectedSegmentIndex:([AppController sharedInstance].currentUser.allowNotifications) ? 0 : 1];
        [_segmentDegrees setSelectedSegmentIndex:([[AppController sharedInstance].currentUser.degrees isEqualToString:@"C"]) ? 0 : 1];

    }
}

-(void)buildGroupsScrollView{
    
    int startingY = _userImage.maxY - _userImage.height*.15;
    int rowHeight = (self.view.height - startingY)/8;
    
    [_groupsScrollView removeAllSubviews];
    
    int startingBtnX = 20;
    int count = 0;
    
    for(AppGroup *group in [AppController sharedInstance].currentUser.groups){
        
        if(group.isAll){
            count++;
            continue;
        }
        
        if(group.isAdd){
            continue;
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(startingBtnX, 0, rowHeight/4, rowHeight)];
        btn.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:12];
        [btn setTitle:group.title forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.tag = count++;
        btn.width += 20;
        btn.height = rowHeight;
        startingBtnX += btn.width;
        [_groupsScrollView addSubview:btn];
        [btn addTarget:self action:@selector(groupBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *icon= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50,50)];
        icon.text = @"o";
        icon.textColor = [UIColor whiteColor];
        icon.font = [UIFont fontWithName:FONT_ICONS size:round(rowHeight*.20)];
        [icon sizeToFit];
        [btn addSubview:icon];
        [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, -icon.height*3, 0)];
        icon.y = rowHeight*.50;
        icon.x = btn.width/2 - icon.width/2;
    }
    [_groupsScrollView setContentSize:CGSizeMake(startingBtnX, _groupsScrollView.height)];
    [_groupsScrollView setContentOffset:CGPointMake(0, 0)];
    
}

-(void)changePassTapped{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Enter your new password, must have a lenght of 6 or more" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = @"";
    alert.tag = 11;
    [alert show];
}


-(void)doViewTerms{
    AppGenericViewController *vc = [[AppGenericViewController alloc] init];
    vc.pageInfo = @{@"title":@"Terms of Services",@"obj":@"",@"more":@"Y",@"genericType":@"terms"};
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
 

    if(buttonIndex == 1){
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        if([textField.text isEmpty] || [textField.text length] < 6){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You password must be 6 or more characters in length" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
        [dict setObject:[NSString base64Encode:textField.text] forKey:@"newpass"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [manager POST:[AppAPIBuilder APIForPostAvatarAndInfo:nil] parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
    }

}

-(void)groupBtnTapped:(UIButton *)btn{
    int idx = (int)btn.tag;
    AppGroup *group = [[AppController sharedInstance].currentUser.groups objectAtIndex:idx];
    
    AppFriendsInGroupViewController *vc = [[AppFriendsInGroupViewController alloc] initWithNibName:@"AppFriendsInGroupViewController" bundle:nil];
    vc.theGroup = group;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];

}

-(void)addGroupTapped{
    AppCustomGroupsViewController *vc = [[AppCustomGroupsViewController alloc] initWithNibName:@"AppCustomGroupsViewController" bundle:nil];
    vc.isManageView = YES;
    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == _inputHomeTown){
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
    if(textField == _inputFirstName){
        
        if([_inputFirstName.text isEmpty] || [_inputFirstName.text length] < 1){
            [[AppController sharedInstance] showAlertWithTitle:@"First Name Required" andMessage:@"Please enter your first name"];
            return NO;
        }
        
        [_inputLastName becomeFirstResponder];
        return NO;
    }else if(textField == _inputLastName){
        
        if([_inputLastName.text isEmpty] || [_inputLastName.text length] < 1){
            [[AppController sharedInstance] showAlertWithTitle:@"Last Name Required" andMessage:@"Please enter your last name"];
            return NO;
        }
        
        [_inputPhone becomeFirstResponder];
        return NO;
    }else if(textField == _inputUsername){
        
        if([_inputUsername.text isEmpty] || [_inputUsername.text length] < 1){
            [[AppController sharedInstance] showAlertWithTitle:@"Username Required" andMessage:@"Please enter a username"];
            return NO;
        }

        [[AppController sharedInstance] hideKeyboard];
        return NO;
    }
    return NO;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == _inputHomeTown){
        [self doChangeHomeTown];
        return NO;
    }
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self doSave];
}

-(void)userInfoUpdated{
    if([AppController sharedInstance].currentUser.imgData != nil){
        _userImage.image = [[UIImage alloc] initWithData:[AppController sharedInstance].currentUser.imgData];
    }else{
        [_userImage setImageWithURL:[NSURL URLWithString:[AppController sharedInstance].currentUser.img] placeholderImage:[AppController sharedInstance].personImageIcon];
    }
}

- (IBAction)doLogout{
    [[AppController sharedInstance] logout];
}

- (IBAction)doGoBack {
    [[AppController sharedInstance] goBack];
}



- (IBAction)changePhoto{
    if(!_imagePicker){
        _imagePicker = [[VTImagePicker alloc] init];
        _imagePicker.delegateViewController = self;
    }
    
    [_imagePicker presentPhotoPicker];
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
    _userImage.image = im;
    [[self navigationController] popViewControllerAnimated:YES];
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:
                                 @{
                                   @"token":[AppController sharedInstance].currentUser.token,
                                   @"justAvatar":@"Y"}];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    NSData *data = UIImageJPEGRepresentation(_userImage.image, 1.0f);
    
    [AppController sharedInstance].currentUser.imgData = data;

    [manager POST:[AppAPIBuilder APIForPostAvatarAndInfo:nil] parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_INFO_UPDATED object:nil];

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _userImage.image = nil;
    }];
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    [[self navigationController] popViewControllerAnimated:YES];
}




- (IBAction)doSave {
    
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:_inputUsername.text forKey:@"username"];
    [dict setObject:_inputFirstName.text forKey:@"firstname"];
    [dict setObject:_inputLastName.text forKey:@"lastname"];
    [dict setObject:_inputPhone.text forKey:@"phone"];
    [dict setObject:([_segmentVisibility selectedSegmentIndex] == 0) ? @"Y" : @"N" forKey:@"private"];
    [dict setObject:([_segmentNotifications selectedSegmentIndex] == 0) ? @"Y" : @"N" forKey:@"notifications"];
    [dict setObject:([_segmentDegrees selectedSegmentIndex] == 0) ? @"C" : @"F" forKey:@"degrees"];
    if(_selectedHomeTown != nil){
        [dict setObject:_selectedHomeTown forKey:@"hometown_obj"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForPostAvatarAndInfo:nil] parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            
            [AppController sharedInstance].currentUser.username = _inputUsername.text;
            [AppController sharedInstance].currentUser.firstname = _inputFirstName.text;
            [AppController sharedInstance].currentUser.lastname = _inputLastName.text;
            [AppController sharedInstance].currentUser.homeTown = _inputHomeTown.text;
            [AppController sharedInstance].currentUser.phone = _inputPhone.text;
            [AppController sharedInstance].currentUser.isPrivate = ([_segmentVisibility selectedSegmentIndex] == 0);
            [AppController sharedInstance].currentUser.allowNotifications = ([_segmentNotifications selectedSegmentIndex] == 0);
            
            [AppController sharedInstance].currentUser.name = [NSString stringWithFormat:@"%@ %@",[AppController sharedInstance].currentUser.firstname,[AppController sharedInstance].currentUser.lastname];
            
           [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_USER_INFO object:nil];
            
        }else{
         
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
    _btnLogout.hidden = NO;

    [self doSave];
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
    if(tableView == _tableViewSearch){
        return [_searchItems count];
    }
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _tableViewSearch){
        return 55.0;
    }
    AppBeenThere *b = [_items objectAtIndex:indexPath.row];
    if(b.showExpanded){
        return [b returnExpandedHeight];
    }else{
        return 120.0;
    }
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
        _inputHomeTown.text = [NSString returnStringObjectForKey:@"title" withDictionary:_selectedHomeTown];
        [self hideSearchView];
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

    }else{
        [_scrollView setContentSize:CGSizeMake(_scrollView.width, _btnSave.maxY + 80 + kbSize.height - _scrollView.y)];

    }
    
    
}

- (void)keyboardWillHide:(NSNotification*)aNotification{
    
    if([self.view.subviews containsObject:_locationSelectionView]){

        
    }else{
        [_scrollView setContentSize:CGSizeMake(_scrollView.width,_btnSave.maxY + 80)];
    }

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[AppController sharedInstance] hideKeyboard];
}


@end
