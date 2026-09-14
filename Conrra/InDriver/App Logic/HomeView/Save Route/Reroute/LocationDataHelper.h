//
//  LocationDataHelper.h
//  LTS Driver
//
//  Created by Grepix on 15/03/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol LocationDataHelperDeleage <NSObject>

-(void) drawReRoute;

@end
@interface LocationDataHelper : NSObject
@property(strong,nonatomic) NSMutableArray *array;
@property(assign,nonatomic) int inValidLocationCounter ;
@property(assign,nonatomic) int lastInValidIndex ;
@property(weak,nonatomic) id<LocationDataHelperDeleage> delegate;

-(void)addObject:(CLLocation *)location  index:(int) index;
-(int) lastValidIndex;
-(BOOL) isOnValidRoute;
-(void) removeOldObjectWhenReRoute;
@end

NS_ASSUME_NONNULL_END
