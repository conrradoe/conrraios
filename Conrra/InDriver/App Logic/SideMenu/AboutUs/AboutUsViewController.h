//
//  AboutUsViewController.h

//
//  Created by Grepix - Baij on 10/04/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "LanguageHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface AboutUsViewController : UIViewController
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property(assign,nonatomic)BOOL isAboutUs;
@property(assign,nonatomic)BOOL isFormSignUp;

@property(assign,nonatomic)BOOL isFarePolicy;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoader;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property(assign,nonatomic)BOOL isCustomUrl;
@property(strong,nonatomic)NSString * customUrl;
@property(strong,nonatomic)NSString * customTitle;

@end

NS_ASSUME_NONNULL_END
