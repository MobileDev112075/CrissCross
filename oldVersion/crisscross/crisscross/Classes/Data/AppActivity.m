//
//  AppActivity.m
//  crisscross
//
//  Created by Vincent Tuscano on 6/3/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppActivity.h"

@implementation AppActivity

- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if (self) {
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
    _line1 = [NSString returnStringObjectForKey:@"l1" withDictionary:dict];
    _line2 = [NSString returnStringObjectForKey:@"l2" withDictionary:dict];
    _line3 = [NSString returnStringObjectForKey:@"l3" withDictionary:dict];
    _img = [NSString returnStringObjectForKey:@"img" withDictionary:dict];
    _usersId = [NSString returnStringObjectForKey:@"users_id" withDictionary:dict];
    _cityId = [NSString returnStringObjectForKey:@"city_id" withDictionary:dict];
    _created = [[NSString returnStringObjectForKey:@"created" withDictionary:dict] floatValue];
    _startU = [[NSString returnStringObjectForKey:@"start_date" withDictionary:dict] floatValue];
    _endU = [[NSString returnStringObjectForKey:@"end_date" withDictionary:dict] floatValue];
    _activitySectionType = [NSString returnStringObjectForKey:@"section" withDictionary:dict];
    NSString *type = [NSString returnStringObjectForKey:@"type" withDictionary:dict];
    
    
    if([type isEqualToString:@"USER"]){
        _activityType = AppActivityTypeUser;
    }else if([type isEqualToString:@"PLAN"]){
        _activityType = AppActivityTypePlan;
    }else if([type isEqualToString:@"CITY"]){
        _activityType = AppActivityTypeCity;
    }else if([type isEqualToString:@"BTDT"]){
        _activityType = AppActivityTypeBTDT;
        _btItem = [[AppBeenThere alloc] initWithDictionary:[dict objectForKey:@"bt"]];
        _btItem.isAChild = YES;
    }else{
        _activityType = AppActivityTypeStatic;
    }
    
    _usersTotal = [[NSString returnStringObjectForKey:@"users_total" withDictionary:dict] intValue];
    _usersThere = [[NSMutableArray alloc] init];
    if([dict objectForKey:@"users_there"]){
        for(NSDictionary *d in [dict objectForKey:@"users_there"]){
            [_usersThere addObject:[[AppContact alloc] initWithDictionary:d]];
        }
    }
    
    _usersInvitedToJoinPlan = [[NSMutableArray alloc] init];
    if([dict objectForKey:@"users_invited"]){
        for(NSDictionary *d in [dict objectForKey:@"users_invited"]){
            [_usersInvitedToJoinPlan addObject:[[AppContact alloc] initWithDictionary:d]];
        }
    }
    
    
    _suggestionsTotal = [[NSString returnStringObjectForKey:@"sug_total" withDictionary:dict] intValue];
    _userAcceptRejectOptions = [[NSString returnStringObjectForKey:@"options" withDictionary:dict] isEqualToString:@"USER_REQUEST"];
    _userRejectOptions = [[NSString returnStringObjectForKey:@"options" withDictionary:dict] isEqualToString:@"USER_REMOVE"];
    _swipeOptionMissJoin = [[NSString returnStringObjectForKey:@"options" withDictionary:dict] isEqualToString:@"MISS_JOIN"];
    _swipeOptionMissUpdatePlans = [[NSString returnStringObjectForKey:@"options" withDictionary:dict] isEqualToString:@"MISS_UPDATE_PLANS"];

    _swipeOptionId = [NSString returnStringObjectForKey:@"options_id" withDictionary:dict];
    
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"userId = %@",_usersId];
    NSArray *foundMatchingUser = [NSMutableArray arrayWithArray:[[AppController sharedInstance].currentUser.friends filteredArrayUsingPredicate:p]];
    

    if([foundMatchingUser count] > 0){
        _associatedContact = [foundMatchingUser firstObject];
    }
    
}

@end
