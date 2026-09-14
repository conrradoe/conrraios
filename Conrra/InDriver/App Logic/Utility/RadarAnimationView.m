//
//  RadarAnimationView.m
//  Conrra
//

#import "RadarAnimationView.h"

// Amber color #F5A623
#define kAmberColor [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1.0]

// Ring radii (pt from center)
static const CGFloat kRing0Radius = 80.0;
static const CGFloat kRing1Radius = 150.0;
static const CGFloat kRing2Radius = 230.0;
// Center solid dot radius
static const CGFloat kDotRadius   = 24.0;

// Animation
static const CFTimeInterval kDuration  = 1.8;
static const CFTimeInterval kStagger   = 0.4;

@interface RadarAnimationView ()
@property (nonatomic, strong) CAShapeLayer *dotLayer;
@property (nonatomic, strong) NSArray<CAShapeLayer *> *ringLayers;
@property (nonatomic, assign) BOOL isAnimating;
@end

@implementation RadarAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        [self buildLayers];
    }
    return self;
}

#pragma mark - Build

- (void)buildLayers {
    // Solid center dot
    self.dotLayer = [self circleLayerWithRadius:kDotRadius color:kAmberColor opacity:1.0];
    [self.layer addSublayer:self.dotLayer];

    // 3 rings with decreasing initial opacity
    CGFloat opacities[] = {0.5, 0.35, 0.2};
    CGFloat radii[]     = {kRing0Radius, kRing1Radius, kRing2Radius};
    NSMutableArray *rings = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        CAShapeLayer *ring = [self circleLayerWithRadius:radii[i]
                                                   color:kAmberColor
                                                 opacity:opacities[i]];
        [self.layer addSublayer:ring];
        [rings addObject:ring];
    }
    self.ringLayers = [rings copy];
}

- (CAShapeLayer *)circleLayerWithRadius:(CGFloat)radius
                                  color:(UIColor *)color
                                opacity:(CGFloat)opacity {
    CAShapeLayer *layer = [CAShapeLayer layer];
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0,
                                 self.bounds.size.height / 2.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                        radius:radius
                                                    startAngle:0
                                                      endAngle:M_PI * 2
                                                     clockwise:YES];
    layer.path        = path.CGPath;
    layer.fillColor   = color.CGColor;
    layer.strokeColor = [UIColor clearColor].CGColor;
    layer.opacity     = opacity;
    layer.position    = center;
    return layer;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0,
                                 self.bounds.size.height / 2.0);
    self.dotLayer.position = center;
    for (CAShapeLayer *ring in self.ringLayers) {
        ring.position = center;
    }
}

#pragma mark - Public

- (void)startAnimating {
    if (self.isAnimating) return;
    self.isAnimating = YES;
    self.hidden = NO;

    CGFloat radii[]    = {kRing0Radius, kRing1Radius, kRing2Radius};
    CGFloat opacities[] = {0.5, 0.35, 0.2};

    for (int i = 0; i < 3; i++) {
        CAShapeLayer *ring = self.ringLayers[i];

        // Opacity animation: opacities[i] → 0
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue    = @(opacities[i]);
        opacityAnim.toValue      = @0.0;
        opacityAnim.duration     = kDuration;
        opacityAnim.beginTime    = CACurrentMediaTime() + i * kStagger;
        opacityAnim.repeatCount  = HUGE_VALF;
        opacityAnim.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        opacityAnim.fillMode = kCAFillModeBackwards;

        // Scale animation: 0.3 → 1.0 (rings grow outward)
        CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnim.fromValue   = @0.3;
        scaleAnim.toValue     = @1.0;
        scaleAnim.duration    = kDuration;
        scaleAnim.beginTime   = CACurrentMediaTime() + i * kStagger;
        scaleAnim.repeatCount = HUGE_VALF;
        scaleAnim.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        scaleAnim.fillMode = kCAFillModeBackwards;

        [ring addAnimation:opacityAnim forKey:[NSString stringWithFormat:@"opacity_%d", i]];
        [ring addAnimation:scaleAnim   forKey:[NSString stringWithFormat:@"scale_%d", i]];
        (void)radii[i]; // suppress unused warning
    }
}

- (void)stopAnimating {
    if (!self.isAnimating) return;
    self.isAnimating = NO;
    for (CAShapeLayer *ring in self.ringLayers) {
        [ring removeAllAnimations];
    }
    self.hidden = YES;
}

@end
