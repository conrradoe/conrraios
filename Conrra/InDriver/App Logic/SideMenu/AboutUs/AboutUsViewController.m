//
//  AboutUsViewController.m

//
//  Created by Grepix - Baij on 10/04/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "AboutUsViewController.h"
#import "WebCallConstants.h"
#import "SettingsModel.h"
@interface AboutUsViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbHeaderTitle;


@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNewDesign];
    NSString *urlString=@"";
    NSArray * arr = defaults_object(@"settingResponse");
    SettingsModel *settingsModel =[[SettingsModel alloc]initItemWithDict:arr];
    if(self.isAboutUs)
    {
      
        urlString= isEmpty(settingsModel.aboutUsUrl);
        //         @"https://www.grepixit.com/taxi-booking-app-development-company-like-uber.html";
    }else{
        
        urlString= isEmpty(settingsModel.privacyUrl);
        //         urlString = @"https://www.grepixit.com/privacy-policy.html";
    }
    if(self.isFormSignUp)
    {
        urlString = isEmpty(settingsModel.tnc);
    }else if(self.isFarePolicy)
    {
        urlString = isEmpty(settingsModel.fare_policy_url);
    }else if(_isCustomUrl)
    {
        self.lbHeaderTitle.text=[LanguageHelper getStringWithKey:self.customTitle];
         urlString= isEmpty(self.customUrl);
    }
    [self setUIFields];
    //2
    NSURL *url = [NSURL URLWithString:urlString];
    self.webView.UIDelegate=self;
    self.webView.navigationDelegate=self;
    
    //3
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.activityLoader  setHidden:NO];
       [self.activityLoader startAnimating];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self setUIFields];
}
#pragma mark - New Design

- (void)setupNewDesign {
    self.headerView.hidden = YES;

    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    // New programmatic header covering status bar + nav bar area
    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:header];

    // Gray circular back button with chevron.left
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    backBtn.layer.cornerRadius = 20;
    backBtn.tintColor = textMain;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightMedium];
        [backBtn setImage:[[UIImage systemImageNamed:@"chevron.left" withConfiguration:cfg]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    } else {
        [backBtn setTitle:@"‹" forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:26];
    }
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:backBtn];

    // Title label — reassign IBOutlet so setUIFields keeps working
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = textMain;
    [header addSubview:titleLbl];
    self.lbHeaderTitle = titleLbl;

    // Bottom separator
    UIView *sep = [[UIView alloc] init];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    sep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [header addSubview:sep];

    [NSLayoutConstraint activateConstraints:@[
        // Header spans from view top down to safe.top + 44 (matches storyboard headerView bottom)
        [header.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.bottomAnchor constraintEqualToAnchor:safe.topAnchor constant:44],
        // Back button sits in the 44pt nav-bar portion, 8pt from bottom
        [backBtn.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [backBtn.bottomAnchor constraintEqualToAnchor:header.bottomAnchor constant:-8],
        [backBtn.widthAnchor constraintEqualToConstant:40],
        [backBtn.heightAnchor constraintEqualToConstant:40],
        // Title centered horizontally, aligned with back button vertically
        [titleLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLbl.centerYAnchor constraintEqualToAnchor:backBtn.centerYAnchor],
        // Separator
        [sep.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [sep.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [sep.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [sep.heightAnchor constraintEqualToConstant:1],
    ]];

    [self setUIFields];
}

-(void) setUIFields{
  
    if(self.isAboutUs)
    {
        self.lbHeaderTitle.text=[LanguageHelper getStringWithKey:@"k_r1_s3_about_us"];
        
        //         @"https://www.grepixit.com/taxi-booking-app-development-company-like-uber.html";
    }else{
        self.lbHeaderTitle.text=[LanguageHelper getStringWithKey:@"k_2_s4_privacy"];
        //         urlString = @"https://www.grepixit.com/privacy-policy.html";
    }
     if(self.isFarePolicy)
    {
        
        self.lbHeaderTitle.text=[LanguageHelper getStringWithKey:@"k_s3_show_fare_policy"];
 
    }
     else if(_isCustomUrl)
    {
        self.lbHeaderTitle.text=[LanguageHelper getStringWithKey:self.customTitle];
    }
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)back:(id)sender {
     if(self.isFormSignUp)
     {
         [self dismissViewControllerAnimated:YES completion:^{
             
         }];
         return;
     }
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
   [self.activityLoader  setHidden:YES];
    [self.activityLoader stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self.activityLoader  setHidden:YES];
       [self.activityLoader stopAnimating];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
  if (!navigationAction.targetFrame.isMainFrame) {
      [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:^(BOOL success) {
          
      }];
  }
  return nil;
}
@end
