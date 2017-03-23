//
//  NSString+Additions.h
//  
//
//  Created by Vincent Tuscano on 12/25/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)


+ (NSString *)base64Encode:(NSString *)plainText;
+ (NSString *)base64Decode:(NSString *)base64String;
+ (NSString *)returnStringObjectForKey:(NSString *)str withDictionary:(NSDictionary *)dict;
+(NSString *)removeNull:(NSString *)str;
- (BOOL)isEmpty;
- (BOOL)isNotEmpty;
- (BOOL)isEmail;

@end
