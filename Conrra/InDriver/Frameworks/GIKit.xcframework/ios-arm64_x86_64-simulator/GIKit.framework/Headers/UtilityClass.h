//
//  UtilityClass.h
//  Frankly_App
//
//  Created by Vinay Jain on 14/02/14.
//  Copyright (c) 2013 Vinay Jain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface UtilityClass : NSObject
+ (void)swa:(NSString *)title
          m:(NSString *)message
cbt:(NSString *)cancelButtonTitle
        obt:(NSString *)otherButtonTitle;

+ (void)swa:(NSString *)title
                 m:(NSString *)message
       cbt:(NSString *)cancelButtonTitle
        obt:(NSString *)otherButtonTitle vc:(UIViewController *)viewController;



+ (void)stwv:(NSString *)text tv:(UIView *)view;
+ (void)stwview:(UIView *)viewtoShow tv:(UIView *)view;
+ (void)stwview:(UIView *)viewtoShow
                   toView:(UIView *)view
             withDuration:(int)duration;
+ (BOOL)validateEmailWithString:(NSString *)strEmail;


- (NSDate *)GetDateFromString:(NSString *)strDate;

+ (void)setLH:(BOOL)isHidden wt:(NSString *)title;
+ (void)setLH:(BOOL)isHidden
              wt:(NSString *)title
         withIntraction:(BOOL)isIntract
               wv:(UIView *)view;

+ (void)SetAllLoadersHidden;

- (void)AddTitleShadowToView:(UIView *)view;

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;


- (UIImage *)captureView:(UIView *)view;
- (UIImage *)comImage:(UIImage *)image;

- (NSData *)compressImageToData:(UIImage *)image;

- (NSData *)compressImageToData:(UIImage *)image withQuality:(float)compressionQuality;

- (NSString *)GetGMTDatetoLocalTZ:(NSString *)strGMTDate;



- (NSDate *)ExtractDateFromStringTimestamp:(NSString *)timeStamp;

- (NSDate *) toLocalTime:(NSDate*)localDate;

- (CGFloat)getSH:(NSString *)strText withWidth:(int)width withFont:(UIFont *)font;

- (NSString *)encodeString:(NSString *)string;
- (NSString *)decodeString:(NSString *)string;


- (NSString *)gLH1:(NSString *)label label2:(NSString *)label2 width:(int)widthR withFont:(UIFont *)font;


+ (CGFloat)gTH:(CGSize)label forText:(NSString*)textString withFont:(UIFont*)font;


+(NSString *)  formatDateWithLocale:(NSString *) stringDate;

+ (void)setCornerRadius:(UIView *)view radius:(int)cornerRadius border:(BOOL)border;
+ (void)setCornerRadius:(UIView *)view radius:(int)cornerRadius borderColor:(UIColor *)borderColor;

@end
