//
//  AppAPIBuilder.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppAPIBuilder : NSObject


+(NSSet *)APIAcceptableContentTypes;
+(NSString *)APIPrefix;
+(NSMutableDictionary *)APIDictionary;
+(NSString *)APIAddKeyObjects:(NSMutableDictionary *)dict toString:(NSString *)str;
+(NSMutableDictionary *)APIAddTokenToDictionray:(NSMutableDictionary *)dict;
+(NSString *)APIForLogin:(NSMutableDictionary *)dict;
+(NSString *)APIForForgotPass:(NSMutableDictionary *)dict;

+(NSString *)APIForSignUp:(NSMutableDictionary *)dict;

+(NSString *)APIForUpdateDeviceId:(NSMutableDictionary *)dict;
+(NSString *)APIForSendToDevice:(NSMutableDictionary *)dict;


+(NSString *)APIForPostAvatarAndInfo:(NSMutableDictionary *)dict;
+(NSString *)APIForLoginWithToken:(NSMutableDictionary *)dict;
+(NSString *)APIForFindFriends:(NSMutableDictionary *)dict;
+(NSString *)APIForInviteContacts:(NSMutableDictionary *)dict;
+(NSString *)APIForPairFriends:(NSMutableDictionary *)dict;
+(NSString *)APIForGetAllGroups:(NSMutableDictionary *)dict;
+(NSString *)APIForCreateGroup:(NSMutableDictionary *)dict;
+(NSString *)APIForDeleteGroup:(NSMutableDictionary *)dict;
+(NSString *)APIForAddToGroup:(NSMutableDictionary *)dict;
+(NSString *)APIForRemoveFromGroup:(NSMutableDictionary *)dict;
+(NSString *)APIForSearchCity:(NSMutableDictionary *)dict;
+(NSString *)APIForRemoveFriend:(NSMutableDictionary *)dict;
+(NSString *)APIForGetWeather:(NSMutableDictionary *)dict;
+(NSString *)APIForSetFriendInStone:(NSMutableDictionary *)dict;
+(NSString *)APIForDreamingOfEdit:(NSMutableDictionary *)dict;
+(NSString *)APIForSavingPlans:(NSMutableDictionary *)dict;
+(NSString *)APIForGetPlans:(NSMutableDictionary *)dict;
+(NSString *)APIForGetActivity:(NSMutableDictionary *)dict;
+(NSString *)APIForGetGroup:(NSMutableDictionary *)dict;
+(NSString *)APIForUpdateFriendToFriend:(NSMutableDictionary *)dict;
+(NSString *)APIForGetUser:(NSMutableDictionary *)dict;
+(NSString *)APIForSaveBeenThere:(NSMutableDictionary *)dict;
+(NSString *)APIForFind:(NSMutableDictionary *)dict;
+(NSString *)APIForUpdateGroupTitle:(NSMutableDictionary *)dict;
+(NSString *)APIForGetCommunalBTDT:(NSMutableDictionary *)dict;
+(NSString *)APIForGetCommunalBTDTFeedback:(NSMutableDictionary *)dict;
+(NSString *)APIForRemoveStamp:(NSMutableDictionary *)dict;
+(NSString *)APIForNotifyFriends:(NSMutableDictionary *)dict;
+(NSString *)APIForGetBTDTSuggestions:(NSMutableDictionary *)dict;
+(NSString *)APIForTrackInviteSent:(NSMutableDictionary *)dict;
+(NSString *)APIForResetBadge:(NSMutableDictionary *)dict;
+(NSString *)APIForDuplicatePlan:(NSMutableDictionary *)dict;
+(NSString *)APIForRejectPlanInvite:(NSMutableDictionary *)dict;
+(NSString *)APIForGetPrivacyOrTerms:(NSMutableDictionary *)dict;

@end
