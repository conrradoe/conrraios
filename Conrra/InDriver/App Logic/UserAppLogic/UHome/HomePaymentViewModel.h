//
//  HomePaymentViewModel.h
//  HireMeRider
//
//  Created by Grepix Infotech on 20/09/23.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface HomePaymentViewModel : NSObject
@property (assign, nonatomic) int paymentMode;
@property (strong, nonatomic) NSString *paymentModeText;
@property (strong, nonatomic) NSString *cardNumber;
@property (strong, nonatomic) NSString *paymentMethod;
@property (strong, nonatomic) NSString *tripPayMode;

@property (strong, nonatomic) UIImage *paymentModeImage;
-(instancetype)init:(int) paymentMode;
-(void) updatePaymentModeText:(int) paymentMode;
-(void) updatePaymentModeText:(int) paymentMode cardNumber:(NSString *)cardNumber;
@end

NS_ASSUME_NONNULL_END
