//
//  UserProfile.h
//  GetRide
//
//  Created by Grepix Infotech on 16/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserProfile : NSObject
+(UserProfile *)shared;
-(int)cityID;
-(int)loggedCityID;
@end

NS_ASSUME_NONNULL_END
