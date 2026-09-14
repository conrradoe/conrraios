//
//  NotificationModel.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 08/05/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "NotificationModel.h"

@implementation NotificationModel
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.noitificationId=[dict objectForKey:@"id"];
        self.message=[dict objectForKey:@"message"];
        self.title=[dict objectForKey:@"title"];
        self.url=[dict objectForKey:@"url"];
        self.ref_id=[dict objectForKey:@"ref_id"];
        self.createdDate=[dict objectForKey:@"created"];
    }
    return self;
}
+(NSMutableArray<NotificationModel*> *) parseNotification:(NSArray *) array
{
    NSMutableArray * arrayNoti=[[NSMutableArray alloc] init];
    for (NSDictionary * dict in array) {
        [arrayNoti addObject:[[NotificationModel alloc] initWithDict:dict]];
    }
    return arrayNoti;
}

@end
