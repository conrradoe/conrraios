//
//  UserPinAnnotationView.m
//  Conrra
//

#import "UserPinAnnotationView.h"

// Body square side
static const CGFloat kBodySize   = 64.0;
// Tail height below the body
static const CGFloat kTailHeight = 18.0;
// Total view height
static const CGFloat kViewHeight = kBodySize + kTailHeight;
// Avatar diameter inside the body
static const CGFloat kAvatarSize = 44.0;
// White ring width around avatar
static const CGFloat kRingWidth  = 3.0;
// Squircle corner radius (≈ 0.28 × size → iOS-style squircle feel)
static const CGFloat kCornerRadius = 18.0;
// Brand yellow
#define kYellowColor [UIColor colorWithRed:245/255.0 green:197/255.0 blue:24/255.0 alpha:1.0]

@interface UserPinAnnotationView ()
@property (nonatomic, strong) UIView       *bodyView;
@property (nonatomic, strong) UIView       *ringView;
@property (nonatomic, strong) UIImageView  *avatarView;
@property (nonatomic, strong) CAShapeLayer *tailLayer;
@end

@implementation UserPinAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
                   reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, kBodySize, kViewHeight);
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = CGPointMake(0.5, 1.0); // anchor at tail tip

        [self buildBody];
        [self buildTail];
        [self buildAvatar];
        [self setAvatarImage:nil]; // default icon
    }
    return self;
}

#pragma mark - Build sub-views

- (void)buildBody {
    self.bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kBodySize, kBodySize)];
    self.bodyView.backgroundColor = kYellowColor;
    self.bodyView.layer.cornerRadius = kCornerRadius;
    if (@available(iOS 13.0, *)) {
        self.bodyView.layer.cornerCurve = kCACornerCurveContinuous;
    }
    // Drop shadow on body
    self.bodyView.layer.shadowColor  = [UIColor blackColor].CGColor;
    self.bodyView.layer.shadowOpacity = 0.18f;
    self.bodyView.layer.shadowRadius  = 12.0f;
    self.bodyView.layer.shadowOffset  = CGSizeMake(0, 6);
    self.bodyView.layer.masksToBounds = NO;
    [self addSubview:self.bodyView];
}

- (void)buildTail {
    // Triangle: base centered at bottom of body, tip pointing down
    CGFloat cx = kBodySize / 2.0;
    CGFloat baseY = kBodySize;
    CGFloat tipY  = kViewHeight;
    CGFloat halfBase = 9.0;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(cx - halfBase, baseY)];
    [path addLineToPoint:CGPointMake(cx + halfBase, baseY)];
    [path addLineToPoint:CGPointMake(cx, tipY)];
    [path closePath];

    self.tailLayer = [CAShapeLayer layer];
    self.tailLayer.path = path.CGPath;
    self.tailLayer.fillColor = kYellowColor.CGColor;
    // Tail shadow matching body
    self.tailLayer.shadowColor   = [UIColor blackColor].CGColor;
    self.tailLayer.shadowOpacity = 0.12f;
    self.tailLayer.shadowRadius  = 6.0f;
    self.tailLayer.shadowOffset  = CGSizeMake(0, 4);
    [self.layer addSublayer:self.tailLayer];
}

- (void)buildAvatar {
    // White ring view
    CGFloat ringSize = kAvatarSize + kRingWidth * 2;
    CGFloat ringX = (kBodySize - ringSize) / 2.0;
    CGFloat ringY = (kBodySize - ringSize) / 2.0;
    self.ringView = [[UIView alloc] initWithFrame:CGRectMake(ringX, ringY, ringSize, ringSize)];
    self.ringView.backgroundColor = [UIColor whiteColor];
    self.ringView.layer.cornerRadius = ringSize / 2.0;
    self.ringView.layer.masksToBounds = YES;
    [self.bodyView addSubview:self.ringView];

    // Avatar image view
    CGFloat avX = kRingWidth;
    CGFloat avY = kRingWidth;
    self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(avX, avY, kAvatarSize, kAvatarSize)];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.layer.cornerRadius = kAvatarSize / 2.0;
    self.avatarView.layer.masksToBounds = YES;
    [self.ringView addSubview:self.avatarView];
}

#pragma mark - Public

- (void)setAvatarImage:(UIImage *)image {
    if (image) {
        self.avatarView.image = image;
        self.avatarView.backgroundColor = [UIColor clearColor];
    } else {
        // SF Symbol fallback (iOS 13+), plain gray circle on older
        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration
                configurationWithPointSize:26 weight:UIImageSymbolWeightMedium];
            self.avatarView.image = [UIImage systemImageNamed:@"person.fill"
                                          withConfiguration:cfg];
            self.avatarView.tintColor = [UIColor whiteColor];
            self.avatarView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
        } else {
            self.avatarView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        }
    }
}

@end
