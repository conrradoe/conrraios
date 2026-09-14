//
//  HelperViewController.m

//
//  Created by Grepix - Baij on 15/04/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "HelperViewController.h"
#import "HelperCollectionViewCell.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "LanguageHelper.h"
#import <Conrra-Swift.h>

static const NSInteger kOnboardingStepCount = 4;
static const CGFloat kPageIndicatorActiveWidth = 24.0;
static const CGFloat kPageIndicatorInactiveWidth = 8.0;
static const CGFloat kPageIndicatorHeight = 4.0;
static const CGFloat kPageIndicatorSpacing = 6.0;
static const CGFloat kBottomPadding = 20.0;
static const CGFloat kBottomMargin = 24.0;

@interface HelperViewController ()
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSString *> *> *onboardingSteps;
@property (nonatomic, strong) UIView *customPageIndicatorContainer;
@property (nonatomic, copy) NSArray<UIView *> *customPageIndicatorDots;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *customPageIndicatorWidths;
@property (nonatomic, strong) UIView *bottomButtonContainer;
@property (nonatomic, assign) BOOL didSetupInitialLayout;
@end

@implementation HelperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.onboardingSteps = @[
        @{ @"title": [LanguageHelper getStringWithKey:@"k_s10_onboarding_1_title" defaultValue:@"Elige tu punto de recogida 📍"], @"body": [LanguageHelper getStringWithKey:@"k_s10_onboarding_1_body" defaultValue:@"Indica dónde quieres que te busquemos y te asignamos al conductor más cercano, ya sea en moto o carro."], @"image": @"onboarding_1" },
        @{ @"title": [LanguageHelper getStringWithKey:@"k_s10_onboarding_2_title" defaultValue:@"Viajes rápidos y seguros 🔐"], @"body": [LanguageHelper getStringWithKey:@"k_s10_onboarding_2_body" defaultValue:@"Conductores verificados, precios claros y recorridos en tiempo real para que llegues seguro y sin complicaciones."], @"image": @"onboarding_2" },
        @{ @"title": [LanguageHelper getStringWithKey:@"k_s10_onboarding_3_title" defaultValue:@"Negocia tu tarifa antes de salir 💰"], @"body": [LanguageHelper getStringWithKey:@"k_s10_onboarding_3_body" defaultValue:@"Propón tu precio, recibe ofertas de conductores y elige la opción que mejor se ajuste a tu presupuesto y a tu tiempo."], @"image": @"onboarding_3" },
        @{ @"title": [LanguageHelper getStringWithKey:@"k_s10_onboarding_4_title" defaultValue:@"Moto o Carro, tú decides 🚖"], @"body": [LanguageHelper getStringWithKey:@"k_s10_onboarding_4_body" defaultValue:@"Elige el tipo de vehículo que mejor se adapte a tu tiempo, presupuesto y ruta del día."], @"image": @"onboarding_4" }
    ];

    if (self.btnEmpezar) {
        self.btnEmpezar.backgroundColor = [UIColor colorNamed:@"color_empezar"];
        self.btnEmpezar.hidden = YES;
    }
    if (self.btnNext) {
        self.btnNext.backgroundColor = [UIColor colorNamed:@"color_empezar"];
        self.btnNext.hidden = NO;
        UIImage *arrowImg = [UIImage imageNamed:@"onboarding_arrow"];
        if (arrowImg) {
            [self.btnNext setImage:[arrowImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [self.btnNext setTitle:nil forState:UIControlStateNormal];
            self.btnNext.tintColor = [UIColor blackColor];
        } else if (@available(iOS 13.0, *)) {
            UIImage *chevron = [UIImage systemImageNamed:@"chevron.right"];
            if (chevron) {
                [self.btnNext setImage:[chevron imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [self.btnNext setTitle:nil forState:UIControlStateNormal];
                self.btnNext.tintColor = [UIColor blackColor];
            }
        }
    }
    if (self.logoImageView) self.logoImageView.hidden = YES;
    self.viewPageControl.hidden = YES;

    // Order matters: bottom container must exist before page indicator references it
    [self setupBottomButtonContainer];
    [self setupCustomPageIndicator];
}

- (void)setupBottomButtonContainer {
    // Detach Skip and Next from storyboard superview, place in a shared container
    self.btnSkip.translatesAutoresizingMaskIntoConstraints = NO;
    self.btnNext.translatesAutoresizingMaskIntoConstraints = NO;
    [self.btnSkip removeFromSuperview];
    [self.btnNext removeFromSuperview];

    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:container];
    [container addSubview:self.btnSkip];
    [container addSubview:self.btnNext];
    _bottomButtonContainer = container;

    [NSLayoutConstraint activateConstraints:@[
        // Container: full width, 32pt above safe area bottom
        [container.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [container.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [container.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-32],

        // Arrow button: right side with 20pt padding, drives container height
        [self.btnNext.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-20],
        [self.btnNext.topAnchor constraintEqualToAnchor:container.topAnchor constant:20],
        [self.btnNext.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-20],
        [self.btnNext.widthAnchor constraintEqualToAnchor:self.btnNext.heightAnchor],

        // Saltar button: left side, vertically centered
        [self.btnSkip.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:20],
        [self.btnSkip.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
    ]];

    // Empezar button at the exact same bottom position as the container
    self.btnEmpezar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.btnEmpezar removeFromSuperview];
    [self.view addSubview:self.btnEmpezar];
    [NSLayoutConstraint activateConstraints:@[
        [self.btnEmpezar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.btnEmpezar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.btnEmpezar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-32],
    ]];
}

- (void)setupCustomPageIndicator {
    _customPageIndicatorContainer = [[UIView alloc] init];
    _customPageIndicatorContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_customPageIndicatorContainer];
    NSMutableArray *dots = [NSMutableArray arrayWithCapacity:kOnboardingStepCount];
    UIColor *yellow = [UIColor colorNamed:@"color_empezar"];
    if (!yellow) yellow = [UIColor colorWithRed:0.96 green:0.72 blue:0.0 alpha:1.0];
    for (NSInteger i = 0; i < kOnboardingStepCount; i++) {
        UIView *dot = [[UIView alloc] init];
        dot.translatesAutoresizingMaskIntoConstraints = NO;
        dot.backgroundColor = (i == 0) ? yellow : [UIColor whiteColor];
        dot.layer.cornerRadius = kPageIndicatorHeight / 2.0;
        [_customPageIndicatorContainer addSubview:dot];
        [dots addObject:dot];
    }
    _customPageIndicatorDots = [dots copy];
    [NSLayoutConstraint activateConstraints:@[
        [_customPageIndicatorContainer.centerXAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.centerXAnchor],
        // Anchor page dots 16pt above the bottom button container
        [_customPageIndicatorContainer.bottomAnchor constraintEqualToAnchor:_bottomButtonContainer.topAnchor constant:-16],
    ]];
    [self layoutCustomPageIndicatorDots];
}

- (void)layoutCustomPageIndicatorDots {
    if (_customPageIndicatorDots.count == 0) return;
    UIView *prev = nil;
    NSMutableArray *widths = [NSMutableArray array];
    for (NSInteger i = 0; i < _customPageIndicatorDots.count; i++) {
        UIView *dot = _customPageIndicatorDots[i];
        [NSLayoutConstraint activateConstraints:@[
            [dot.heightAnchor constraintEqualToConstant:kPageIndicatorHeight],
            [dot.centerYAnchor constraintEqualToAnchor:_customPageIndicatorContainer.centerYAnchor]
        ]];
        CGFloat w = (i == 0) ? kPageIndicatorActiveWidth : kPageIndicatorInactiveWidth;
        NSLayoutConstraint *widthC = [dot.widthAnchor constraintEqualToConstant:w];
        [widthC setActive:YES];
        [widths addObject:widthC];
        if (prev) {
            [NSLayoutConstraint activateConstraints:@[
                [dot.leadingAnchor constraintEqualToAnchor:prev.trailingAnchor constant:kPageIndicatorSpacing]
            ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [dot.leadingAnchor constraintEqualToAnchor:_customPageIndicatorContainer.leadingAnchor]
            ]];
        }
        if (i == _customPageIndicatorDots.count - 1) {
            [NSLayoutConstraint activateConstraints:@[
                [_customPageIndicatorContainer.trailingAnchor constraintEqualToAnchor:dot.trailingAnchor]
            ]];
        }
        prev = dot;
    }
    _customPageIndicatorWidths = [widths copy];
}

- (void)updateCustomPageIndicatorForPage:(NSInteger)currentPage {
    UIColor *yellow = [UIColor colorNamed:@"color_empezar"];
    if (!yellow) yellow = [UIColor colorWithRed:0.96 green:0.72 blue:0.0 alpha:1.0];
    for (NSInteger i = 0; i < _customPageIndicatorDots.count; i++) {
        UIView *dot = _customPageIndicatorDots[i];
        dot.backgroundColor = (i == currentPage) ? yellow : [UIColor whiteColor];
    }
    for (NSInteger i = 0; i < _customPageIndicatorWidths.count; i++) {
        NSLayoutConstraint *c = _customPageIndicatorWidths[i];
        c.constant = (i == currentPage) ? kPageIndicatorActiveWidth : kPageIndicatorInactiveWidth;
    }
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Only reload once when the collection view frame is first valid.
    // Reloading on every layout pass was resetting scroll offset, breaking the arrow button.
    if (!self.didSetupInitialLayout && self.collectionView.frame.size.width > 0) {
        self.didSetupInitialLayout = YES;
        [self.collectionView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateButtonsForCurrentPage];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kOnboardingStepCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HelperCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HelperCollectionViewCell" forIndexPath:indexPath];
    NSDictionary *step = self.onboardingSteps[indexPath.row];
    NSString *imageName = step[@"image"];
    UIImage *bgImage = (imageName.length > 0) ? [UIImage imageNamed:imageName] : nil;
    [cell configureWithTitle:step[@"title"] body:step[@"body"] backgroundImage:bgImage];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
}

- (void)goToSignIn {
    UINavigationController *vc = IS_PHONE_VERIFICATION == 1 ? [StoryBoardUtiles navigationPhone] : [StoryBoardUtiles navigationEmail];
    [[APP_DELEGATE window] setRootViewController:vc];
    [[APP_DELEGATE window] makeKeyAndVisible];
    [APP_DELEGATE setNavigationController:vc];
}

- (IBAction)onSkipButtonTap:(id)sender {
    [self goToSignIn];
}

- (IBAction)onEmpezarButtonTap:(id)sender {
    [self goToSignIn];
}

- (IBAction)onNextButtonTap:(id)sender {
    NSInteger currentIndex = (NSInteger)(self.collectionView.contentOffset.x / self.collectionView.frame.size.width + 0.5);
    if (currentIndex >= kOnboardingStepCount - 1) {
        [self goToSignIn];
        return;
    }
    NSIndexPath *next = [NSIndexPath indexPathForItem:(currentIndex + 1) inSection:0];
    [self.collectionView scrollToItemAtIndexPath:next atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)updateButtonsForCurrentPage {
    CGFloat w = self.collectionView.frame.size.width;
    if (w <= 0) return;
    NSInteger currentIndex = (NSInteger)(self.collectionView.contentOffset.x / w + 0.5);
    if (currentIndex < 0) currentIndex = 0;
    if (currentIndex >= kOnboardingStepCount) currentIndex = kOnboardingStepCount - 1;
    self.viewPageControl.currentPage = currentIndex;
    [self updateCustomPageIndicatorForPage:currentIndex];
    BOOL isLastPage = (currentIndex == kOnboardingStepCount - 1);
    self.btnEmpezar.hidden = !isLastPage;
    _bottomButtonContainer.hidden = isLastPage;
    if (!isLastPage) {
        [self.btnSkip setTitle:NSLocalizedString(@"Saltar", nil) forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateButtonsForCurrentPage];
}

@end
