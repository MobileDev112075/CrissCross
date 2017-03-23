//
//  NSDate+Additions.h
//  
//
//  Created by Vincent Tuscano on 12/28/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

- (NSString *)timeAgo;
- (NSString *)timeAgoShort;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@end
