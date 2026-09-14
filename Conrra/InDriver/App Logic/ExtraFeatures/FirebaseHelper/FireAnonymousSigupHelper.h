//
//  FireAnonymousSigupHelper.h
//  TeamJoe
//
//  Created by Grepix Infotech on 19/01/18.
//  Copyright © 2023 ZappDesignTemplates. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completionFirebase)(id result,NSError *error);
@interface FireAnonymousSigupHelper : NSObject
+(void)checkFireIdAndUpdateInProfileWithComBlock:(NSDictionary *) dictUser comBlock:(completionFirebase)  comBlock;

-(void)updateAllUsersFirebaseID;

@end
