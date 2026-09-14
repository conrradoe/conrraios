//
//  ConrraButton.h
//  Conrra
//
//  Reusable design-system button. Three variants:
//    ConrraButtonStylePrimary — brand yellow (app_theame), themed text
//    ConrraButtonStyleDark    — #282828 background, white text
//    ConrraButtonStyleGray    — #E8E8E8 background, black text
//
//  USAGE (code):
//    ConrraButton *btn = [ConrraButton buttonWithStyle:ConrraButtonStyleDark];
//
//  USAGE (storyboard outlet, e.g. btLogin):
//    [ConrraButton applyStyle:ConrraButtonStylePrimary toButton:self.btLogin];
//
//  USAGE (storyboard custom class):
//    Set custom class = ConrraButton, then set styleValue IBInspectable (0/1/2).
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ConrraButtonStyle) {
    ConrraButtonStylePrimary = 0,
    ConrraButtonStyleDark    = 1,
    ConrraButtonStyleGray    = 2,
};

@interface ConrraButton : UIButton

/// Current visual style.
@property (nonatomic, assign) ConrraButtonStyle buttonStyle;

/// IBInspectable alias for buttonStyle (0 = Primary, 1 = Dark, 2 = Gray).
/// Set this in Interface Builder when the custom class is ConrraButton.
@property (nonatomic, assign) IBInspectable NSInteger styleValue;

/// Create a fully styled button ready for Auto Layout.
+ (instancetype)buttonWithStyle:(ConrraButtonStyle)style;

/// Apply a style to an existing UIButton — use this for storyboard IBOutlets.
+ (void)applyStyle:(ConrraButtonStyle)style toButton:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
