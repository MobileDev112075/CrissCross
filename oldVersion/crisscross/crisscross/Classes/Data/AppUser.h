//
//  AppUser.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppPlan.h"
#import "AppContact.h"

@interface AppUser : NSObject

@property(nonatomic,strong) NSString *userId;
@property(nonatomic,strong) NSString *uniqueId;
@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) NSString *cid;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *username;
@property(nonatomic,strong) NSString *currentCity;
@property(nonatomic,strong) NSString *showCity;
@property(nonatomic,strong) NSString *homeTown;
@property(nonatomic,strong) NSString *firstname;
@property(nonatomic,strong) NSString *lastname;
@property(nonatomic,strong) NSString *phone;
@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSString *img;
@property(nonatomic,strong) NSString *imgLarge;
@property(nonatomic,strong) NSData *imgData;
@property(nonatomic,strong) NSString *imgBanner;
@property(nonatomic,strong) NSString *degrees;


@property(nonatomic,strong) NSMutableArray *contacts;
@property(nonatomic,strong) NSMutableArray *unarchivedContacts;
@property(nonatomic,strong) NSMutableArray *latestInvites;

@property(nonatomic,strong) NSMutableArray *stamps;
@property(nonatomic,strong) NSMutableArray *surePlans;
@property(nonatomic,strong) NSMutableArray *ifPlans;
@property(nonatomic,strong) NSMutableArray *allPlans;
@property(nonatomic,strong) NSMutableArray *friends;
@property(nonatomic,strong) NSMutableArray *groups;
@property(nonatomic,strong) NSMutableArray *dreamingOfLocations;
@property(nonatomic,strong) NSMutableArray *beenThereItems;
@property(nonatomic,strong) NSMutableArray *timelineItems;

@property(nonatomic,assign) BOOL friendsBlocked;
@property(nonatomic,assign) BOOL allowNotifications;
@property(nonatomic,assign) BOOL isPrivate;
@property(nonatomic,assign) BOOL hasNewActivity;

@property(nonatomic,assign) NSTimeInterval lastSeenActivityTime;


-(void)doubleCheckGroupsHaveAdd;
-(AppUser *)initWithDictionary:(NSDictionary *)dict;
-(void)loadStoredUserData;
-(void)saveUserData;
-(void)removeAllData;
-(void)addKeyValueFromDictionary:(NSDictionary *)dict;
-(void)refreshUserDataFromServer;
-(void)setupPlansWithDictionary:(NSDictionary *)dict;
-(AppPlan *)getFirstUpcomingPlanType:(int)ptype;
-(BOOL)isFriendsWithContact:(AppContact *)contact;


@end
