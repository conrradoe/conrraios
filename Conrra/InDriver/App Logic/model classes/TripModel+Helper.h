//
//  TripModel+Helper.h
//  InDriver
//
//  Created by Grepix on 19/11/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "TripModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TripModel (Helper)
-(NSString *) pickupLocationApp;
-(NSString *) dropLocationApp;
-(NSString *) pickupTitleWithPickUpTime;
-(NSString *) dropTitleWithDropTime;
-(void)sendChatNotificationToDriver:(NSString *)message;
-(void)sendChatNotificationToUser:(NSString *)message;
-(BOOL) isTripCancelledForStatus;
@end

NS_ASSUME_NONNULL_END
