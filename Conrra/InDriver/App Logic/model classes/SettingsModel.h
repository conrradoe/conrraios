//
//  ConstantModel.h
//  HireMe Rider
//
//  Created by  Appicial on 04/09/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsModel : NSObject

@property(nonatomic,strong) NSString *driver_docs;
@property(nonatomic,strong) NSString *aboutUsUrl;
@property(nonatomic,strong) NSString *privacyUrl;
@property(nonatomic,strong) NSString * tnc;
@property(nonatomic,strong) NSArray *legal;
@property(nonatomic,strong) NSString * fare_policy_url;
@property(nonatomic,strong) NSString * ios_driver_app_ver;
@property(nonatomic,strong) NSString * refer_image;
//@property(nonatomic,strong) NSMutableArray *redZoneGeofenceArray;
@property(nonatomic,strong) NSString * enable_chat;

-(instancetype)initItemWithDict:(NSArray *)array;
+(SettingsModel *) getSettignsObject;
-(void) refreshObject;


@end
