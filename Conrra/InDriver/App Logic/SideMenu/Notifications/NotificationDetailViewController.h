//
//  NotificationDetailViewController.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 13/06/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationModel.h"
#import <WebKit/WebKit.h>
#import "LanguageHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property(strong,nonatomic) NotificationModel * notificationModel;
@property (weak, nonatomic) IBOutlet UIImageView *imgMain;

@property (weak, nonatomic) IBOutlet WKWebView *webview;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *headerMainView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;

@end

NS_ASSUME_NONNULL_END
