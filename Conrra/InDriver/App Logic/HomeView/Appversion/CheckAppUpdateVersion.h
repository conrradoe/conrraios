//
//  CheckAppUpdateVersion.h
//  Beehub
//
//  Created by Grepix - Baij on 06/09/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <GIKit/GIKit.h>
#import "ConstantModel.h"
#import "LanguageHelper.h"

NS_ASSUME_NONNULL_BEGIN
@protocol CheckAppUpdateVersionDelegate<NSObject>

-(void) openAlertViewController:(UIAlertController *) alertViewController;

@end


@interface CheckAppUpdateVersion : NSObject

//@property(weak ,nonatomic) UIViewController * viewController;
//- (instancetype)initWithViewController:(UIViewController *) viewController;
@property(weak,nonatomic)id<CheckAppUpdateVersionDelegate> delegate;
-(void) checkAndShowAlert;
-(void) checkAndShowAlertWith:(ConstantModel *)constantModel;
@end

NS_ASSUME_NONNULL_END
