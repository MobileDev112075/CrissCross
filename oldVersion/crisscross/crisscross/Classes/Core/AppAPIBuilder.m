//
//  AppAPIBuilder.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/17/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppAPIBuilder.h"

@implementation AppAPIBuilder



+(NSSet *)APIAcceptableContentTypes{
    return [NSSet setWithObjects:@"text/plain",@"application/json",@"text/html", nil];
}

+(NSString *)APIPrefix{
    return [NSString stringWithFormat:@"%@",WEB_SERVICE_ROOT];
}

+(NSMutableDictionary *)APIDictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if([[AppController sharedInstance].currentUser.token isNotEmpty]){
        [dict setObject:[AppController sharedInstance].currentUser.token forKey:@"token"];
    }
    [dict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"v"];
    return dict;
}

+(NSString *)APIAddKeyObjects:(NSMutableDictionary *)dict toString:(NSString *)str{
    if(dict == nil)
        dict = [[NSMutableDictionary alloc] init];
    

    str = [str stringByAppendingString:[NSString stringWithFormat:@"?v=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    
    for(NSString *i in dict){
        str = [str stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",i,[dict objectForKey:i]]];
    }
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSMutableDictionary *)APIAddTokenToDictionray:(NSMutableDictionary *)dict{
    if(dict == nil)
        dict = [[NSMutableDictionary alloc] init];
    return dict;
}

+(NSString *)APIForLogin:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/login/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForLoginWithToken:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/loginWithToken/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForForgotPass:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/forgotPass/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForSignUp:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/register/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForPostAvatarAndInfo:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/postAvatarAndInfo/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForFindFriends:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/findFriends/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForInviteContacts:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/inviteContacts/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetActivity:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/getActivity/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetGroup:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/getGroup/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetUser:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/getUser/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetAllGroups:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/getAllGroups/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForUpdateFriendToFriend:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/updateFriendToFriend/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForTrackInviteSent:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/trackInviteSent/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}


+(NSString *)APIForCreateGroup:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/createGroup/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForAddToGroup:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/addToGroup/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForUpdateGroupTitle:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/updateGroupTitle/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForRemoveFromGroup:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/removeFromGroup/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForDeleteGroup:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/deleteGroup/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForPairFriends:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/pairFriends/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForRemoveFriend:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/removeFriend/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForSetFriendInStone:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/setFriendInStone/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForSearchCity:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/searchCity/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForFind:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/find/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetWeather:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/getWeather/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForDreamingOfEdit:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/dreamingOfEdit/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForSavingPlans:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/savingPlans/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetPlans:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/getPlans/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForSaveBeenThere:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/beenThereDoneThatEdit/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetCommunalBTDT:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/communalBTDT/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetCommunalBTDTFeedback:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/communalBTDTFeedback/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}
// V
+(NSString *)APIForGetBTDTSuggestions:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/getBTDTSuggetions/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForNotifyFriends:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/notifyFriends/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForRemoveStamp:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/removeStamp/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForUpdateDeviceId:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/updatePushDeviceId/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForSendToDevice:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@&a=sendToDevice",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForResetBadge:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/resetBadge/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForDuplicatePlan:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/duplicatePlan/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForRejectPlanInvite:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/rejectPlanInvite/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

+(NSString *)APIForGetPrivacyOrTerms:(NSMutableDictionary *)dict{
    
    NSString *url = [NSString stringWithFormat:@"%@/getPrivacyOrTerms/",[AppAPIBuilder APIPrefix]];
    return [AppAPIBuilder APIAddKeyObjects:dict toString:url];
}

@end
