//
//  AppUser.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppUser.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>

@implementation AppUser


- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if (self) {
         _contacts = [[NSMutableArray alloc] init];
        _latestInvites = [[NSMutableArray alloc] init];
        _unarchivedContacts = [[NSMutableArray alloc] init];
        _dreamingOfLocations = [[NSMutableArray alloc] init];
        _beenThereItems = [[NSMutableArray alloc] init];
        _timelineItems = [[NSMutableArray alloc] init];
        
        _surePlans = [[NSMutableArray alloc] init];
        _ifPlans = [[NSMutableArray alloc] init];
        _allPlans = [[NSMutableArray alloc] init];
        _friends = [[NSMutableArray alloc] init];
        _groups = [[NSMutableArray alloc] init];
        _stamps = [[NSMutableArray alloc] init];
        
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    

    _userId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _name = [NSString returnStringObjectForKey:@"name" withDictionary:dict];
    _username = [NSString returnStringObjectForKey:@"username" withDictionary:dict];
    _firstname = [NSString returnStringObjectForKey:@"firstname" withDictionary:dict];
    _lastname = [NSString returnStringObjectForKey:@"lastname" withDictionary:dict];
    _cid = [NSString returnStringObjectForKey:@"cid" withDictionary:dict];
    _email = [NSString returnStringObjectForKey:@"email" withDictionary:dict];
    _img = [NSString returnStringObjectForKey:@"image_url" withDictionary:dict];
    _imgLarge = [NSString returnStringObjectForKey:@"image_url" withDictionary:dict];
    _imgBanner = [NSString returnStringObjectForKey:@"image_banner_url" withDictionary:dict];
    _currentCity = [NSString returnStringObjectForKey:@"current_city" withDictionary:dict];
    _showCity = [NSString returnStringObjectForKey:@"show_city" withDictionary:dict];
    _homeTown = [NSString returnStringObjectForKey:@"home_town" withDictionary:dict];
    _degrees = [NSString returnStringObjectForKey:@"degrees" withDictionary:dict];
    _phone = [NSString returnStringObjectForKey:@"phone" withDictionary:dict];
    
    if([_homeTown isEmpty]){
        _homeTown = _currentCity;
    }
    
    [_timelineItems removeAllObjects];
    for(NSDictionary *d in [dict objectForKey:@"timeline"]){
        AppActivity *a = [[AppActivity alloc] initWithDictionary:d];
        [_timelineItems addObject:a];
    }
    
    [_beenThereItems removeAllObjects];
    for(NSDictionary *d in [dict objectForKey:@"beenthere"]){
        AppBeenThere *a = [[AppBeenThere alloc] initWithDictionary:d];
        [_beenThereItems addObject:a];
    }

    [_friends removeAllObjects];
    for(NSDictionary *d in [dict objectForKey:@"friends"]){
        AppContact *c = [[AppContact alloc] initWithDictionary:d];
        [_friends addObject:c];
    }
    
    _friendsBlocked = [[NSString returnStringObjectForKey:@"friends_blocked" withDictionary:dict] isEqualToString:@"Y"];
    _hasNewActivity = [[NSString returnStringObjectForKey:@"has_activity" withDictionary:dict] isEqualToString:@"Y"];
    
    _lastSeenActivityTime = [[NSString returnStringObjectForKey:@"seen_activity" withDictionary:dict] doubleValue];
    
    [_groups removeAllObjects];
    
    for(NSDictionary *d in [dict objectForKey:@"groups"]){
        AppGroup *c = [[AppGroup alloc] initWithDictionary:d];
        [_groups addObject:c];
    }
    
    [_surePlans removeAllObjects];
    for(NSDictionary *d in [dict objectForKey:@"sure"]){
        AppPlan *c = [[AppPlan alloc] initWithDictionary:d];
        [_surePlans addObject:c];
    }
    
    [_ifPlans removeAllObjects];
    for(NSDictionary *d in [dict objectForKey:@"if"]){
        AppPlan *c = [[AppPlan alloc] initWithDictionary:d];
        [_ifPlans addObject:c];
    }
    
    [_stamps removeAllObjects];
    for(NSDictionary *d in [dict objectForKey:@"stamps"]){
        [_stamps addObject:d];
    }
    
    _allowNotifications = [[NSString returnStringObjectForKey:@"notifications" withDictionary:dict] isEqualToString:@"Y"];
    _isPrivate = [[NSString returnStringObjectForKey:@"private" withDictionary:dict] isEqualToString:@"Y"];
}

-(void)doubleCheckGroupsHaveAdd{

}


-(BOOL)isFriendsWithContact:(AppContact *)contact{
 
    NSPredicate *p = [NSPredicate predicateWithFormat:@"storedIdString == %@", contact.storedIdString];
    NSArray *searchResults = [_friends filteredArrayUsingPredicate:p];
    return NO;
}


-(void)refreshUserDataFromServer{
    
    if(_userId == nil){
        return;
    }
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:_userId forKey:@"user_id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    [manager POST:[AppAPIBuilder APIForGetUser:nil] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            [self addKeyValueFromDictionary:[responseObject objectForKey:@"user"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_INFO_UPDATED object:nil];            
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


-(AppPlan *)getFirstUpcomingPlanType:(int)ptype{
    NSTimeInterval rightNow = [[NSDate date] timeIntervalSince1970];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"startDateInterval <= %f AND %f <= endDateInterval",rightNow,rightNow];
    NSArray *foundItems = (ptype == AppPlanTypeSure) ? [_surePlans filteredArrayUsingPredicate:p] : [_ifPlans filteredArrayUsingPredicate:p];
    
    if([foundItems count] > 0){
        AppPlan *foundPlan = [foundItems firstObject];
        return foundPlan;
    }else{
        p = [NSPredicate predicateWithFormat:@"startDateInterval >= %f",rightNow];
        foundItems = (ptype == AppPlanTypeSure) ? [_surePlans filteredArrayUsingPredicate:p] : [_ifPlans filteredArrayUsingPredicate:p];
        if([foundItems count] > 0){
            AppPlan *foundPlan = [foundItems firstObject];
            return foundPlan;
        }
    }
    return nil;
}

-(void)setupPlansWithDictionary:(NSDictionary *)dict{
    
    if([dict objectForKey:@"plans"] != nil){
        [_allPlans removeAllObjects];
        for(NSDictionary *d in [dict objectForKey:@"plans"]){
            [_allPlans addObject:[[AppPlan alloc] initWithDictionary:d]];
        }
    }
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"planType == 0"];
    NSArray *foundItems = [_allPlans filteredArrayUsingPredicate:p];
    _surePlans = [[NSMutableArray alloc] initWithArray:foundItems];
    
    p = [NSPredicate predicateWithFormat:@"planType == 1"];
    foundItems = [_allPlans filteredArrayUsingPredicate:p];
    _ifPlans = [[NSMutableArray alloc] initWithArray:foundItems];
}

-(void)setToken:(NSString *)token{
    _token = token;
    [self saveUserData];
//    [CrashlyticsKit setUserIdentifier:_userId];
//    [CrashlyticsKit setUserEmail:_email];
//    [CrashlyticsKit setUserName:_name];

}



-(void)loadStoredUserData{
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"];
    if(token != nil){
        _token = token;
    }
}

-(void)saveUserData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(!_token){
        [defaults setObject:@"" forKey:@"userToken"];
    }else{
        [defaults setObject:_token forKey:@"userToken"];
    }
    [defaults synchronize];
}


-(void)removeAllData{
    _token = nil;
    _contacts = [[NSMutableArray alloc] init];
    _latestInvites = [[NSMutableArray alloc] init];
    _unarchivedContacts = [[NSMutableArray alloc] init];
    _dreamingOfLocations = [[NSMutableArray alloc] init];
    _surePlans = [[NSMutableArray alloc] init];
    _ifPlans = [[NSMutableArray alloc] init];
    _allPlans = [[NSMutableArray alloc] init];

    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
    [[RAVNPush sharedInstance] resetBadgeToZero];
}




@end
