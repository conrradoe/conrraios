//
//  UserProfile.m
//  GetRide
//
//  Created by Grepix Infotech on 16/12/24.
//

#import "UserProfile.h"
#import "WebCallConstants.h"
@implementation UserProfile
static UserProfile *_sharedMySingleton = nil;

+(UserProfile *)shared {
    @synchronized([UserProfile class]) {
        if (!_sharedMySingleton)
          _sharedMySingleton = [[self alloc] init];
        return _sharedMySingleton;
    }
    return nil;
}
-(int)cityID{
    NSDictionary * dict = defaults_object(P_USER_DICT);
    if([[dict objectForKey:P_CITY_ID] intValue]>0){
        return [[dict objectForKey:P_CITY_ID] intValue];
    }
    if([[dict objectForKey:P_P_CITY_ID] intValue]>0){
        return [[dict objectForKey:P_P_CITY_ID] intValue];
    }
    return  0;
}

-(int)loggedCityID{
    NSDictionary * dict = defaults_object(P_USER_DICT_LOGGED);
    if([[dict objectForKey:P_CITY_ID] intValue]>0){
        return [[dict objectForKey:P_CITY_ID] intValue];
    }
    if([[dict objectForKey:P_P_CITY_ID] intValue]>0){
        return [[dict objectForKey:P_P_CITY_ID] intValue];
    }
    return  0;
}
@end
