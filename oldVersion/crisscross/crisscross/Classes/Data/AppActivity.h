//
//  AppActivity.h
//  crisscross
//
//  Created by Vincent Tuscano on 6/3/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppBeenThere.h"
typedef enum{
    AppActivityTypeStatic = 0,
    AppActivityTypeUser = 1,
    AppActivityTypePlan = 2,
    AppActivityTypeCity = 3,
    AppActivityTypeBTDT
}
AppActivityIdType;

@interface AppActivity : NSObject

@property(nonatomic,strong) NSString *line1;
@property(nonatomic,strong) NSString *line2;
@property(nonatomic,strong) NSString *line3;
@property(nonatomic,strong) NSString *img;
@property(nonatomic,strong) NSString *usersId;
@property(nonatomic,strong) NSString *cityId;

@property(nonatomic,assign) int usersTotal;
@property(nonatomic,assign) int suggestionsTotal;
@property(nonatomic,strong) NSMutableArray *usersThere;
@property(nonatomic,strong) NSMutableArray *usersInvitedToJoinPlan;

@property(nonatomic,assign) NSTimeInterval created;
@property(nonatomic,assign) NSTimeInterval startU;
@property(nonatomic,assign) NSTimeInterval endU;
@property(nonatomic,assign) BOOL userAcceptRejectOptions;
@property(nonatomic,assign) BOOL userRejectOptions;
@property(nonatomic,assign) BOOL swipeOptionMissJoin;
@property(nonatomic,assign) BOOL swipeOptionMissUpdatePlans;



@property(nonatomic,strong) NSString *swipeOptionId;
@property(nonatomic,assign) BOOL isSearchResult;

@property(nonatomic,assign) NSString *activitySectionType;
@property(nonatomic,assign) AppActivityIdType activityType;
@property(nonatomic,strong) AppBeenThere *btItem;
@property(nonatomic,strong) AppContact *associatedContact;

-(AppActivity *)initWithDictionary:(NSDictionary *)dict;

@end
