//
//  TripTransactionManager.h
//  GetRide
//
//  Created by Grepix Infotech on 09/05/24.
//

#import <Foundation/Foundation.h>
#import "TripModel.h"
@class TripTransactionManager;
@protocol TripTransactionManagerDelegate <NSObject>

-(void) onCashPaymentCompleted;
-(void) onCashPaymentError;


@end
NS_ASSUME_NONNULL_BEGIN

@interface TripTransactionManager : NSObject

- (instancetype)initWithTrip:(TripModel*) trip;
@property(strong,nonatomic) TripModel * trip;
@property(assign,nonatomic) id<TripTransactionManagerDelegate> delegate;
-(void) payWithCashDetectComssion;
@end

NS_ASSUME_NONNULL_END
