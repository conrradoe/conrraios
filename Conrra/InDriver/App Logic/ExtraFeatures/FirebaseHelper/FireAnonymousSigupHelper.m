//
//  FireAnonymousSigupHelper.m
//  TeamJoe
//
//  Created by Grepix Infotech on 19/01/18.
//  Copyright © 2023 ZappDesignTemplates. All rights reserved.
//

#import "FireAnonymousSigupHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "AppDelegate.h"

@import Firebase;
@interface FireAnonymousSigupHelper()
{
    int userCount;
}
@property (strong,nonatomic) NSMutableArray *arrSearchFriends;
@end


@implementation FireAnonymousSigupHelper

-(instancetype)init{
    
    self = [super init];
    if (self){
    }
    return self;
}

-(void)updateAllUsersFirebaseID{
    userCount =0;
    [UtilityClass setLH:NO wt:@"getting..."];
}

-(void)checkFireID{
  
}

-(void)updateFireID:(NSDictionary*)dict withCompletion:(completionFirebase)completion{
   
}


-(NSMutableArray  *) arrayToObject:(NSArray *)  array
{
    NSMutableArray *a=[[NSMutableArray alloc] init];
    return a;
}

////////////////


#pragma  - mark Check Fire ID and Update

+(void)checkFireIdAndUpdateInProfileWithComBlock:(NSDictionary *) dictUser comBlock:(completionFirebase)  comBlock{
    NSString *fId=[dictUser objectForKey:P_FIRE_ID];
    if(fId.length>0) {
        BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
        NSString *email=[NSString stringWithFormat:@"%@%@",pre_fix_fire_email,isEmpty([dictUser objectForKey:P_EMAIL])];
        if(is_user_login){
            email=[NSString stringWithFormat:@"%@%@",pre_fix_u_fire_email,isEmpty([dictUser objectForKey:P_U_EMAIL])];
        }
        [[FIRAuth auth] signInWithEmail:isEmpty(email)
                               password:[ dictUser objectForKey:@"fire_password"]
                             completion:^(FIRAuthDataResult * _Nullable authResult,
                                          NSError * _Nullable error) {
             if(error!=nil)  {
                 [self createUSerTo:dictUser comBlock :comBlock];
             }else{
                 comBlock(dictUser,nil);
             }
        }];
    }
    else {
        BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
        NSString *email=[NSString stringWithFormat:@"%@%@",pre_fix_fire_email,isEmpty([dictUser objectForKey:P_EMAIL])];
        if(is_user_login){
            email=[NSString stringWithFormat:@"%@%@",pre_fix_u_fire_email,isEmpty([dictUser objectForKey:P_U_EMAIL])];
        }
        [[FIRAuth auth] signInWithEmail:isEmpty(email)
                               password:default_fire_password/*[ dictUser objectForKey:@"fire_password"]*/
                             completion:^(FIRAuthDataResult * _Nullable authResult,
                                          NSError * _Nullable error) {
             if(error!=nil)  {
                 [self createUSerTo:dictUser comBlock :comBlock];
             }else{
                 [self addFirebaseIdToUserProfile:authResult.user.uid];
             }
            comBlock(dictUser,nil);
        }];
    }
}

+(void) createUSerTo:(NSDictionary *) dictUser comBlock:(completionFirebase)  comBlock{
    NSString *email=[NSString stringWithFormat:@"%@%@",pre_fix_fire_email,isEmpty([dictUser objectForKey:P_EMAIL])];
    BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
    if(is_user_login){
        email=[NSString stringWithFormat:@"%@%@",pre_fix_u_fire_email,isEmpty([dictUser objectForKey:P_U_EMAIL])];
    }
    [[FIRAuth auth] createUserWithEmail:isEmpty(email)
                               password:[ dictUser objectForKey:@"fire_password"]
                             completion:^(FIRAuthDataResult * _Nullable authResult,
                                          NSError * _Nullable error) {
        if (error == nil) {
            [self addFirebaseIdToUserProfile:authResult.user.uid];
        }
        else {
           
        }
        comBlock(dictUser,error);
    }];
}

/**
 Update the Anonymous  firebase id to tJ user  Profile
 */
+(void) addFirebaseIdToUserProfile:(NSString *) firebaseId{
    if(firebaseId.length>0) {
        NSDictionary *dictLogged = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
        NSDictionary *dict=@{P_FIRE_ID:isEmpty(firebaseId),P_USER_ID:[dictLogged objectForKey:P_USER_ID]};
        [GIC mkwu:UPDATE_USER_PROFILE   d:dict  isa:NO   cb:^(id results, NSError *error) {
            if ([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]) {
                defaults_set_object(P_USER_DICT,[results objectForKey:P_RESPONSE] );
                defaults_set_object(P_USER_DICT_LOGGED,[results objectForKey:P_RESPONSE] );
            }
        }];
    }
}


- (NSError *)ValidateResponse:(NSDictionary *)dict {
    
    //  if (![[dict objectForKey:P_STATUS] isEqualToString:P_STATUS_OK] &&
    //               [[UIApplication sharedApplication] applicationState] ==
    //               UIApplicationStateActive) {
    //
    //
    //        if(([[dict objectForKey:P_MESSAGE] length] > 0))
    //        {
    //            [UtilityClass showWarningAlert:@""
    //                                   message:[dict objectForKey:P_MESSAGE]
    //                         cancelButtonTitle:@"Ok"
    //                          otherButtonTitle:nil];
    //        }else
    //        {
    //            RTAlertView *preAlertView=[[APP_DELEGATE mediaUpload] alertView];
    //            if(!(preAlertView!=nil&&[preAlertView isVisible]))
    //            {
    //                RTAlertView *customAlertView =
    //                [[RTAlertView alloc] initWithTitle:@""
    //                                           message:([[dict objectForKey:P_MESSAGE] length] > 0)
    //                 ? [dict objectForKey:P_MESSAGE]
    //                                                  : @"We are experiencing server timing issues, please try again in a few seconds"/*@"Your internet connection appears to be "
    //                                                                                                                                   @"down. " @"Please check it and try again."*/
    //                                          delegate:nil
    //                                 cancelButtonTitle:@"Ok"
    //                                  otherButtonTitle:nil];
    //                customAlertView.delegate = nil;
    //
    //                customAlertView.alertViewStyle = UIAlertViewStyleDefault;
    //                [[APP_DELEGATE mediaUpload] setAlertView:customAlertView];
    //                [customAlertView show];
    //            }
    //        }
    //
    //
    //
    //
    //
    //    }
    return nil;
}
@end

