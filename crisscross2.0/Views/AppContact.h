//
//  AppContact.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AppContact : NSObject

@property(nonatomic,strong) NSString *email;
@property(nonatomic,assign) int storedId;

@property(nonatomic,strong) NSString *storedIdString;
@property(nonatomic,strong) NSString *uniqueId;
@property(nonatomic,strong) NSString *userId;
@property(nonatomic,strong) NSString *currentCity;
@property(nonatomic,strong) NSString *showCity;
@property(nonatomic,strong) NSString *homeTown;
@property(nonatomic,strong) NSString *databaseId;
@property(nonatomic,strong) NSString *prayerNotes;
@property(nonatomic,strong) NSString *img;
@property(nonatomic,strong) NSString *imgLarge;
@property(nonatomic,strong) NSString *token;
@property(nonatomic,strong) NSString *cid;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *firstName;
@property(nonatomic,strong) NSString *lastName;
@property(nonatomic,strong) NSString *primaryPhone;
@property(nonatomic,strong) NSMutableArray *phoneNumbers;
@property(nonatomic,strong) NSString *phoneNumbersJSON;
@property(nonatomic,strong) NSMutableArray *emails;

@property(nonatomic,assign) BOOL hasAppInstalled;
@property(nonatomic,assign) BOOL noName;
@property(nonatomic,assign) BOOL pendingInvite;
@property(nonatomic,assign) BOOL acceptedInvite;
@property(nonatomic,assign) BOOL acceptedPlanJoinInvite;
@property(nonatomic,assign) BOOL findFriendsAreFriends;

@property(nonatomic,assign) BOOL isSetInStone;
@property(nonatomic,assign) BOOL isBlocked;

-(AppContact *)initWithDictionary:(NSDictionary *)dict;
-(void)addKeyValueFromDictionary:(NSDictionary *)dict;
-(AppContact *)initWithRecord:(ABRecordRef)contact;


-(NSString *)firstChar;



@end
