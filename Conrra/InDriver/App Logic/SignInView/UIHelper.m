//
//  UIHelper.m

//
//  Created by Grepix - Baij on 25/08/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "UIHelper.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import <objc/runtime.h>
@implementation UIHelper

+(NSAttributedString *) formatForgotPassword{
   NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
       [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_5_s1_forgot_password"]
                                                                                attributes:@{
                                                                                    NSFontAttributeName:FONTS_THEME_REGULAR(16),NSForegroundColorAttributeName:[UIColor colorNamed:@"app_theame"],
                                                                                    NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}]];
    return attributedString;
}


+(NSString *) appNameForDisplay{
     return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (UIImage *)imageForMapWithImage:(UIImage *)image
{
    if (!image) return image;
    CGSize canvas = CGSizeMake(44, 44);
    // Scale-to-fit (MIN) so the whole icon is visible — no cropping
    CGFloat scale  = MIN(canvas.width / image.size.width, canvas.height / image.size.height);
    CGFloat width  = image.size.width  * scale;
    CGFloat height = image.size.height * scale;
    CGRect  rect   = CGRectMake((canvas.width  - width)  / 2.0,
                                (canvas.height - height) / 2.0,
                                width, height);
    UIGraphicsBeginImageContextWithOptions(canvas, NO, 0);
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+(void) setPlaceHolder:(UITextField *) textField {
    [self setPlaceHolder:textField color:[UIColor colorNamed:@"color_placeholder"]];
}


+(void) setPlaceHolder:(UITextField *) textField color:(UIColor *)color  {
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(textField, ivar);
    placeholderLabel.textColor =color;
}


@end
