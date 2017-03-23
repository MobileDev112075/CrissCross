//
//  AppWelcomeViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppWelcomeViewController.h"
#import "AppFriendsInCityTableViewCell.h"
#import "AppFindFriendViewController.h"
#import "AppBeenThereDetailViewController.h"

#define kAppFriendsInCityTableViewCell @"AppFriendsInCityTableViewCell"

@interface AppWelcomeViewController ()

@end

@implementation AppWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sections = [[NSMutableArray alloc] init];
    _items = [[NSMutableArray alloc] init];
    _forecastData = [[NSMutableArray alloc] init];
    _blurImageView.clipsToBounds = YES;
    _bgImage.clipsToBounds = YES;
    _canSwipeAway = YES;
    [_friendsInCityTableView registerNib:[UINib nibWithNibName:kAppFriendsInCityTableViewCell bundle:nil] forCellReuseIdentifier:kAppFriendsInCityTableViewCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doLayout) name:NOTIFICATION_REFRESH_WELCOME_SCREEN object:nil];
    
    _totalFriendsLabel.text = @"";
    _totalFriendsUnderLabel.text = @"Locating Friends\nIn Town";
    _totalFriendsUnderLabel.adjustsFontSizeToFitWidth = YES;
    self.canLeaveWithSwipe = NO;
    
    [_loadingIndicator startAnimating];

    _weatherViewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _weatherTimeViewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_weatherView addSubview:_weatherViewScrollView];
    [_weatherView addSubview:_weatherTimeViewScrollView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    [[RAVNPush sharedInstance] setUserId:[AppController sharedInstance].currentUser.userId];
    [[RAVNPush sharedInstance] requestPushAccess];
    
}




- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer{
    if(!_canSwipeAway)
        return;
    CGFloat xDistance = [gestureRecognizer translationInView:self.view].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self.view].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            _originalPoint = self.view.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            self.view.center = CGPointMake(_originalPoint.x + xDistance, _originalPoint.y);
            break;
        };
        case UIGestureRecognizerStateEnded: {
            
            if(xDistance > 200){
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     self.view.x = self.view.width*2;
                                 }];
            }else if(xDistance < -200){
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     self.view.x = -self.view.width*2;
                                 }];
            }else{
                [self resetViewPositionAndTransformations];
            }
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.view.center = _originalPoint;
                         self.view.transform = CGAffineTransformMakeRotation(0);
                     }];
}

- (void)wantsToLeaveWithSwipe{
    [self doLogoPressed];
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)appEnteredForeground{
    self.view.transform = CGAffineTransformIdentity;
    self.view.height = [AppController sharedInstance].screenBoundsSize.height;
    self.view.width = [AppController sharedInstance].screenBoundsSize.width;
    self.view.x = 0;
    self.view.y = 0;
    self.view.transform = CGAffineTransformIdentity;
    _canSwipeAway = YES;
    [[RAVNPush sharedInstance] setUserId:[AppController sharedInstance].currentUser.userId];
    [[RAVNPush sharedInstance] requestPushAccess];
    [self getUserLocation];
}


- (void)doLayout{

    
    if(_reloadOnViewReturn){
        _reloadOnViewReturn = NO;
        _didLayout = NO;
    }
    
    if(!_didLayout){
        _didLayout = YES;
        [_topnav.view removeFromSuperview];
        
       
        _tapForForecast.font = [UIFont fontWithName:_tapForForecast.font.fontName size:round(_forecaseView.height*.06)];
        _tapForForecast.hidden = YES;
        _forecastTemp.text = @"Loading Weather";
        
        _forecastTemp.adjustsFontSizeToFitWidth = YES;
        _cityLabel1.text = _cityLabel2.text = _cityLabel3.text = @"";
        _forecastIcon.text = @"";
        _weatherViewMainIcon.text = @"";

        _forecaseView.width = self.view.width/2;
        _inTownView.width = self.view.width/2;
        _inTownView.x = _forecaseView.maxX;
        _bgImage.image = nil;
        
        
        _bottomView.y = _topView.maxY;
        _bottomView.height = self.view.height - _bottomView.y;
        
        _sectionsHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _bottomView.width, _bottomView.height)];
        [_bottomView addSubview:_sectionsHolder];
        
        [_topView addTopBorderWithHeight:1 andColor:[[UIColor colorWithHexString:COLOR_CC_GREEN] colorWithAlphaComponent:0.1]];
        [_forecaseView addRightBorderWithWidth:1 andColor:[[UIColor colorWithHexString:COLOR_CC_GREEN] colorWithAlphaComponent:0.1]];
        
        
        [self rebuildSections:nil];
        
         _blurImageView = [[UIImageView alloc] initWithFrame:_bgImage.frame];
        [self getUserLocation];
        
        
    }else{
        
    }
    
       
}


-(void)rebuildSections:(NSDictionary *)dict{
    
    [_sections removeAllObjects];
    [_sectionsHolder removeAllSubviews];
    
    if(dict == nil){
        return;
    }
    
    if([dict objectForKey:@"itin"] != nil){
    
        _sections = [NSMutableArray arrayWithArray:[dict objectForKey:@"itin"]];

        int startingY = 0;
        
      
        int count = 0;
        
        
        for(NSDictionary *dict in _sections){
            
            BOOL isNotify = [[NSString returnStringObjectForKey:@"type" withDictionary:dict] isEqualToString:@"notify"];
            BOOL isAddFriends = [[NSString returnStringObjectForKey:@"type" withDictionary:dict] isEqualToString:@"add"];
            
            UIButton *row = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _sectionsHolder.width, 100)];
            
            if(count == [_sections count]-1){
                row.height += 15*2;
            }
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:row.frame];
            [iv setImageWithURL:[NSURL URLWithString:[NSString returnStringObjectForKey:@"img" withDictionary:dict]] placeholderImage:nil];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.alpha = kImageAlpha;
            iv.clipsToBounds = YES;
            
            
            [row addSubview:iv];
            
            [row addTopBorderWithHeight:1 andColor:[[UIColor colorWithHexString:COLOR_CC_GREEN] colorWithAlphaComponent:0.1]];
            
            [row addTarget:self action:@selector(doGoToSection:) forControlEvents:UIControlEventTouchUpInside];
            
            
            UILabel *label = [[UILabel alloc] initWithFrame:row.frame];
            label.text = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
            label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:18];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.adjustsFontSizeToFitWidth = YES;
            label.width = row.width - 40;
            [label sizeToFit];
            label.width = row.width - 40;
            
            label.y = 20;
            label.x = row.width/2 - label.width/2;
            [row addSubview:label];
            
            NSString *iconStr = [NSString returnStringObjectForKey:@"icon" withDictionary:dict];
            
            THLabel *icon = [[THLabel alloc] initWithFrame:row.frame];
            if(iconStr){
                icon.text = [NSString returnStringObjectForKey:@"icon" withDictionary:dict];
                icon.font = [UIFont fontWithName:FONT_ICONS size:30];
                icon.textColor = [UIColor whiteColor];
                icon.adjustsFontSizeToFitWidth = YES;
                [icon sizeToFit];
                icon.y = label.y - icon.height;
                icon.x = row.width/2 - icon.width/2;
                [row addSubview:icon];
            }
            
            UILabel *byline = [[UILabel alloc] initWithFrame:row.frame];
            byline.text = [NSString returnStringObjectForKey:@"byline" withDictionary:dict];
            byline.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:20];
            byline.textColor = [UIColor colorWithHexString:COLOR_CC_GREEN];
            byline.textAlignment = NSTextAlignmentCenter;
            byline.numberOfLines = 0;
            byline.adjustsFontSizeToFitWidth = YES;
            byline.width = row.width - 40;
            [byline sizeToFit];
            byline.width = row.width - 40;
            byline.y = label.maxY - 2;
            byline.x = row.width/2 - byline.width/2;
            [row addSubview:byline];
            
            [_sectionsHolder addSubview:row];
            row.tag = count++;
            
            row.height = byline.maxY + 20;
            if(isNotify){
                icon.y += 40;
                byline.y += icon.maxY - 10;
                row.height = byline.maxY + 40;
                row.tag = 99;
            }else if(isAddFriends){
                row.tag = 98;
            }
            
            row.y = startingY;
            startingY += row.height;
        }
        [_sectionsHolder setContentSize:CGSizeMake(_sectionsHolder.width, startingY)];
        [_sectionsHolder setContentOffset:CGPointZero];
    }
    
}



#pragma mark Location


-(void)getUserLocation{
    
    BOOL checkLocation = NO;
    
    if([CLLocationManager locationServicesEnabled]){
        
        
        switch([CLLocationManager authorizationStatus]){
            case kCLAuthorizationStatusAuthorizedAlways:
                checkLocation = YES;
                break;
            case kCLAuthorizationStatusDenied:
                break;
            case kCLAuthorizationStatusRestricted:
                break;
            case kCLAuthorizationStatusNotDetermined:
                checkLocation = YES;
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                checkLocation = YES;
                break;
            default:
                checkLocation = YES;
                break;
        }
    }
    
    if(checkLocation){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        if([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
    else{

        if(_alertViewLocation != nil){
            [_alertViewLocation dismissWithClickedButtonIndex:0 animated:NO];
            _alertViewLocation = nil;
        }
        if(_alertViewLocation == nil){
            _alertViewLocation = [[UIAlertView alloc] initWithTitle:@"Location Disabled" message:@"Please enable the Location Services that are disabled in your Settings of the Phone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Manage Settings", nil];
            _alertViewLocation.tag = 5;
            [_alertViewLocation show];
        }
        
    }
}



-(void)getWeather:(NSString *)city andISO:(NSString *)iso{
    

    _totalFriendsLabel.text = @"";
    _totalFriendsUnderLabel.text = @"Locating Friends\nIn Town";
    _friendsNearLabel.text = @"";
    _friendsNearLabel.adjustsFontSizeToFitWidth = YES;
    
    
    [_getWeatherTimer invalidate];
    _loadingIndicator.hidden = NO;
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitTimeZone fromDate:now];
    NSTimeZone *tz = [components timeZone];

    
    [dict setObject:[NSString stringWithFormat:@"%f",_lastUserLocation.latitude] forKey:@"lat"];
    [dict setObject:[NSString stringWithFormat:@"%f",_lastUserLocation.longitude] forKey:@"lng"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[components hour]] forKey:@"hour"];
    [dict setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"cdiff"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)tz.secondsFromGMT] forKey:@"tz"];
    [dict setObject:city forKey:@"city"];
    [dict setObject:iso forKey:@"iso"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetWeather:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [self updateWeatherWithDictionary:responseObject];
            [self rebuildSections:responseObject];
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [[AppController sharedInstance].currentUser refreshUserDataFromServer];
}

-(void)loadBackgroundImage{
    if([_bgPhotos count] == 0){
        return;
    }
    NSString *photo = [_bgPhotos objectAtIndex:0];
    __weak UIImageView *mainBg = _bgImage;
    __weak UIImageView *mainBlurBg = _blurImageView;
    [_bgImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:photo]] placeholderImage:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         mainBg.image = image;
         UIImage *imageBlur = [VTUtils blurWithImageEffects:mainBg.image];
         mainBlurBg.image = imageBlur;
         mainBlurBg.alpha = 0.2;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

     }];
}

-(void)updateWeatherWithDictionary:(NSDictionary *)dict{
    

    _haveWeatherData = YES;
    _builtWeather = NO;
    [_weatherViewScrollView removeAllSubviews];
    [_weatherTimeViewScrollView removeAllSubviews];
    _tapForForecast.hidden = NO;
    _cityLabel1.adjustsFontSizeToFitWidth = _cityLabel2.adjustsFontSizeToFitWidth = _cityLabel3.adjustsFontSizeToFitWidth = YES;
    _cityLabel1.text = _cityLabel2.text = _cityLabel3.text = [NSString returnStringObjectForKey:@"city" withDictionary:dict];
    
    
    [AppController sharedInstance].currentUser.currentCity = _cityLabel1.text;
    _tapForForecast.hidden = NO;
    
    [_forecastData removeAllObjects];
    
    for(NSArray *dayArray in [dict objectForKey:@"data"]){
        [_forecastData addObject:dayArray];
    }
    
    NSDictionary *mainWeather = [[_forecastData firstObject] firstObject];
    NSString *theWeatherTemp = [NSString stringWithFormat:@"%@/%@",[mainWeather objectForKey:@"high"],[mainWeather objectForKey:@"low"]];
    NSRange range = [theWeatherTemp rangeOfString:@"/"];
    
    NSDictionary *currentWeather = [dict objectForKey:@"current"];
    _forecastTemp.text = [NSString stringWithFormat:@"%@",[currentWeather objectForKey:@"temp"]];
    _forecastIcon.text = [NSString stringWithFormat:@"%@",[currentWeather objectForKey:@"icon"]];
    _forecastIcon.textColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[currentWeather objectForKey:@"color"]]];
    
    _bgPhotos = [currentWeather objectForKey:@"photos"];
    [self loadBackgroundImage];
    
    _weatherViewMainIcon.text = [NSString stringWithFormat:@"%@",[currentWeather objectForKey:@"icon"]];
    _weatherViewMainIcon.textColor = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",[currentWeather objectForKey:@"color"]]];
    
    if(range.location != NSNotFound){
        
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#7F83A3"], NSForegroundColorAttributeName,nil];
        NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"FFFFFF"], NSForegroundColorAttributeName,nil];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:theWeatherTemp attributes:attrs];
        [attributedText setAttributes:subAttrs range: NSMakeRange(0,range.location+1)];
        [_weatherViewMainTemp setAttributedText:attributedText];
        
    }else{
        _weatherViewMainTemp.text = theWeatherTemp;
    }
    
    _loadingIndicator.hidden = YES;
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    _weatherViewMainDate.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:today]];
    

    _items = [[NSMutableArray alloc] init];
    for(NSDictionary *d in [dict objectForKey:@"close_by"]){
        AppContact *c = [[AppContact alloc] initWithDictionary:d];
        [_items addObject:c];
    }
    [_friendsInCityTableView reloadData];
    
    int total = (int)[_items count];
    _totalFriendsLabel.text = [NSString stringWithFormat:@"%d",total];
    _totalFriendsUnderLabel.text = [NSString stringWithFormat:@"Friend%@\nIn Town",(total == 1) ? @"": @"s"];
    _friendsNearLabel.text = [NSString stringWithFormat:@"%d Friend%@\n near",total,(total == 1) ? @"": @"s"];
    
    
    if([_cityLabel1.text length] == 0){
        _cityLabel1.text = _cityLabel2.text = _cityLabel3.text = @"CrissCross";
        _forecastTemp.text = @"";
        _forecastIcon.text = @"";
        _tapForForecast.hidden = YES;
        _haveWeatherData = NO;
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
#if TARGET_IPHONE_SIMULATOR
    
#else



#endif
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    _lastUserLocation = newLocation.coordinate;
    [_locationManager stopUpdatingLocation];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
    [_loadingScreen removeFromSuperview];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray* placemarks, NSError* error){
         [_loadingScreen removeFromSuperview];

         if([placemarks count]) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString *locality = [NSString stringWithFormat:@"%@",placemark.locality];
             NSString *countryCode = [NSString stringWithFormat:@"%@",placemark.ISOcountryCode];
             
             [self getWeather:locality andISO:countryCode];
         }else{
             [self getWeather:@"" andISO:@""];
         }
         
         
         
     }];
    
    
    
    
}


















-(void)doGoToSection:(UIButton *)btn{
    
    int idx = (int)btn.tag;
    
    switch (idx) {
            
        case 98:{
            _reloadOnViewReturn = YES;
            AppFindFriendViewController *vc = [[AppFindFriendViewController alloc] initWithNibName:@"AppFindFriendViewController" bundle:nil];
            vc.fromProfile = YES;
            [[AppController sharedInstance].navController pushViewController:vc animated:YES];
        }
            break;
        case 99:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Notify your friends in %@",_cityLabel1.text] message:@"Warning: You are about to notify all your friends in the city" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Notify",nil];
            [alert show];
        }
            break;
            
        default:{
            if(idx < [_sections count] && idx >= 0){
                NSDictionary *dict = [_sections objectAtIndex:idx];
                @try{
                    NSArray *ids = [dict objectForKey:@"ids"];
                    AppBeenThereDetailViewController *vc = [[AppBeenThereDetailViewController alloc] initWithNibName:@"AppBeenThereDetailViewController" bundle:nil];
                    AppBeenThere *bt = [[AppBeenThere alloc] initWithDictionary:@{}];
                    bt.allIds = ids;
                    bt.title = [NSString returnStringObjectForKey:@"byline" withDictionary:dict];
                    bt.itemTitle = [NSString returnStringObjectForKey:@"byline" withDictionary:dict];
                    bt.img = [NSString returnStringObjectForKey:@"img_url" withDictionary:dict];
                    bt.categoryId = [[NSString returnStringObjectForKey:@"category_id" withDictionary:dict] intValue];
                    bt.communityItem = YES;
                    bt.isAChild = YES;
                    vc.beenThere = bt;
                    [[AppController sharedInstance].navController pushViewController:vc animated:YES];
                    
                }@catch(NSException *e){
                }
                
            }
        }
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    

    if(alertView.tag == 2){
        if(buttonIndex == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        _alertViewLocation = nil;
        return;
    }else if(alertView.tag == 5){
        if(buttonIndex == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }else{
            if(_alreadyAskedAboutLocation)
                return;
            _alreadyAskedAboutLocation = YES;
            _alertViewLocation = [[UIAlertView alloc] initWithTitle:@"Location Disabled" message:@"Without access to location you can't see when you will Crisscross with friends! This can be changed in the settings on your profile" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Allow Access", nil];
            _alertViewLocation.tag = 2;
            [_alertViewLocation show];
        }
        _alertViewLocation = nil;
        return;
    }


    
    if(buttonIndex == 1){

        NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
        [dict setObject:_cityLabel1.text forKey:@"area"];
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        for(AppContact *c in _items){
            [ids addObject:c.userId];
        }
        [dict setObject:ids forKey:@"ids"];
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
        [manager POST:[AppAPIBuilder APIForNotifyFriends:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            responseObject = [VTUtils processResponse:responseObject];
            if([VTUtils isResponseSuccessful:responseObject]){

            }else{
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sent!" message:nil delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)doLogoPressed{
    if(!_overallButton){
        _overallButton = [[UIButton alloc] initWithFrame:self.view.frame];
        [_overallButton addTarget:self action:@selector(pageBringBack) forControlEvents:UIControlEventTouchDown];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DASH_ANIMATE_IN object:nil];
    
    [self.view addSubview:_overallButton];
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.view.x = self.view.width;
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

-(void)pageBringBack{
                             [_overallButton removeFromSuperview];
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.view.x = 0;
                     } completion:^(BOOL finished) {

                     }];
}

- (IBAction)doViewForecast {
    
    if(!_haveWeatherData)
        return;
    
    if(!_builtWeather){
        _builtWeather = YES;
        _weatherViewScrollView.width = _weatherTimeViewScrollView.width = self.view.width;
        _weatherViewScrollView.height = (self.view.height - _weatherViewMainDate.maxY)/2;
        _weatherTimeViewScrollView.height = _weatherViewScrollView.height;
        _weatherTimeViewScrollView.y = _weatherViewMainDate.maxY;
        _weatherViewScrollView.y = _weatherTimeViewScrollView.maxY;
      
        
        int startingX = 20;
        int spacing = (self.view.width + 100)/[_forecastData count];
        int didHours = 0;

        for(NSArray *arr in _forecastData){
            
            for(NSDictionary *dict in arr){

                if(didHours++ > 5)
                    continue;
                UIButton *row = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, spacing, _weatherTimeViewScrollView.height)];
                
                
                UILabel *icon = [[UILabel alloc] initWithFrame:row.frame];
                icon.text = [NSString returnStringObjectForKey:@"icon" withDictionary:dict];
                icon.font = [UIFont fontWithName:FONT_ICONS size:30];
                icon.textColor = [UIColor whiteColor];
                icon.adjustsFontSizeToFitWidth = YES;
                [icon sizeToFit];
                
                icon.y = row.height/2 - icon.height/2;
                icon.x = row.width/2 - icon.width/2;
                [row addSubview:icon];
                
                
                UILabel *label = [[UILabel alloc] initWithFrame:row.frame];
                label.text = [NSString returnStringObjectForKey:@"display_time" withDictionary:dict];
                label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:12];
                label.textColor = [UIColor whiteColor];
                [label sizeToFit];
                label.y = icon.y - 20;
                label.x = row.width/2 - label.width/2;
                [row addSubview:label];

                
                UILabel *byline = [[UILabel alloc] initWithFrame:row.frame];
                byline.text = [NSString stringWithFormat:@"%@/%@",[NSString returnStringObjectForKey:@"high" withDictionary:dict],[NSString returnStringObjectForKey:@"low" withDictionary:dict]];
                
                byline.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:14];
                byline.textColor = [UIColor colorWithHexString:@"FFFFFF"];
                [byline sizeToFit];
                byline.y = icon.maxY + 5;
                byline.x = row.width/2 - byline.width/2;
                [row addSubview:byline];
                
                [_weatherTimeViewScrollView addSubview:row];
                row.x = startingX;
                startingX += row.width;
            }
        }
        [_weatherTimeViewScrollView setContentSize:CGSizeMake(startingX, _weatherTimeViewScrollView.height)];
        
        
        startingX = 20;
        spacing = (self.view.width + 100)/[_forecastData count];
        for(NSArray *arr in _forecastData){
            NSDictionary *dict = [arr firstObject];
            UIButton *row = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, spacing, _weatherViewScrollView.height)];
            
            UILabel *icon = [[UILabel alloc] initWithFrame:row.frame];
            icon.text = [NSString returnStringObjectForKey:@"icon" withDictionary:dict];
            icon.font = [UIFont fontWithName:FONT_ICONS size:30];
            icon.textColor = [UIColor whiteColor];
            icon.adjustsFontSizeToFitWidth = YES;
            [icon sizeToFit];
            
            icon.y = row.height/2 - icon.height/2;
            icon.x = row.width/2 - icon.width/2;
            [row addSubview:icon];

            
            UILabel *label = [[UILabel alloc] initWithFrame:row.frame];
            label.text = [NSString returnStringObjectForKey:@"day" withDictionary:dict];
            label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:12];
            label.textColor = [UIColor whiteColor];
            [label sizeToFit];
            label.y = icon.y - 20;
            label.x = row.width/2 - label.width/2;
            [row addSubview:label];
            
            
            UILabel *byline = [[UILabel alloc] initWithFrame:row.frame];
            byline.text = [NSString stringWithFormat:@"%@/%@",[NSString returnStringObjectForKey:@"high" withDictionary:dict],[NSString returnStringObjectForKey:@"low" withDictionary:dict]];
            
            byline.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_LIGHT size:14];
            byline.textColor = [UIColor colorWithHexString:@"FFFFFF"];
            [byline sizeToFit];
            byline.y = icon.maxY + 5;
            byline.x = row.width/2 - byline.width/2;
            [row addSubview:byline];
            
            [_weatherViewScrollView addSubview:row];
            row.x = startingX;
            startingX += row.width;
        }
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, _weatherViewScrollView.y, self.view.width, 1)];
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        [_weatherView addSubview:line];
        [_weatherViewScrollView setContentSize:CGSizeMake(startingX, _weatherViewScrollView.height)];
        
        _weatherViewScrollView.showsHorizontalScrollIndicator = NO;
        _weatherTimeViewScrollView.showsHorizontalScrollIndicator = NO;
        
        
    }
    
    _canSwipeAway = NO;
    
    _blurImageView.alpha = 0.2;
    [_weatherView insertSubview:_blurImageView atIndex:0];
    _weatherView.width = self.view.width;
    _weatherView.height = self.view.height;
    [self.view addSubview:_weatherView];
    _weatherView.alpha = 0;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _weatherView.alpha = 1;
                     } completion:^(BOOL finished) {
                         
                     }];

}

- (IBAction)doShowFriendsInCity {
    if([_items count] == 0)
        return;
    
    _canSwipeAway = NO;
    _blurImageView.alpha = 0.2;
    [_friendsInCityView insertSubview:_blurImageView atIndex:0];
    _friendsInCityView.width = self.view.width;
    _friendsInCityView.height = self.view.height;
    [self.view addSubview:_friendsInCityView];
    _friendsInCityView.alpha = 0;
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _friendsInCityView.alpha = 1;

                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (IBAction)doHideForecast{
    _canSwipeAway = YES;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _weatherView.alpha = 0;
                         
                     } completion:^(BOOL finished) {
                         [_weatherView removeFromSuperview];
                     }];
    
    
}

- (IBAction)doHideFriendsInCity {
    _canSwipeAway = YES;
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _friendsInCityView.alpha = 0;

                     } completion:^(BOOL finished) {
                         [_friendsInCityView removeFromSuperview];
                     }];

    
}




#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_items count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    AppFriendsInCityTableViewCell *cell = (AppFriendsInCityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAppFriendsInCityTableViewCell];
    if (cell == nil) {
        cell = [[AppFriendsInCityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppFriendsInCityTableViewCell];
    }
    
    AppContact *c = [_items objectAtIndex:indexPath.row];
    [cell setupWithContact:c];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == _friendsInCityTableView){
        AppContact *c = [_items objectAtIndex:indexPath.row];
        [[AppController sharedInstance] routeToUserProfile:c.userId];
        
    }
    
    
}




@end
