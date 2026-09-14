//
//  ImageDoc.h

//
//  Created by Grepix - Baij on 07/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CustomUIButton.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImageDoc : UIView
@property(strong,nonatomic) UIImageView * imageView;
@property(strong, nonatomic)UIActivityIndicatorView * activityLoader;
@property(strong, nonatomic) CustomUIButton * button;
@property(strong, nonatomic) UILabel *label;
@property(assign, nonatomic) BOOL isImageSelect;
@property(assign, nonatomic) BOOL isImageSelectChanged;
@property(strong, nonatomic) NSDictionary * dictAssets;
- (instancetype)initWithFrame:(CGRect )frame view:(UIView *) view;
@end

NS_ASSUME_NONNULL_END
