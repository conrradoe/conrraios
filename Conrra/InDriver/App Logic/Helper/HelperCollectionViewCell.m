//
//  HelperCollectionViewCell.m

//
//  Created by Grepix - Baij on 15/04/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "HelperCollectionViewCell.h"
#import "WebCallConstants.h"

static const CGFloat kContentPadding = 20.0;
static const CGFloat kTitleMaxWidth = 320.0;
static const CGFloat kTitleMaxHeight = 72.0;
// Main: Noto Sans Medium 28pt, line-height 36. Description: Noto Sans Regular 16pt, line-height 24.
// TODO: Add Noto Sans font files (NotoSans-Medium.ttf, NotoSans-Regular.ttf) to the project and register in Info.plist under "Fonts provided by application" for exact design match.
static const CGFloat kTitleFontSize = 28.0;
static const CGFloat kTitleLineHeight = 36.0;
static const CGFloat kBodyFontSize = 16.0;
static const CGFloat kBodyLineHeight = 24.0;

static UIFont *_fontNotoSansMedium(CGFloat size) {
    UIFont *f = [UIFont fontWithName:@"NotoSans-Medium" size:size];
    return f ?: [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
}
static UIFont *_fontNotoSansRegular(CGFloat size) {
    UIFont *f = [UIFont fontWithName:@"NotoSans-Regular" size:size];
    return f ?: [UIFont systemFontOfSize:size weight:UIFontWeightRegular];
}
static NSMutableParagraphStyle *_paragraphStyle(CGFloat lineHeight) {
    NSMutableParagraphStyle *p = [[NSMutableParagraphStyle alloc] init];
    p.minimumLineHeight = lineHeight;
    p.maximumLineHeight = lineHeight;
    p.alignment = NSTextAlignmentCenter;
    return p;
}

@implementation HelperCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupOnboardingUI];
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) [self setupOnboardingUI];
    return self;
}

- (void)setupOnboardingUI {
    _dimOverlay = [[UIView alloc] init];
    _dimOverlay.backgroundColor = [UIColor blackColor];
    _dimOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_dimOverlay];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = _fontNotoSansMedium(kTitleFontSize);
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_titleLabel];

    _bodyLabel = [[UILabel alloc] init];
    _bodyLabel.font = _fontNotoSansRegular(kBodyFontSize);
    _bodyLabel.textColor = [UIColor whiteColor];
    _bodyLabel.numberOfLines = 0;
    _bodyLabel.textAlignment = NSTextAlignmentCenter;
    _bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_bodyLabel];

    [NSLayoutConstraint activateConstraints:@[
        [_dimOverlay.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [_dimOverlay.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [_dimOverlay.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [_dimOverlay.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [_titleLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [_titleLabel.widthAnchor constraintEqualToConstant:kTitleMaxWidth],
        [_titleLabel.heightAnchor constraintLessThanOrEqualToConstant:kTitleMaxHeight],
        [_titleLabel.topAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:kContentPadding],
        [_bodyLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kContentPadding],
        [self.contentView.trailingAnchor constraintEqualToAnchor:_bodyLabel.trailingAnchor constant:kContentPadding],
        [_bodyLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:-8],
        [self.contentView.bottomAnchor constraintEqualToAnchor:_bodyLabel.bottomAnchor constant:200]
    ]];
}

- (void)configureWithTitle:(NSString *)title body:(NSString *)body backgroundImage:(UIImage *)backgroundImage {
    self.titleLabel.text = title;
    self.bodyLabel.text = body;
    NSMutableParagraphStyle *titleStyle = _paragraphStyle(kTitleLineHeight);
    NSMutableParagraphStyle *bodyStyle = _paragraphStyle(kBodyLineHeight);
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title ?: @"" attributes:@{ NSFontAttributeName: _fontNotoSansMedium(kTitleFontSize), NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: titleStyle }];
    self.bodyLabel.attributedText = [[NSAttributedString alloc] initWithString:body ?: @"" attributes:@{ NSFontAttributeName: _fontNotoSansRegular(kBodyFontSize), NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: bodyStyle }];
    // TODO: When adding onboarding images, set image from asset here and hide dimOverlay or use it as dim overlay on top of image. Example: self.imageScreen.image = [UIImage imageNamed:imageName]; self.dimOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    if (backgroundImage) {
        self.imageScreen.image = backgroundImage;
        self.imageScreen.hidden = NO;
        self.dimOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.35];
    } else {
        self.imageScreen.image = nil;
        self.imageScreen.hidden = YES;
        self.dimOverlay.backgroundColor = [UIColor blackColor];
    }
    self.imageScreen.contentMode = UIViewContentModeScaleAspectFill;
    self.imageScreen.clipsToBounds = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (self.imgBackground) [self.imgBackground setHidden:NO];
    self.titleLabel.text = nil;
    self.bodyLabel.text = nil;
    self.imageScreen.image = nil;
}

@end
