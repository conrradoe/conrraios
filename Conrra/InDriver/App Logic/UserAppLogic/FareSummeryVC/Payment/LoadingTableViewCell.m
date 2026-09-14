//
//  ConrraLoadingOverlay.m
//  Conrra
//

#import "LoadingTableViewCell.h"
#import <GIKit/GIKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation LoadingTableViewCell
- (void)awakeFromNib { [super awakeFromNib]; }
@end

static ConrraLoadingOverlay *_sharedOverlay = nil;

@implementation ConrraLoadingOverlay {
    CAShapeLayer *_ring;
}

+ (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_sharedOverlay) return;

        // Find key window
        UIWindow *win = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    win = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!win) win = UIApplication.sharedApplication.keyWindow;
        if (!win) return;

        _sharedOverlay = [[ConrraLoadingOverlay alloc] initWithFrame:win.bounds];
        _sharedOverlay.alpha = 0;
        [win addSubview:_sharedOverlay];

        [UIView animateWithDuration:0.18 animations:^{
            _sharedOverlay.alpha = 1;
        }];
    });
}

+ (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        ConrraLoadingOverlay *overlay = _sharedOverlay;
        _sharedOverlay = nil;
        [UIView animateWithDuration:0.18 animations:^{
            overlay.alpha = 0;
        } completion:^(BOOL finished) {
            [overlay removeFromSuperview];
        }];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    // Semi-transparent dark background
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35f];

    // White card
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 20;
    card.layer.shadowColor  = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.12f;
    card.layer.shadowRadius  = 12;
    card.layer.shadowOffset  = CGSizeMake(0, 4);
    card.center = self.center;
    [self addSubview:card];

    // Spinning ring using CAShapeLayer
    CGFloat ringSize = 52;
    CGFloat ringX = (90 - ringSize) / 2.0;
    CGFloat ringY = (90 - ringSize) / 2.0;

    // Track ring (light gray)
    CAShapeLayer *track = [CAShapeLayer layer];
    track.frame = CGRectMake(ringX, ringY, ringSize, ringSize);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ringSize, ringSize)];
    track.path = circlePath.CGPath;
    track.strokeColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.0f].CGColor;
    track.fillColor   = UIColor.clearColor.CGColor;
    track.lineWidth   = 5.0;
    [card.layer addSublayer:track];

    // Spinning arc (yellow, 270° visible)
    _ring = [CAShapeLayer layer];
    _ring.frame = CGRectMake(ringX, ringY, ringSize, ringSize);
    _ring.path  = circlePath.CGPath;

    UIColor *accentColor = [UIColor colorNamed:@"app_theame"];
    if (!accentColor) accentColor = [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    _ring.strokeColor = accentColor.CGColor;
    _ring.fillColor   = UIColor.clearColor.CGColor;
    _ring.lineWidth   = 5.0;
    _ring.lineCap     = kCALineCapRound;
    _ring.strokeStart = 0.0;
    _ring.strokeEnd   = 0.72; // ~260° arc
    [card.layer addSublayer:_ring];

    // Rotation animation
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    spin.toValue      = @(2 * M_PI);
    spin.duration     = 0.85;
    spin.repeatCount  = INFINITY;
    spin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_ring addAnimation:spin forKey:@"spin"];
}

@end

#import <objc/runtime.h>

@implementation UtilityClass (ConrraLoading)

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        SEL origSel  = @selector(setLH:wt:);
        SEL newSel   = @selector(conrra_setLH:wt:);
        Method orig  = class_getClassMethod([UtilityClass class], origSel);
        Method swiz  = class_getClassMethod([UtilityClass class], newSel);
        if (orig && swiz) method_exchangeImplementations(orig, swiz);

        SEL origSel2 = @selector(setLH:);
        SEL newSel2  = @selector(conrra_setLH:);
        Method orig2 = class_getClassMethod([UtilityClass class], origSel2);
        Method swiz2 = class_getClassMethod([UtilityClass class], newSel2);
        if (orig2 && swiz2) method_exchangeImplementations(orig2, swiz2);
    });
}

+ (void)conrra_setLH:(BOOL)isHidden wt:(NSString *)title {
    if (isHidden) [ConrraLoadingOverlay hide];
    else          [ConrraLoadingOverlay show];
}

+ (void)conrra_setLH:(BOOL)isHidden {
    if (isHidden) [ConrraLoadingOverlay hide];
    else          [ConrraLoadingOverlay show];
}

@end
