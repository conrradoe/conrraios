//
//  LanguageViewController.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "BecomeDriverVC.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "SettingsModel.h"
#import "UIHelper.h"
#import "Utilities.h"

@interface BecomeDriverVC ()
{
    UIButton *_ndBtnBack;
    UIButton *_ndBtnDriver;
    UITextView *_ndContentView;
}
@end

@implementation BecomeDriverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgMain.hidden       = YES;
    self.txtMeesgae.hidden    = YES;
    self.btnBack.hidden       = YES;
    self.btnApplyForDriver.hidden = YES;
    [self buildNewDesign];
    [self populateContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - New Design

- (void)buildNewDesign {
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scroll];

    UIView *contentContainer = [[UIView alloc] init];
    contentContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:contentContainer];

    _ndContentView = [[UITextView alloc] init];
    _ndContentView.translatesAutoresizingMaskIntoConstraints = NO;
    _ndContentView.editable = NO;
    _ndContentView.scrollEnabled = NO;
    _ndContentView.textContainerInset = UIEdgeInsetsZero;
    _ndContentView.textContainer.lineFragmentPadding = 0;
    _ndContentView.backgroundColor = [UIColor clearColor];
    _ndContentView.font = [UIFont fontWithName:@"NotoSans-Regular" size:17] ?: [UIFont systemFontOfSize:17];
    _ndContentView.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor secondaryLabelColor];
    [contentContainer addSubview:_ndContentView];

    UIView *bottomBar = [[UIView alloc] init];
    bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    bottomBar.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:bottomBar];

    // Thin separator line
    UIView *separator = [[UIView alloc] init];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.08];
    [bottomBar addSubview:separator];

    // Primary button — Modo Conductor / Aplica para Conductor
    _ndBtnDriver = [UIButton buttonWithType:UIButtonTypeSystem];
    _ndBtnDriver.translatesAutoresizingMaskIntoConstraints = NO;
    _ndBtnDriver.backgroundColor = [UIColor colorNamed:@"app_theame"];
    _ndBtnDriver.layer.cornerRadius = 14;
    _ndBtnDriver.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    [_ndBtnDriver setTitleColor:[UIColor colorNamed:@"color_button_text"] ?: [UIColor whiteColor] forState:UIControlStateNormal];
    [_ndBtnDriver addTarget:self action:@selector(onApplyForDriverButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_ndBtnDriver];

    // Secondary button — Volver
    _ndBtnBack = [UIButton buttonWithType:UIButtonTypeSystem];
    _ndBtnBack.translatesAutoresizingMaskIntoConstraints = NO;
    _ndBtnBack.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.0];
    _ndBtnBack.layer.cornerRadius = 14;
    _ndBtnBack.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    [_ndBtnBack setTitleColor:[UIColor colorWithWhite:0.2 alpha:1.0] forState:UIControlStateNormal];
    [_ndBtnBack setTitle:[LanguageHelper getStringWithKey:@"k_9_s4_go_back" defaultValue:@"Volver"] forState:UIControlStateNormal];
    [_ndBtnBack addTarget:self action:@selector(ButtonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_ndBtnBack];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    [NSLayoutConstraint activateConstraints:@[
        // Scroll — top to bottom bar
        [scroll.topAnchor constraintEqualToAnchor:safe.topAnchor constant:16],
        [scroll.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:bottomBar.topAnchor],

        // Content container fills scroll width
        [contentContainer.topAnchor constraintEqualToAnchor:scroll.topAnchor],
        [contentContainer.leadingAnchor constraintEqualToAnchor:scroll.leadingAnchor],
        [contentContainer.trailingAnchor constraintEqualToAnchor:scroll.trailingAnchor],
        [contentContainer.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor],
        [contentContainer.widthAnchor constraintEqualToAnchor:scroll.widthAnchor],

        // Steps text
        [_ndContentView.topAnchor constraintEqualToAnchor:contentContainer.topAnchor],
        [_ndContentView.leadingAnchor constraintEqualToAnchor:contentContainer.leadingAnchor constant:24],
        [_ndContentView.trailingAnchor constraintEqualToAnchor:contentContainer.trailingAnchor constant:-24],
        [_ndContentView.bottomAnchor constraintEqualToAnchor:contentContainer.bottomAnchor constant:-24],

        // Bottom bar — anchored to safe area bottom
        [bottomBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [bottomBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [bottomBar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        // Separator at top of bottom bar
        [separator.topAnchor constraintEqualToAnchor:bottomBar.topAnchor],
        [separator.leadingAnchor constraintEqualToAnchor:bottomBar.leadingAnchor],
        [separator.trailingAnchor constraintEqualToAnchor:bottomBar.trailingAnchor],
        [separator.heightAnchor constraintEqualToConstant:1],

        // Driver button
        [_ndBtnDriver.topAnchor constraintEqualToAnchor:bottomBar.topAnchor constant:16],
        [_ndBtnDriver.leadingAnchor constraintEqualToAnchor:bottomBar.leadingAnchor constant:24],
        [_ndBtnDriver.trailingAnchor constraintEqualToAnchor:bottomBar.trailingAnchor constant:-24],
        [_ndBtnDriver.heightAnchor constraintEqualToConstant:54],

        // Back button
        [_ndBtnBack.topAnchor constraintEqualToAnchor:_ndBtnDriver.bottomAnchor constant:12],
        [_ndBtnBack.leadingAnchor constraintEqualToAnchor:bottomBar.leadingAnchor constant:24],
        [_ndBtnBack.trailingAnchor constraintEqualToAnchor:bottomBar.trailingAnchor constant:-24],
        [_ndBtnBack.heightAnchor constraintEqualToConstant:54],
        [_ndBtnBack.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-16],
    ]];
}

- (void)populateContent {
    NSDictionary *dictUser = defaults_object(P_USER_DICT_LOGGED);
    BOOL is_driver = [[dictUser objectForKey:@"is_driver"] boolValue];

    NSString *driverBtnTitle = is_driver
        ? [LanguageHelper getStringWithKey:@"k_s4_cas_d" defaultValue:@"Continúa como Conductor"]
        : [LanguageHelper getStringWithKey:@"k_s4_apf_d" defaultValue:@"Aplica para Conductor"];
    [_ndBtnDriver setTitle:driverBtnTitle forState:UIControlStateNormal];

    NSString *htmlString = [LanguageHelper getStringWithKey:@"k_9_s4_std_msg" defaultValue:@""];
    // Fix malformed HTML from server: remove duplicate </li> closing tags
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"</li></li>" withString:@"</li>"];
    NSString *styled = [NSString stringWithFormat:
        @"<span style='font-family: \"-apple-system\", \"NotoSans-Regular\"; font-size: 17px; color: #333333;'>%@</span>",
        htmlString];
    NSAttributedString *attrStr = [[NSAttributedString alloc]
        initWithData:[styled dataUsingEncoding:NSUnicodeStringEncoding]
        options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
        documentAttributes:nil
        error:nil];
    if (attrStr.length > 0) {
        _ndContentView.attributedText = attrStr;
    } else {
        _ndContentView.text = [Utilities stringByStrippingHTML:htmlString];
    }
    _ndContentView.textColor = [UIColor colorNamed:@"color_app_label"];
}

#pragma mark - Actions

- (IBAction)ButtonBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onApplyForDriverButtonTap:(id)sender {
    [APP_DELEGATE onDriverSwitchButtonTap:nil];
}

- (void)handleTapOnLabel:(UITapGestureRecognizer *)gesture {
    UITextView *textView = (UITextView *)gesture.view;
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [gesture locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:location
                                                     inTextContainer:textView.textContainer
                                fractionOfDistanceBetweenInsertionPoints:NULL];
    if (characterIndex < textView.textStorage.length) {
        NSRange range;
        NSDictionary *attributes = [textView.textStorage attributesAtIndex:characterIndex effectiveRange:&range];
        NSString *pURL = [NSString stringWithFormat:@"%@", [attributes objectForKey:@"NSLink"]];
        if ([attributes objectForKey:@"NSLink"] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:pURL]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pURL] options:@{} completionHandler:nil];
        }
    }
}

@end
