//
//  AppGroup.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/22/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppGroup.h"
#import "NSString+Additions.h"

@implementation AppGroup


- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if (self) {
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
    
    _groupId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _title = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    _isTopBlock = [[NSString returnStringObjectForKey:@"isTopBlock" withDictionary:dict] isEqualToString:@"Y"];
    _isAll = [[NSString returnStringObjectForKey:@"isAll" withDictionary:dict] isEqualToString:@"Y"];
    _isAdd = [[NSString returnStringObjectForKey:@"isAdd" withDictionary:dict] isEqualToString:@"Y"];

    _usersIds = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"ids"]];
    
}



@end
