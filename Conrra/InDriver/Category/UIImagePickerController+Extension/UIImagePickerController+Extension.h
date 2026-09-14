//
//  UIImagePickerController+Extension.h
//  OD Partner
//
//  Created by Grepix - Baij on 08/10/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImagePickerController (Extension)
+ (void)obtainPermissionForMediaSourceType:(UIImagePickerControllerSourceType)sourceType withSuccessHandler:(void (^) (void))successHandler andFailure:(void (^) (void))failureHandler;
@end

NS_ASSUME_NONNULL_END
