//
//  NotificationModel.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 08/05/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NotificationModel : NSObject
@property(strong ,nonatomic) NSString * noitificationId;
@property(strong ,nonatomic) NSString * message;
@property(strong ,nonatomic) NSString * title;
@property(strong ,nonatomic) NSString * url;
@property(strong ,nonatomic) NSString * createdDate;
@property(strong ,nonatomic) NSString * ref_id;

- (instancetype)initWithDict:(NSDictionary *)dict;
+(NSMutableArray<NotificationModel*> *) parseNotification:(NSArray *) array;
@end

NS_ASSUME_NONNULL_END
