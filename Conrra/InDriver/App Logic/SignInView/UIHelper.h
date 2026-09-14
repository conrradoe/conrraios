//
//  UIHelper.h

//
//  Created by Grepix - Baij on 25/08/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIHelper : NSObject
+(NSAttributedString *) formatForgotPassword;
+(NSString *) appNameForDisplay;

+ (UIImage *)imageForMapWithImage:(UIImage *)image;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;

+(void) setPlaceHolder:(UITextField *) textField;
+(void) setPlaceHolder:(UITextField *) textField color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
