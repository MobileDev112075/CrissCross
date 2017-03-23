//
//  NSString+Additions.m
//  
//
//  Created by Vincent Tuscano on 12/25/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import "NSString+Additions.h"
#import "NSData+Base64.h"

@implementation NSString (Additions)


+ (NSString *)base64Encode:(NSString *)plainText{
    NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainTextData base64EncodedString];
    return base64String;
}

+ (NSString *)base64Decode:(NSString *)base64String{
    NSData *plainTextData = [NSData dataFromBase64String:base64String];
    NSString *plainText = [[NSString alloc] initWithData:plainTextData encoding:NSUTF8StringEncoding];
    return plainText;
}

+ (NSString *)returnStringObjectForKey:(NSString *)str withDictionary:(NSDictionary *)dict{
    
    if([dict objectForKey:str]){
        NSString *string = [NSString stringWithFormat:@"%@",[dict objectForKey:str]];
        if([string isEqualToString:@"<null>"])
            return @"";

        return [NSString stringWithFormat:@"%@",[dict objectForKey:str]];
    }
    return @"";
}

+(NSString *)removeNull:(NSString *)str{
    str = [NSString stringWithFormat:@"%@",str];
    str = [str stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
    return str;
}


- (BOOL)isEmpty {
    if (self == nil) {
        return YES;
    }
    
    if ([self length] == 0) {
        return YES;
    }
    return [self isEqualToString:@""];
}


- (BOOL)isNotEmpty {
    if (self == nil) {
        return NO;
    }
    return ![self isEqualToString:@""];
}


- (BOOL)isEmail {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,18}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}


@end
