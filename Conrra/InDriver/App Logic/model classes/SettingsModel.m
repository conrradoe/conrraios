//
//  ConstantModel.m
//  HireMe Rider
//
//  Created by  Appicial on 04/09/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "SettingsModel.h"
#import "CityModel.h"
#import <GIKit/GIKit.h>
#import "Utilities.h"
@implementation SettingsModel
static SettingsModel *instance;


- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(instancetype)initItemWithDict:(NSArray *)array;
{
    self = [super init];
    if (self) {
        [self parserData:array];
    }
    
    return self;
    
}

-(void)parserData:(NSArray *) array{
    
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:@"skey"]isEqualToString:@"driver_docs"]){
            self.driver_docs=[dict objectForKey:@"svalue"];
        }else if ([[dict objectForKey:@"skey"]isEqualToString:@"enable_aboutus"]){
            self.aboutUsUrl=[dict objectForKey:@"svalue"];
        }
        else if ([[dict objectForKey:@"skey"]isEqualToString:@"enable_pp"]){
            self.privacyUrl=[dict objectForKey:@"svalue"];
        }
        else if ([[dict objectForKey:@"skey"]isEqualToString:@"tnc"]){
            self.tnc=[dict objectForKey:@"svalue"];
        }else if ([[dict objectForKey:@"skey"]isEqualToString:@"fare_policy_url"]){
            self.fare_policy_url=[dict objectForKey:@"svalue"];
        }else if ([[dict objectForKey:@"skey"]isEqualToString:@"ios_driver_app_ver"]){
            self.ios_driver_app_ver=[dict objectForKey:@"svalue"];
        }
        else if ([[dict objectForKey:@"skey"]isEqualToString:@"refer_image"]){
            self.refer_image=[dict objectForKey:@"svalue"];
        }
        else if ([[dict objectForKey:@"skey"]isEqualToString:@"enable_chat"]){
            self.enable_chat=[dict objectForKey:@"svalue"];
        }
        
        else if ([[dict objectForKey:@"skey"]isEqualToString:@"legal"]){
            NSString *legal=[dict objectForKey:@"svalue"];
            if(legal.length>0)
            {
                NSData *data = [legal dataUsingEncoding:NSUTF8StringEncoding];
                self.legal = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            }
        }
        else if ([[dict objectForKey:@"skey"]isEqualToString:@"red_zone"]){
            //               self.redZoneGeofenceArray=[Utilities idFormJsonString:[dict objectForKey:@"svalue"]];
//            [self loadLocalCityGeoFanceJson:[Utilities idFormJsonString:[dict objectForKey:@"svalue"]]];
        }
        
    }
}
-(void) refreshObject{
    NSArray * arr = defaults_object(@"settingResponse");
    if([arr isKindOfClass:[NSArray class]]&&arr.count>0) {
        [self parserData:arr];
    }
}


//-(void)loadLocalCityGeoFanceJson:(NSDictionary*)redZoneJson{
//    
//    if([redZoneJson isKindOfClass:[NSDictionary class]]) {
//        NSString * stringType=[ redZoneJson objectForKey:@"type"];
//        NSArray * arrayCordinates;
//        if([stringType isEqualToString:@"GeometryCollection"])   {
//            NSArray * geometries=[redZoneJson objectForKey:@"geometries"];
//            if(geometries.count>0)  {
//                arrayCordinates=[[geometries objectAtIndex:0] objectForKey:@"coordinates"];
//            }
//        }else{
//            arrayCordinates=[redZoneJson objectForKey:@"coordinates"];
//        }
//        self.redZoneGeofenceArray=[[NSMutableArray alloc]  init ];
//        
//        for (NSArray * arrayChild in arrayCordinates ) {
//            NSMutableArray*arrayMulti=[[NSMutableArray alloc]  init ];
//            
//            for (NSArray * arrayChild2 in arrayChild ) {
//                for (NSArray * arrayChild3 in arrayChild2 ) {
//                    if(arrayChild3.count>1)
//                    {
//                        CLLocation * location=[[CLLocation alloc] initWithLatitude:[[arrayChild3 objectAtIndex:1] doubleValue] longitude:[[arrayChild3 objectAtIndex:0] doubleValue]];
//                        //                            CLLocation * location=[[CLLocation alloc] initWithLatitude:[[arrayChild3 objectAtIndex:0] doubleValue] longitude:[[arrayChild3 objectAtIndex:1] doubleValue]];
//                        [arrayMulti addObject:location];
//                    }
//                }
//            }
//            [self.redZoneGeofenceArray addObject:arrayMulti];
//        }
//    }
//}

+(SettingsModel *) getSettignsObject{
    if(instance!=nil){
        return instance;
    }
    NSArray * arr = defaults_object(@"settingResponse");
    if([arr isKindOfClass:[NSArray class]]&&arr.count>0) {
        instance =[[SettingsModel alloc]initItemWithDict:arr];
        return instance;
    }
    return nil;
}
@end
