//
//  AppWelcomeViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface AppWelcomeViewController : AppViewController<UIAlertViewDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *_sections;
    UIScrollView *_sectionsHolder;
    UIImageView *_blurImageView;
    NSMutableArray *_items;
    NSMutableArray *_forecastData;
    BOOL _builtWeather;
    BOOL _haveWeatherData;
    UIButton *_overallButton;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _lastUserLocation;
    NSArray *_bgPhotos;
    NSTimer *_getWeatherTimer;
    UIPanGestureRecognizer *_panGestureRecognizer;
    CGPoint _originalPoint;
    BOOL _reloadOnViewReturn;
    BOOL _alreadyAskedAboutLocation;
    BOOL _canSwipeAway;
    int _locationCount;
    
    UIScrollView *_weatherViewScrollView;
    UIScrollView *_weatherTimeViewScrollView;
    UIAlertView *_alertViewLocation;
}

@property (strong, nonatomic) IBOutlet UIImageView *bgImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) IBOutlet UIView *inTownView;
@property (strong, nonatomic) IBOutlet UIView *forecaseView;

@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UILabel *forecastIcon;
@property (strong, nonatomic) IBOutlet UILabel *forecastTemp;
@property (strong, nonatomic) IBOutlet UILabel *friendsNearLabel;

@property (strong, nonatomic) IBOutlet UIView *friendsInCityView;
@property (strong, nonatomic) IBOutlet UIView *weatherView;

@property (strong, nonatomic) IBOutlet CCButton *btnClose;
@property (strong, nonatomic) IBOutlet UILabel *weatherViewMainIcon;
@property (strong, nonatomic) IBOutlet UILabel *weatherViewMainTemp;
@property (strong, nonatomic) IBOutlet UILabel *weatherViewMainDate;

@property (strong, nonatomic) IBOutlet UITableView *friendsInCityTableView;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel1;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel2;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel3;

@property (strong, nonatomic) IBOutlet UILabel *totalFriendsLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalFriendsUnderLabel;
@property (strong, nonatomic) IBOutlet UILabel *tapForForecast;

- (void)doLayout;
- (IBAction)doLogoPressed;
- (IBAction)doViewForecast;
- (IBAction)doHideForecast;
- (IBAction)doShowFriendsInCity;
- (IBAction)doHideFriendsInCity;
-(void)appEnteredForeground;

@end
