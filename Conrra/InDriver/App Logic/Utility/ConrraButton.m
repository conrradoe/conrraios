//
//  ConrraButton.m
//  Conrra
//

#import "ConrraButton.h"
#import "WebCallConstants.h"

@implementation ConrraButton

#pragma mark - Factory

+ (instancetype)buttonWithStyle:(ConrraButtonStyle)style {
    ConrraButton *button = [ConrraButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button applyStyle:style];
    return button;
}

#pragma mark - Styling

+ (void)applyStyle:(ConrraButtonStyle)style toButton:(UIButton *)button {
    UIColor *bg;
    UIColor *fg;

    switch (style) {
        case ConrraButtonStylePrimary:
            bg = [UIColor colorNamed:@"app_theame"];
            fg = [UIColor blackColor];
            break;

        case ConrraButtonStyleDark:
            bg = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f]; // #282828
            fg = [UIColor whiteColor];
            break;

        case ConrraButtonStyleGray:
            bg = [UIColor colorWithRed:0.910f green:0.910f blue:0.910f alpha:1.0f]; // #E8E8E8
            fg = [UIColor blackColor];
            break;
    }

    button.backgroundColor = bg;
    [button setTitleColor:fg forState:UIControlStateNormal];
    button.titleLabel.font = FONTS_THEME_BOLD(17);
    button.layer.cornerRadius = 14;
    button.clipsToBounds = YES;
}

- (void)applyStyle:(ConrraButtonStyle)style {
    _buttonStyle = style;
    _styleValue  = (NSInteger)style;
    [ConrraButton applyStyle:style toButton:self];
}

#pragma mark - IBInspectable support

- (void)setStyleValue:(NSInteger)styleValue {
    _styleValue = styleValue;
    [self applyStyle:(ConrraButtonStyle)styleValue];
}

- (void)setButtonStyle:(ConrraButtonStyle)buttonStyle {
    _buttonStyle = buttonStyle;
    _styleValue  = (NSInteger)buttonStyle;
    [ConrraButton applyStyle:buttonStyle toButton:self];
}

#pragma mark - IB / XIB lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    // Re-apply so IB IBInspectable value is honoured at runtime.
    [self applyStyle:(ConrraButtonStyle)_styleValue];
}

@end
