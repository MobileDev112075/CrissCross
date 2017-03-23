//
//  AppPlan.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/30/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppPlan.h"

@implementation AppPlan

- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if (self) {
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
    _planId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _title = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    _img = [NSString returnStringObjectForKey:@"photo" withDictionary:dict];
    _locationsId = [NSString returnStringObjectForKey:@"locations_id" withDictionary:dict];
    
    _startDateInterval = [[NSString returnStringObjectForKey:@"start_date" withDictionary:dict] floatValue];
    _endDateInterval = [[NSString returnStringObjectForKey:@"end_date" withDictionary:dict] floatValue];
    
    
    _planMessage = [NSString returnStringObjectForKey:@"plan_message" withDictionary:dict];
    _planType = [[NSString returnStringObjectForKey:@"plans_type_id" withDictionary:dict] intValue];
    
    _howTransitId = [[NSString returnStringObjectForKey:@"how_id" withDictionary:dict] intValue];
    _kindOfPlanId = [NSString returnStringObjectForKey:@"kind_of_types_id" withDictionary:dict];
    
    
    _kindOfPlanIds = [_kindOfPlanId componentsSeparatedByString:@","];
    
    _isViewableByAll = [[NSString returnStringObjectForKey:@"viewable_by_all" withDictionary:dict] isEqualToString:@"Y"];
    
    
    if([dict objectForKey:@"shared_groups_id"])
        _sharedWithGroupsIds = [NSArray arrayWithArray:[dict objectForKey:@"shared_groups_id"]];
    else
        _sharedWithGroupsIds = @[];
    
    
    if([dict objectForKey:@"shared_users_id"])
        _sharedWithUsersIds = [NSArray arrayWithArray:[dict objectForKey:@"shared_users_id"]];
    else
        _sharedWithUsersIds = @[];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSInteger currentTimeZoneOffset = -1 * [[dateFormatter timeZone] secondsFromGMT];
    
    _startDateInterval += currentTimeZoneOffset;

    
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:_startDateInterval];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];

    
    NSString *currentTimeZone = [[dateFormatter timeZone] abbreviation];
    _endDateInterval += currentTimeZoneOffset;

    
    dateFormatter = [[NSDateFormatter alloc] init];
    epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:_endDateInterval];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    currentTimeZone = [[dateFormatter timeZone] abbreviation];

    
    
    
    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate dateWithTimeIntervalSince1970:_startDateInterval]];
    NSInteger day = [components day];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM"];
    NSString *startMonthString = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:_startDateInterval]];
    
    
    _dateTitleStart = [NSString stringWithFormat:@"%@ %d",[startMonthString uppercaseString],(int)day];
    
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate dateWithTimeIntervalSince1970:_endDateInterval]];
    NSInteger endDay = [components2 day];
    NSString *endMonthString = [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:_endDateInterval]];
    

    _dayNum = [NSString stringWithFormat:@"%d",(int)day];
    _byline = [NSString stringWithFormat:@"%@ %d TO %@ %d ",[startMonthString uppercaseString],(int)day,[endMonthString uppercaseString],(int)endDay];
    
    _dayNumEnd = [NSString stringWithFormat:@"%d",(int)endDay];
    
    _dateTitleEnd = [NSString stringWithFormat:@"%@ %d",[endMonthString uppercaseString],(int)endDay];
    _overlappedUsers = [[NSMutableArray alloc] init];
    
    if([dict objectForKey:@"overlap"]){
        for(NSDictionary *d in [dict objectForKey:@"overlap"]){
            [_overlappedUsers addObject:[[AppContact alloc] initWithDictionary:d]];
        }
    }
    
    
}

@end
