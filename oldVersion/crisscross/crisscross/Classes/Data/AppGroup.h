//
//  AppGroup.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/22/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppGroup : NSObject

@property(nonatomic,strong) NSString *groupId;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSMutableArray *usersIds;

@property(nonatomic,assign) BOOL isTopBlock;
@property(nonatomic,assign) BOOL isAll;
@property(nonatomic,assign) BOOL isAdd;
@property(nonatomic,assign) BOOL isManageView;

-(AppGroup *)initWithDictionary:(NSDictionary *)dict;

@end
