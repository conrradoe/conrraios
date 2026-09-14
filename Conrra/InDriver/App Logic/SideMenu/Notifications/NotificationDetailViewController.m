//
//  NotificationDetailViewController.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 13/06/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "NotificationDetailViewController.h"

@interface NotificationDetailViewController ()<WKNavigationDelegate,WKUIDelegate>

@end

@implementation NotificationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUIFields];
    self.lblHeaderTitle.text=self.notificationModel.title;
    NSString *urlAddress =self.notificationModel.url;
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:requestObj];
    self.webview.UIDelegate=self;
    self.webview.navigationDelegate=self;
  
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self setUIFields];
}
-(void) setUIFields{
    self.lblHeaderTitle.text = [LanguageHelper getStringWithKey:@"k_15_s4_a1_notifications"];
//    [self.btnBack setBackgroundImage:[UIImage imageNamed:@"backward-arrow"] forState:UIControlStateNormal];

    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)ButtonBackPressed:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
  if (!navigationAction.targetFrame.isMainFrame) {
      [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
          
      }];
  }
  return nil;
}

@end
