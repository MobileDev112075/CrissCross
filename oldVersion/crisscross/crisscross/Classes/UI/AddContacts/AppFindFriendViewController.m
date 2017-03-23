//
//  AppFindFriendViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/18/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppFindFriendViewController.h"
#import "AppDashboardViewController.h"
#import "AppContactsTableViewCell.h"
#import "AppAddFriendsInterstitialViewController.h"
//#import "AppsFlyerTracker.h"

#define kAppContactsTableViewCell @"AppContactsTableViewCell"

@interface AppFindFriendViewController ()

@end

@implementation AppFindFriendViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    _multiCellSelected = [[NSMutableArray alloc] init];
    _allEmails = [[NSMutableArray alloc] init];
    _searchResults = [[NSMutableArray alloc] init];
    _buttons = [[NSMutableArray alloc] init];

    _sectionKeys = [AppController sharedInstance].contactsSectionKeys;
    _sectionData = [AppController sharedInstance].contactsSectionData;
    
    _sectionKeysHaveApp = [[NSMutableArray alloc] init];
    _sectionDataHaveApp = [[NSMutableDictionary alloc] init];
    
    _allContacts = [[NSMutableArray alloc] init];
    _allContactsWithApp = [[NSMutableArray alloc] init];
    _allContactsWithOutApp = [[NSMutableArray alloc] init];
    [_tableView registerNib:[UINib nibWithNibName:kAppContactsTableViewCell bundle:nil] forCellReuseIdentifier:kAppContactsTableViewCell];

    if ([_tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        _tableView.sectionIndexColor = [UIColor colorWithHexString:@"#CBCCCD"];
        _tableView.sectionIndexBackgroundColor = [UIColor colorWithHexString:@"#F8F9F9"];
    }
    

    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIFont fontWithName:FONT_HELVETICA_NEUE size:13], NSFontAttributeName,
                             [UIColor colorWithHexString:COLOR_CC_TEAL], NSForegroundColorAttributeName,
                             nil]
     forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.view.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG2];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH_WELCOME_SCREEN object:nil];
    [super viewWillDisappear:animated];
    if(_checkOnEnterView){
        _checkOnEnterView = NO;
        [self checkIfWeCanAccessTheAddressBook];
    }
}

-(void)layoutUI{
    if(!_didLayout){
        _didLayout = YES;
        _topnav.theTitle.text = @"Find Your Friends";
        

        UITextField *searchTextField = [_searchBar valueForKey:@"_searchField"];
        UILabel *placeholderLabel = [searchTextField valueForKey:@"_placeholderLabel"];
        [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
        
        if(_fromProfile){
            _btnSkip.hidden = YES;
            _btnContinue.hidden = YES;
            [_btnContinue setTitle:@"Send" forState:UIControlStateNormal];
        }else{
            [_btnContinue setTitle:@"Continue" forState:UIControlStateNormal];
            _topnav.btnBack.hidden = YES;
            if([_multiCellSelected count] == 0)
                _btnContinue.hidden = YES;
            else
                _btnContinue.hidden = NO;
             [self.view addSubview:_btnSkip];
        }
        
        
        
        if(((1)) || _fromProfile){
            _bottomView.height = roundf(self.view.height * 0.10);
            _bottomView.y = self.view.height - _bottomView.height;
            [_btnContinue removeFromSuperview];
            _btnSelectAll.width = self.view.width;
            
            _btnSelectAll.x = 0;
            _btnSelectAll.y = 0;
            _btnSelectAll.height = _bottomView.height;
            _btnSelectAll.backgroundColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
            [_btnSelectAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if(_fromPlans){
                [_btnSelectAll setTitle:@"Continue" forState:UIControlStateNormal];
            }else{
                [_btnSelectAll setTitle:@"Add All Friends" forState:UIControlStateNormal];
            }
            [_btnSelectAll setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 40, 0)];
        }
       

        int count = 0;
        int startingX = 0;
        _topTabsView = [[UIView alloc] initWithFrame:CGRectMake(0, _searchView.maxY, self.view.width, 40)];
        _topTabsView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0];
        [self.view addSubview:_topTabsView];
                                        
        
        for(NSDictionary *dict in @[@{@"title":@"Add Friends"},@{@"title":@"Invite Friends"}]){
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, roundf((_topTabsView.width/2)+1), _topTabsView.height)];
            b.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:14];
            [b setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
            b.tag = count;
            b.backgroundColor = self.view.backgroundColor;
            [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
            [b addTarget:self action:@selector(sectionTapped:) forControlEvents:UIControlEventTouchUpInside];
            startingX += b.maxX;
            [_topTabsView addSubview:b];
            [_buttons addObject:b];
            count++;
            
        }
        
        if(_fromPlans){
            UIButton *b1 = [_buttons firstObject];
            b1.hidden = YES;
            [self sectionTapped:[_buttons lastObject]];
        }else{
            [self sectionTapped:[_buttons firstObject]];
        }

        _tableView.y = _topTabsView.maxY;
        
        _tableView.height = roundf(self.view.height - _bottomView.height - _tableView.y);
        
        
        
        [self checkIfWeCanAccessTheAddressBook];
        
    }
    
    
}



-(void)sectionTapped:(UIButton *)btn{
    for(UIButton *b in _buttons){
        b.backgroundColor = self.view.backgroundColor;
        [b setTitleColor:[UIColor colorWithHexString:COLOR_CC_GREEN] forState:UIControlStateNormal];
    }
    btn.backgroundColor = _tableView.backgroundColor;
    [btn setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    
    int idx = (int)btn.tag;
    if(idx == 0){
        _tabHaveAppInstalledActive = YES;
    }else{
        _tabHaveAppInstalledActive = NO;
    }
    [_tableView reloadData];
}



-(void)checkIfWeCanAccessTheAddressBook{
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        
        
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
    }
    else {
    }
    [self accessContactList];
}


- (IBAction)doGrantAccess {
}

- (IBAction)doSelectAll {
    
    if(_fromPlans){
        [[AppController sharedInstance] goBack];
        return;
    }
    
    if([self totalThatCanBeAdded] == 0){
        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Send To:"  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"All contacts", nil];
        as.tag = 332;
        [as showInView:self.view];

    }else{
        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Send To:"  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"All contacts",@"All friends on CrissCross", nil];
        as.tag = 333;
        [as showInView:self.view];
    }

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    
    if(actionSheet.tag == 333 || actionSheet.tag == 332){
       
       
        if(buttonIndex == 0){
            
            [_loadingScreen removeFromSuperview];
            _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading" andColor:nil withDelay:0];
            _loadingScreen.alpha = 1;
            [self.view addSubview:_loadingScreen];
            
            
            [_loadingScreen removeFromSuperview];
            _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading" andColor:nil withDelay:0];
            [self.view addSubview:_loadingScreen];
            _loadingScreen.alpha = 1;
            NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
            NSString *based = [_allEmails componentsJoinedByString:@"||~~||"];
            [dict setObject:[NSString base64Encode:based] forKey:@"emails"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
            [manager POST:[AppAPIBuilder APIForInviteContacts:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [_loadingScreen removeFromSuperview];
                responseObject = [VTUtils processResponse:responseObject];
                if([VTUtils isResponseSuccessful:responseObject]){
                    
                    if(_fromProfile){
                        [[AppController sharedInstance] goBack];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[AppController sharedInstance] showToastMessage:@"Invites Sent!"];
                        });
                    }else{
                        AppAddFriendsInterstitialViewController *vc = [[AppAddFriendsInterstitialViewController alloc] initWithNibName:@"AppAddFriendsInterstitialViewController" bundle:nil];
                        vc.totalAdded = (int)[_allEmails count];
                        vc.skipGroups = YES;
                        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
                    }
                    
                }else{
                    [[AppController sharedInstance] alertWithServerResponse:responseObject];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [_loadingScreen removeFromSuperview];
                [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
            }];
        }else if(buttonIndex == 1){
            if(actionSheet.tag == 333)
                [self selectAllContacts:YES andSendToServer:YES];
            
        }
    }
}


-(void)accessContactList{
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    
                    [self buildContacts:addressBookRef];
                } else {
                    
                    [self showMessageAboutPermissions];
                }
            });
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        [self buildContacts:addressBookRef];
    }
    else {
        [self showMessageAboutPermissions];
        
    }
    
}

-(void)showMessageAboutPermissions{
    _hasAccess = NO;
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Access to your Contacts" message:@"Looks like your permissions are blocking access. Please change the access in your device's Privacy Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Manage Settings",nil];
    av.tag = 999;
    [av show];
}



-(void)buildContacts:(ABAddressBookRef)addressBookRef{
    
    
    
    _hasAccess = YES;

    _sectionKeys = [[NSMutableArray alloc] init];
    _sectionData = [[NSMutableDictionary alloc] init];
    
    [_sectionData removeAllObjects];
    [_allContacts removeAllObjects];
    
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    NSMutableArray *nums = [[NSMutableArray alloc] init];
    NSMutableArray *dbIds = [[NSMutableArray alloc] init];
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    [_allEmails removeAllObjects];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        
        
        [AppController sharedInstance].currentUser.contacts = [[NSMutableArray alloc] init];
        NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        for (id record in allContacts){
            
            ABRecordRef thisContact = (__bridge ABRecordRef)record;
            
            AppContact *c = [[AppContact alloc] initWithRecord:thisContact];
            
            if(c.noName)
                continue;
            
            [_allContacts addObject:c];
            
            NSString *firstLetter = [[c firstChar] uppercaseString];
            
            
            if([_sectionData objectForKey:firstLetter] == nil){
                NSMutableArray *innerItems = [[NSMutableArray alloc] init];
                [innerItems addObject:c];
                [_sectionData setObject:innerItems forKey:firstLetter];
                [_sectionKeys addObject:firstLetter];
            }else{
                
                [[_sectionData objectForKey:firstLetter] addObject:c];
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[[_sectionData objectForKey:firstLetter] sortedArrayUsingDescriptors:sortDescriptors]];
                [_sectionData setObject:sortedArray forKey:firstLetter];
            }
            
            
            NSPredicate *p = [NSPredicate predicateWithFormat:@"storedIdString == %@", c.storedIdString];
            NSArray *foundItems = [[AppController sharedInstance].currentUser.unarchivedContacts filteredArrayUsingPredicate:p];
            
            BOOL sendForLookup = YES;
            if([foundItems count] > 0){
                
                AppContact *existing = (AppContact *)[foundItems firstObject];
                
                if([existing.databaseId intValue] > 0){
                    
                    
                    if([c.phoneNumbers count] > 0){
                        NSError *error;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:c.phoneNumbers options:NSJSONWritingPrettyPrinted error:&error];
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        if([jsonString isEqualToString:existing.phoneNumbersJSON]){
                            sendForLookup = NO;
                        }
                    }
                    [dbIds addObject:[NSString stringWithFormat:@"%@::~~::%@",existing.storedIdString,existing.databaseId]];
                }
            }
            
            if(sendForLookup){
                for(NSString *cEmail in c.emails){
                    [emails addObject:[NSString stringWithFormat:@"%@::~~::%@",c.storedIdString,cEmail]];
                    [_allEmails addObject:[NSString stringWithFormat:@"%@::~~::%@",c.storedIdString,cEmail]];
                }
                for(NSString *cNumber in c.phoneNumbers){
                    [nums addObject:[NSString stringWithFormat:@"%@::~~::%@",c.storedIdString,cNumber]];
                }
            }else{
                
            }

            [[AppController sharedInstance].currentUser.contacts addObject:c];
        }
        
        
        [_loadingScreen removeFromSuperview];
        _sectionKeys = [NSMutableArray arrayWithArray:[_sectionKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
        [AppController sharedInstance].contactsSectionKeys = _sectionKeys;
        [AppController sharedInstance].contactsSectionData = _sectionData;
        
        
        
        [self sendToServerToCheckFriendsEmails:emails mobile:nums andFoundDBIds:dbIds];
        
    });
}

-(void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{}

-(void)sendToServerToCheckFriendsEmails:(NSMutableArray *)emails mobile:(NSMutableArray *)nums andFoundDBIds:(NSMutableArray *)dbIds{
    
    
    [_loadingScreen removeFromSuperview];
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Loading" andColor:nil withDelay:0];
    [self.view addSubview:_loadingScreen];
    _loadingScreen.alpha = 1;
    

    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    NSString *based = [emails componentsJoinedByString:@"||~~||"];
    [dict setObject:[NSString base64Encode:based] forKey:@"emails"];
    
    NSString *based2 = [nums componentsJoinedByString:@"||~~||"];
    [dict setObject:[NSString base64Encode:based2] forKey:@"nums"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForFindFriends:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            
            NSArray *foundUsers = [responseObject objectForKey:@"found_users"];
            
            NSMutableArray *contactsWithAppInstalled = [[NSMutableArray alloc] init];
            
            for(NSDictionary *tempDict in foundUsers){
                NSString *sId2 = [NSString returnStringObjectForKey:@"matching_id" withDictionary:tempDict];
                NSPredicate *p = [NSPredicate predicateWithFormat:@"storedIdString == %@", sId2];
                NSArray *foundItems = [[AppController sharedInstance].currentUser.contacts filteredArrayUsingPredicate:p];
                for(AppContact *c in foundItems){

                    c.databaseId = [NSString returnStringObjectForKey:@"id" withDictionary:tempDict];
                    c.hasAppInstalled = YES;
                    c.pendingInvite = [[NSString returnStringObjectForKey:@"pending" withDictionary:tempDict] isEqualToString:@"Y"];
                    c.acceptedInvite = [[NSString returnStringObjectForKey:@"accepted" withDictionary:tempDict] isEqualToString:@"Y"];
                    c.findFriendsAreFriends = [[NSString returnStringObjectForKey:@"are_friends" withDictionary:tempDict] isEqualToString:@"Y"];
                    [contactsWithAppInstalled addObject:c];
                }
            }
            
            
            
            


            [_sectionKeysHaveApp removeAllObjects];
            [_sectionDataHaveApp removeAllObjects];
            [_allContactsWithApp removeAllObjects];
            [_allContactsWithOutApp removeAllObjects];
            int countAppUsers = 0;
            for(AppContact *c in contactsWithAppInstalled){
            
                if(c.findFriendsAreFriends)
                    continue;
                
                if([_allContactsWithApp containsObject:c]){
                    continue;
                }
                
                if(c.noName)
                    continue;
                
                if(c.pendingInvite || c.acceptedInvite){
                    continue;
                }
                
                
                NSString *firstLetter = [[c firstChar] uppercaseString];
            
            
                if([_sectionDataHaveApp objectForKey:firstLetter] == nil){
                    NSMutableArray *innerItems = [[NSMutableArray alloc] init];
                    [innerItems addObject:c];
                    [_sectionDataHaveApp setObject:innerItems forKey:firstLetter];
                    [_sectionKeysHaveApp addObject:firstLetter];
                }else{
                    
                    [[_sectionDataHaveApp objectForKey:firstLetter] addObject:c];
                    NSSortDescriptor *sortDescriptor;
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
                    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[[_sectionDataHaveApp objectForKey:firstLetter] sortedArrayUsingDescriptors:sortDescriptors]];
                    [_sectionDataHaveApp setObject:sortedArray forKey:firstLetter];
                }
                countAppUsers++;
                [_allContactsWithApp addObject:c];
                _sectionKeysHaveApp = [NSMutableArray arrayWithArray:[_sectionKeysHaveApp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
            }
            
            
            [_sectionKeys removeAllObjects];
            [_sectionData removeAllObjects];
            
            int countNonAppUsers = 0;
            for(AppContact *c in _allContacts){
                
                if(c.findFriendsAreFriends)
                    continue;
                
                if([_allContactsWithOutApp containsObject:c]){
                    continue;
                }
                
                if([_allContactsWithApp containsObject:c]){
                    continue;
                }
                
                if(c.noName)
                    continue;
                
                if(c.pendingInvite || c.acceptedInvite || c.hasAppInstalled){
                    continue;
                }
                
                
                countNonAppUsers++;
                

                
                
                NSString *firstLetter = [[c firstChar] uppercaseString];
                
                
                if([_sectionData objectForKey:firstLetter] == nil){
                    NSMutableArray *innerItems = [[NSMutableArray alloc] init];
                    [innerItems addObject:c];
                    [_sectionData setObject:innerItems forKey:firstLetter];
                    [_sectionKeys addObject:firstLetter];
                }else{
                    
                    [[_sectionData objectForKey:firstLetter] addObject:c];
                    NSSortDescriptor *sortDescriptor;
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
                    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[[_sectionData objectForKey:firstLetter] sortedArrayUsingDescriptors:sortDescriptors]];
                    [_sectionData setObject:sortedArray forKey:firstLetter];
                }
                
                [_allContactsWithOutApp addObject:c];
                
                _sectionKeys = [NSMutableArray arrayWithArray:[_sectionKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
            }
    
            UIButton *b = [_buttons firstObject];
            [b setTitle:[NSString stringWithFormat:@"Add Friends (%@)",[VTUtils commaFormatted:countAppUsers]] forState:UIControlStateNormal];
            
            b = [_buttons lastObject];
            [b setTitle:[NSString stringWithFormat:@"Invite Friends (%@)",[VTUtils commaFormatted:countNonAppUsers]] forState:UIControlStateNormal];
            
            [_tableView reloadData];
            
            _btnSelectAll.hidden = NO;
            [self resetSelectAppButton];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
    
    
}

-(void)resetSelectAppButton{
}

-(void)doFriendRequestWithContact:(AppContact *)contact{
}

- (IBAction)doContinue {
    
    int total = (int)[_multiCellSelected count];
    if(total > 0){
        
        
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        
        
        [_loadingScreen removeFromSuperview];
        _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"Sending" andColor:nil withDelay:0];
        _loadingScreen.alpha = 1;
        [self.view addSubview:_loadingScreen];
        [[AppController sharedInstance].currentUser.latestInvites removeAllObjects];
        
        for(AppContact *c in _multiCellSelected){
            [[AppController sharedInstance].currentUser.latestInvites addObject:c];
            [ids addObject:c.databaseId];
        }
        
        NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
        NSString *based = [ids componentsJoinedByString:@"||~~||"];
        [dict setObject:[NSString base64Encode:based] forKey:@"ids"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [manager POST:[AppAPIBuilder APIForPairFriends:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [_loadingScreen removeFromSuperview];
            responseObject = [VTUtils processResponse:responseObject];
            if([VTUtils isResponseSuccessful:responseObject]){

                
                if(_fromProfile){
                    [[AppController sharedInstance] goBack];
                }else{
                    AppAddFriendsInterstitialViewController *vc = [[AppAddFriendsInterstitialViewController alloc] initWithNibName:@"AppAddFriendsInterstitialViewController" bundle:nil];
                    vc.totalAdded = total;
                    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
                }
            }else{
                [[AppController sharedInstance] alertWithServerResponse:responseObject];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [_loadingScreen removeFromSuperview];
            [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
        }];
    }else{
        AppDashboardViewController *vc = [[AppDashboardViewController alloc] initWithNibName:@"AppDashboardViewController" bundle:nil];
        [[AppController sharedInstance].navController pushViewController:vc animated:YES];
    }

}



-(int)totalThatCanBeAdded{
    int total = 0;
    for(NSString *key in _sectionKeysHaveApp){
        for(AppContact *c in [_sectionDataHaveApp objectForKey:key]){

            if(c.hasAppInstalled){
                if(!c.pendingInvite && !c.acceptedInvite){
                    total++;
                }
            }
        }
        
    }

    return total;
}



-(void)selectAllContacts:(BOOL)val andSendToServer:(BOOL)toServer{

    if(!val){
        [_multiCellSelected removeAllObjects];
        [_tableView reloadData];
        return;
    }
    
    NSMutableArray *contactsFound = [[NSMutableArray alloc] init];
    int i = 0;
    for(NSString *key in _sectionKeysHaveApp){

        int j = 0;
        for(AppContact *c in [_sectionDataHaveApp objectForKey:key]){

            if(c.hasAppInstalled){
                if(!c.pendingInvite && !c.acceptedInvite){
                    [_multiCellSelected addObject:c];
                    if(toServer){
                        c.pendingInvite = YES;
                        [contactsFound addObject:c.databaseId];
                    }
                }
            }
            j++;
        }
        i++;
        
    }
    [_tableView reloadData];
    if(toServer){
        [self sendFriendRequestToServer:contactsFound andContinue:YES];
    }

}



#pragma mark TABLE


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if(_searchActive)
        return nil;
    return (_tabHaveAppInstalledActive) ? _sectionKeysHaveApp : _sectionKeys;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(_searchActive){
        return nil;
    }
    
    return (_tabHaveAppInstalledActive) ? [_sectionKeysHaveApp objectAtIndex:section] : [_sectionKeys objectAtIndex:section];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (_searchActive){
        return nil;
    }
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 20)];
    v.backgroundColor = [UIColor colorWithHexString:@"#F8F9F9"];
    [v addBottomBorderWithHeight:1 andColor:[UIColor colorWithHexString:@"#E7E8E9"]];
    UILabel *l = [[UILabel alloc] initWithFrame:v.frame];
    if(_tabHaveAppInstalledActive){
        l.text = [_sectionKeysHaveApp objectAtIndex:section];
    }else{
        l.text = [_sectionKeys objectAtIndex:section];
    }
    l.textColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    l.x += 15;
    l.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:12];
    [v addSubview:l];
    return v;
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_searchActive){
        return 0;
    }
    return 20;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_searchActive){
        return 1;
    }
    return (_tabHaveAppInstalledActive) ? [_sectionKeysHaveApp count] : [_sectionKeys count];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_searchActive){
        return [_searchResults count];
    }

    if(_tabHaveAppInstalledActive){
        NSString *key = [_sectionKeysHaveApp objectAtIndex:section];
        return [[_sectionDataHaveApp objectForKey:key] count];
    }else{
        NSString *key = [_sectionKeys objectAtIndex:section];
        return [[_sectionData objectForKey:key] count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return roundf((self.view.height/2.0)/6.0);
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppContactsTableViewCell *cell = (AppContactsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppContactsTableViewCell];
    if (cell == nil) {
        cell = [[AppContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppContactsTableViewCell];
    }
    
    AppContact *c;
    
    if (_searchActive){
        c = [_searchResults objectAtIndex:indexPath.row];
    }else{
        if(_tabHaveAppInstalledActive){
            NSString *key = [_sectionKeysHaveApp objectAtIndex:indexPath.section];
            c = [[_sectionDataHaveApp objectForKey:key] objectAtIndex:indexPath.row];
        }else{
            NSString *key = [_sectionKeys objectAtIndex:indexPath.section];
            c = [[_sectionData objectForKey:key] objectAtIndex:indexPath.row];
        }
    }
    [cell setupWithContact:c andSelected:[_multiCellSelected containsObject:c]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    AppContact *c;
    
    if (_searchActive){
        c = [_searchResults objectAtIndex:indexPath.row];
    }else{
        if(_tabHaveAppInstalledActive){
            NSString *key = [_sectionKeysHaveApp objectAtIndex:indexPath.section];
            c = [[_sectionDataHaveApp objectForKey:key] objectAtIndex:indexPath.row];
        }else{
            NSString *key = [_sectionKeys objectAtIndex:indexPath.section];
            c = [[_sectionData objectForKey:key] objectAtIndex:indexPath.row];
        }
    }
    
    if(c.hasAppInstalled){
        
        if(c.pendingInvite)
            return;
        
        else if(c.acceptedInvite)
            return;
 
        if(_btnSelectAll.tag == 2){
            [self resetSelectAppButton];
            _btnSelectAll.tag = 3;
        }
        
        
        

        
        if ([_multiCellSelected containsObject:c]){
            [_multiCellSelected removeObject:c];
        }
        else{
            [_multiCellSelected addObject:c];

                c.pendingInvite = YES;
            [self sendFriendRequestToServer:@[c.databaseId] andContinue:NO];

        }
    
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
    }else{
        
        if(_fromPlans){
            
            [AppController sharedInstance].passedShareValues = @{@"body":[NSString stringWithFormat:@"%@<br /><br /> <a href=\"bit.ly/crisscrosstheapp\" style=\"color:#6ED769\">Download CrissCross to join the adventure!</a>",_fromPlansString],@"smsbody":[NSString stringWithFormat:@"%@\n\nDownload CrissCross to join the adventure! http://bit.ly/crisscrosstheapp",_fromPlansString]};
            
        }else{
        
            [AppController sharedInstance].passedShareValues = @{@"body":[NSString stringWithFormat:@"Check out CrissCross for your phone!<br /><br />Download now to coordinate plans with the friends you love and get suggestions from those you trust! <a href=\"bit.ly/crisscrosstheapp\" style=\"color:#6ED769\">Download app and accept request.</a>"],@"smsbody":[NSString stringWithFormat:@"Check out CrissCross for your phone! Download now to coordinate plans with the friends you love and get suggestions from those you trust! http://bit.ly/crisscrosstheapp"]};
        }
        [[AppController sharedInstance] inviteViaSMSOrEmail:c];
    }
}




-(void)sendFriendRequestToServer:(NSArray *)ids andContinue:(BOOL)popBack{
    
    [[AppController sharedInstance].currentUser.latestInvites removeAllObjects];

    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    NSString *based = [ids componentsJoinedByString:@"||~~||"];
    [dict setObject:[NSString base64Encode:based] forKey:@"ids"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForPairFriends:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            
            if(popBack){
                if(_fromProfile){
                    [[AppController sharedInstance] goBack];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[AppController sharedInstance] showToastMessage:@"Invites Sent!"];
//                        [[AppsFlyerTracker sharedTracker] trackEvent:@"tutorialCompleted" withValue:@"tutorialCompleted"];
                    });
                }else{
                    AppAddFriendsInterstitialViewController *vc = [[AppAddFriendsInterstitialViewController alloc] initWithNibName:@"AppAddFriendsInterstitialViewController" bundle:nil];
                    vc.totalAdded = (int)[self totalThatCanBeAdded];
                    vc.skipGroups = YES;
                    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (IBAction)doSkip {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Skip" message:@"Are you sure you want to skip?" delegate:self cancelButtonTitle:@"No, Cancel" otherButtonTitles:@"Yes", nil];
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 999){
        if(buttonIndex == 1){
            _checkOnEnterView = YES;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }else{
            
        }
    }else{
        if(buttonIndex == 1){
            AppDashboardViewController *vc = [[AppDashboardViewController alloc] initWithNibName:@"AppDashboardViewController" bundle:nil];
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
    }
}


#pragma mark search

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton: YES animated: YES];
    _searchShowing = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton: NO animated: YES];
    _searchShowing = NO;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _searchActive = YES;
    
    if([searchText isEmpty]){
        _searchActive = NO;
        [_tableView reloadData];
    }else{
        NSPredicate *p = [NSPredicate predicateWithFormat:@"(name MATCHES[cd] %@) OR (lastName BEGINSWITH[cd] %@) OR (firstName BEGINSWITH[cd] %@)", searchText,searchText,searchText];
        [_searchResults removeAllObjects];
        NSArray *searchResultsTemp = [_allContactsWithOutApp filteredArrayUsingPredicate:p];
        for(AppContact *c in searchResultsTemp){
            
            if([_searchResults containsObject:c]){
                continue;
            }
            if(c.findFriendsAreFriends){
                
            }else{

                if([c.emails count] == 0 && [c.phoneNumbers count] == 0){
                    
                }else{
                    [_searchResults addObject:c];
                }
            }
        }
        [_tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self closeSearching];
}

-(void)closeSearching{
    [[AppController sharedInstance] hideKeyboard];
    _searchBar.text = @"";
    _searchActive = NO;
    [_tableView reloadData];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(scrollView == _tableView){
        [_searchBar resignFirstResponder];
    }
}



- (void)keyboardWillShow:(NSNotification*)aNotification{
    _kbSize = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self adjustKeyboardUp:YES];
    
}

-(void)keyboardWillHide:(NSNotification*)aNotification{

    [self adjustKeyboardUp:NO];
}

-(void)adjustKeyboardUp:(BOOL)val{
    
    if(val){
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             _tableView.height = self.view.height - _tableView.y - _kbSize.height;
                         } completion:^(BOOL finished) {}];
        
    }else{
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             _tableView.height = self.view.height - _tableView.y - _bottomView.height;
                         } completion:^(BOOL finished) {}];
    }
}








@end
