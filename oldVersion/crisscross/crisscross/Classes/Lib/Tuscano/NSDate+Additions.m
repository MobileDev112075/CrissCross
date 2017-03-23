//
//  NSDate+Additions.m
//  
//
//  Created by Vincent Tuscano on 12/28/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)


- (NSString *)timeAgo {
    NSString *timeAgo = @"";
    
    if (self) {
        float seconds = -1*rint([self timeIntervalSinceNow]);
        
        if (seconds < 5) {
            timeAgo = @"just now";
        } else if (seconds < 55) {
            timeAgo = [NSString stringWithFormat:@"%.0f seconds ago", seconds];
        } else if (seconds  >= 55 && seconds < 90) {
            timeAgo = @"1 minute ago";
        } else if (seconds >= 90 && seconds <= 55*60) {
            timeAgo = [NSString stringWithFormat:@"%.0f minutes ago", rint(seconds/60)];
        } else if (seconds > 55*60 && seconds <= 90*60) {
            timeAgo = @"1 hour ago";
        } else if (seconds > 90*60 && seconds <= 23.5*60*60) {
            timeAgo = [NSString stringWithFormat:@"%.0f hours ago", rint(seconds/60/60)];
        } else {
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:usLocale];
            [dateFormatter setDateFormat:@"dd MMM"];
            timeAgo = [dateFormatter stringFromDate:self];
        }
    }
    
    return timeAgo;
}

- (NSString *)timeAgoShort {
    NSString *timeAgo = @"";
    
    if (self) {
        float seconds = -1*rint([self timeIntervalSinceNow]);
    
        if (seconds < 5) {
            timeAgo = @"now";
        } else if (seconds < 55) {
            timeAgo = [NSString stringWithFormat:@"%.0fs", seconds];
        } else if (seconds  >= 55 && seconds < 90) {
            timeAgo = @"1m";
        } else if (seconds >= 90 && seconds <= 55*60) {
            timeAgo = [NSString stringWithFormat:@"%.0fm", rint(seconds/60)];
        } else if (seconds > 55*60 && seconds <= 90*60) {
            timeAgo = @"1h";
        } else if (seconds > 90*60 && seconds <= 23.5*60*60) {
            timeAgo = [NSString stringWithFormat:@"%.0fh", rint(seconds/60/60)];
        } else {
            
            NSDate *now = [NSDate date];
            int days = (int)[NSDate daysBetweenDate:self andDate:now];
            timeAgo = [NSString stringWithFormat:@"%dd",days];
            
        }
    }
    return timeAgo;
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

//
//+(NSString*)formatTimeFromSeconds:(int)totalSeconds{
//    
//    int seconds = totalSeconds % 60;
//    int minutes = (totalSeconds / 60) % 60;
//    int hours = totalSeconds / 3600;
//    
//    if(hours)
//        return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
//    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
//}

@end
