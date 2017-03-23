//
//  AppContact.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/19/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppContact.h"
#import "NSString+Additions.h"

@implementation AppContact


- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if (self) {
        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
    _token = [NSString returnStringObjectForKey:@"token" withDictionary:dict];
    _userId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _name = [NSString returnStringObjectForKey:@"name" withDictionary:dict];
    _cid = [NSString returnStringObjectForKey:@"cid" withDictionary:dict];
    _email = [NSString returnStringObjectForKey:@"email" withDictionary:dict];
    _img = [NSString returnStringObjectForKey:@"image_url" withDictionary:dict];
    _imgLarge = [NSString returnStringObjectForKey:@"image_url" withDictionary:dict];
    _pendingInvite = [[NSString returnStringObjectForKey:@"pending" withDictionary:dict] isEqualToString:@"Y"];
    _currentCity = [NSString returnStringObjectForKey:@"current_city" withDictionary:dict];
    _showCity = [NSString returnStringObjectForKey:@"show_city" withDictionary:dict];
    _homeTown = [NSString returnStringObjectForKey:@"home_town" withDictionary:dict];
    _isSetInStone = [[NSString returnStringObjectForKey:@"stone" withDictionary:dict] isEqualToString:@"Y"];
    _acceptedPlanJoinInvite = [[NSString returnStringObjectForKey:@"accepted" withDictionary:dict] isEqualToString:@"Y"];
    
    
    
    if([_homeTown isEmpty]){
        _homeTown = _currentCity;
    }
    
}




-(AppContact *)initWithRecord:(ABRecordRef)contact{
    
    self = [self init];
    if (self) {
        
        ABRecordID recordID = ABRecordGetRecordID(contact);
        _storedId = recordID;
        _storedIdString = [NSString stringWithFormat:@"%d",_storedId];
        _firstName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonFirstNameProperty);
        _lastName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonLastNameProperty);
        
        
        if([_firstName isEqualToString:@""] || [_firstName isEmpty] || [_firstName isEqualToString:@"(null)"] || _firstName == nil){
            _firstName = @"";
        }
        
        if([_lastName isEqualToString:@""] || [_lastName isEmpty] || [_lastName isEqualToString:@"(null)"] || _lastName == nil){
            _lastName = @"";
        }
        
        if([_firstName isEqualToString:@""] && [_lastName isEqualToString:@""] ){
            _noName = YES;
        }
        
        
        _name = [NSString stringWithFormat:@"%@ %@",_firstName,_lastName];
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        
        _primaryPhone = @"";
        _phoneNumbers = [[NSMutableArray alloc] init];
        
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            
            if([phoneNumber isNotEmpty]){
                [_phoneNumbers addObject:phoneNumber];
            }
        }
        
        if([_phoneNumbers count] > 0){
            _primaryPhone = [_phoneNumbers firstObject];
        }
        
        ABMultiValueRef emailsFound = ABRecordCopyValue(contact, kABPersonEmailProperty);
        
        _emails = [[NSMutableArray alloc] init];
        for (CFIndex i = 0; i < ABMultiValueGetCount(emailsFound); i++) {
            NSString *emailAddy = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emailsFound, i);
            
            if([emailAddy isNotEmpty]){
                [_emails addObject:emailAddy];
            }
        }
        CFRelease(emailsFound);
    }
    
    return self;
}

-(NSString *)firstChar{
    
    if([_firstName isNotEmpty]){
        return [NSString stringWithFormat:@"%@",[_firstName substringWithRange:NSMakeRange(0, 1)]];
    }else if([_lastName isNotEmpty]){
        return [NSString stringWithFormat:@"%@",[_lastName substringWithRange:NSMakeRange(0, 1)]];
    }
        
    return [NSString stringWithFormat:@"%@",[_name substringWithRange:NSMakeRange(0, 1)]];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_databaseId forKey:@"databaseId"];
    [aCoder encodeObject:_storedIdString forKey:@"storedIdString"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_phoneNumbers options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [aCoder encodeObject:jsonString forKey:@"phoneNumbersJSON"];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init])    {
        
        _name = [NSString stringWithFormat:@"%@",[aDecoder decodeObjectForKey:@"name"]];
        _databaseId = [NSString stringWithFormat:@"%@",[aDecoder decodeObjectForKey:@"databaseId"]];
        _storedIdString = [NSString stringWithFormat:@"%@",[aDecoder decodeObjectForKey:@"storedIdString"]];
        _phoneNumbersJSON = [NSString stringWithFormat:@"%@",[aDecoder decodeObjectForKey:@"phoneNumbersJSON"]];
    }
    return self;
}



@end
