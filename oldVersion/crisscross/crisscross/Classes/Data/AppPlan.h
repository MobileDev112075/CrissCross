//
//  AppPlan.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/30/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppPlan : NSObject


@property(nonatomic,strong) NSString *planId;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *dayNum;
@property(nonatomic,strong) NSString *dayNumEnd;
@property(nonatomic,strong) NSString *byline;
@property(nonatomic,strong) NSString *img;
@property(nonatomic,strong) NSString *locationsId;

@property(nonatomic,strong) NSString *planMessage;

@property(nonatomic,assign) BOOL markAsConflict;
@property(nonatomic,assign) BOOL isViewableByAll;
@property(nonatomic,assign) int planType;
@property(nonatomic,assign) int howTransitId;
@property(nonatomic,strong) NSString *kindOfPlanId;
@property(nonatomic,strong) NSArray *kindOfPlanIds;

@property(nonatomic,strong) NSArray *sharedWithGroupsIds;
@property(nonatomic,strong) NSArray *sharedWithUsersIds;

@property(nonatomic,strong) NSString *dateTitleStart;
@property(nonatomic,strong) NSString *dateTitleEnd;

@property(nonatomic,strong) NSMutableArray *overlappedUsers;

@property(nonatomic,assign) NSTimeInterval startDateInterval;
@property(nonatomic,assign) NSTimeInterval endDateInterval;

-(AppPlan *)initWithDictionary:(NSDictionary *)dict;

@end
