//
//  UFareOfferViewController.m
//  Conrra
//
//  Screen 3 — "Tarifa recomendada"
//  Fully programmatic. Transparent full-screen background so Screen 1's live map
//  (with drawn route, pins, and radar) shows through the top portion.
//

#import "UFareOfferViewController.h"
#import "LanguageHelper.h"

static const CGFloat kRowH          = 76.0f; // height of each config toggle row
static const CGFloat kConfigContentH = 231.0f; // 1(top-sep) + 3×76 + 2×1(seps)

/// Full-screen root view that passes touch events through the transparent map area.
@interface UFareRootView : UIView
@property (assign, nonatomic) CGFloat sheetStartY;
@end
@implementation UFareRootView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y < self.sheetStartY) return nil;
    return [super hitTest:point withEvent:event];
}
@end

@interface UFareOfferViewController ()
{
    float _currentAmount;
    BOOL  _configExpanded;
    BOOL  _didBuildLayout;
}

// Fare stepper
@property (strong, nonatomic) UILabel     *amountLabel;
// Payment row
@property (strong, nonatomic) UILabel     *paymentRowLabel;
@property (strong, nonatomic) UIImageView *paymentIconView;
// Scroll infrastructure
@property (strong, nonatomic) UIScrollView *sheetScroll;
@property (strong, nonatomic) UIView       *contentCV;
// Accordion
@property (strong, nonatomic) UIView       *configContainer;
@property (strong, nonatomic) UIView       *configContentView;
@property (strong, nonatomic) UIImageView  *configChevron;
// Sheet panels (kept for expand/collapse animation)
@property (strong, nonatomic) UIView       *sheetPanel;
@property (strong, nonatomic) UIView       *shadowPanel;
// Views below accordion that must shift on expand/collapse
@property (strong, nonatomic) UIView       *payRow;
@property (strong, nonatomic) UIButton     *pedirBtn;
// Config toggle switches
@property (strong, nonatomic) UISwitch     *switchPassengers;
@property (strong, nonatomic) UISwitch     *switchPets;
@property (strong, nonatomic) UISwitch     *switchDelivery;

@end

@implementation UFareOfferViewController

@synthesize currentAmount = _currentAmount;

#pragma mark - Config toggle accessors

- (BOOL)configExtraPassengers { return self.switchPassengers.isOn; }
- (BOOL)configPetsAllowed     { return self.switchPets.isOn; }
- (BOOL)configIsDelivery      { return self.switchDelivery.isOn; }

#pragma mark - Lifecycle

- (void)loadView {
    UFareRootView *root = [[UFareRootView alloc] init];
    root.backgroundColor = [UIColor clearColor];
    self.view = root;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentAmount = (self.recommendedFare > 0) ? self.recommendedFare : 0.0f;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!_didBuildLayout && self.view.bounds.size.width > 0) {
        _didBuildLayout = YES;
        [self buildLayout];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Layout

- (void)buildLayout {
    CGFloat sw = self.view.bounds.size.width;
    CGFloat sh = self.view.bounds.size.height;

    CGFloat sheetStartY = sh * 0.42;
    ((UFareRootView *)self.view).sheetStartY = sheetStartY;
    CGFloat sheetH = sh - sheetStartY;

    // Shared colors
    UIColor *darkText   = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    UIColor *grayText   = [UIColor colorWithRed:0.5f   green:0.5f   blue:0.5f   alpha:1.0f];
    UIColor *lightGray  = [UIColor colorWithRed:0.918f green:0.918f blue:0.918f alpha:1.0f];
    UIColor *borderClr  = [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f];

    // Shadow carrier (behind sheet, not clipped)
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, sheetStartY, sw, sheetH)];
    shadowView.backgroundColor    = [UIColor whiteColor];
    shadowView.layer.cornerRadius = 20;
    shadowView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    shadowView.layer.shadowColor   = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOpacity = 0.10f;
    shadowView.layer.shadowRadius  = 14.0f;
    shadowView.layer.shadowOffset  = CGSizeMake(0, -3);
    [self.view addSubview:shadowView];
    self.shadowPanel = shadowView;

    // Sheet (clips rounded corners)
    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, sheetStartY, sw, sheetH)];
    sheet.backgroundColor     = [UIColor whiteColor];
    sheet.layer.cornerRadius  = 20;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.clipsToBounds       = YES;
    [self.view addSubview:sheet];
    self.sheetPanel = sheet;

    // Scroll view fills the sheet so accordion can overflow
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:sheet.bounds];
    scroll.showsVerticalScrollIndicator = NO;
    scroll.alwaysBounceVertical         = NO;
    [sheet addSubview:scroll];
    self.sheetScroll = scroll;

    // Content view inside scroll
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 0)];
    [scroll addSubview:cv];
    self.contentCV = cv;

    CGFloat y = 10.0;

    UIView *handle = [[UIView alloc] initWithFrame:CGRectMake((sw - 36) / 2.0, y, 36, 4)];
    handle.backgroundColor    = borderClr;
    handle.layer.cornerRadius = 2;
    [cv addSubview:handle];
    y += 4 + 16;

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame              = CGRectMake(16, y, 44, 44);
    backBtn.backgroundColor    = lightGray;
    backBtn.layer.cornerRadius = 22;
    backBtn.clipsToBounds      = YES;
    UIImage *chevronLeft = [[UIImage systemImageNamed:@"chevron.left"]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backBtn setImage:chevronLeft forState:UIControlStateNormal];
    backBtn.tintColor = darkText;
    [backBtn addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text      = @"Tarifa recomendada";
    titleLbl.font      = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    titleLbl.textColor = darkText;
    [titleLbl sizeToFit];
    titleLbl.frame = CGRectMake((sw - titleLbl.frame.size.width) / 2.0,
                                 y + (44 - titleLbl.frame.size.height) / 2.0,
                                 titleLbl.frame.size.width,
                                 titleLbl.frame.size.height);
    [cv addSubview:titleLbl];
    y += 44 + 20;

    CGFloat cardW = sw - 32;
    UIView *fareCard = [[UIView alloc] initWithFrame:CGRectMake(16, y, cardW, 80)];
    fareCard.backgroundColor    = [UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.0f];
    fareCard.layer.cornerRadius = 16;
    fareCard.clipsToBounds      = YES;
    [cv addSubview:fareCard];

    UIButton *minusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    minusBtn.frame              = CGRectMake(12, 18, 44, 44);
    minusBtn.backgroundColor    = [UIColor whiteColor];
    minusBtn.layer.cornerRadius = 22;
    minusBtn.clipsToBounds      = YES;
    [minusBtn setTitle:@"−" forState:UIControlStateNormal];
    [minusBtn setTitleColor:darkText forState:UIControlStateNormal];
    minusBtn.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    [minusBtn addTarget:self action:@selector(minusTapped) forControlEvents:UIControlEventTouchUpInside];
    [fareCard addSubview:minusBtn];

    self.amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, cardW - 128, 80)];
    self.amountLabel.text          = [self formattedAmount:_currentAmount];
    self.amountLabel.font          = [UIFont fontWithName:@"NotoSans-Bold" size:26] ?: [UIFont boldSystemFontOfSize:26];
    self.amountLabel.textColor     = darkText;
    self.amountLabel.textAlignment = NSTextAlignmentCenter;
    self.amountLabel.adjustsFontSizeToFitWidth = YES;
    [fareCard addSubview:self.amountLabel];

    UIButton *plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    plusBtn.frame              = CGRectMake(cardW - 56, 18, 44, 44);
    plusBtn.backgroundColor    = [UIColor whiteColor];
    plusBtn.layer.cornerRadius = 22;
    plusBtn.clipsToBounds      = YES;
    [plusBtn setTitle:@"+" forState:UIControlStateNormal];
    [plusBtn setTitleColor:darkText forState:UIControlStateNormal];
    plusBtn.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    [plusBtn addTarget:self action:@selector(plusTapped) forControlEvents:UIControlEventTouchUpInside];
    [fareCard addSubview:plusBtn];

    y += 80 + 10;

    CGFloat halfW = (sw - 32) / 2.0;
    [self addHintIconName:@"dollarsign.circle" text:[LanguageHelper getStringWithKey:@"k_s10_recommended_price" defaultValue:@"Precio recomendado"]
                   inView:cv x:16 y:y width:halfW];
    [self addHintIconName:@"arrow.triangle.2.circlepath" text:[LanguageHelper getStringWithKey:@"k_s10_conversion_usd" defaultValue:@"Conversión a USD"]
                   inView:cv x:16 + halfW y:y width:halfW];
    y += 28 + 14;

    UIView *configContainer = [[UIView alloc] initWithFrame:CGRectMake(16, y, sw - 32, 52)];
    configContainer.layer.borderWidth  = 1.0f;
    configContainer.layer.borderColor  = borderClr.CGColor;
    configContainer.layer.cornerRadius = 12;
    configContainer.clipsToBounds      = YES;
    [cv addSubview:configContainer];
    self.configContainer = configContainer;

    // Header inside container
    UILabel *configLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, sw - 32 - 52, 52)];
    configLbl.text      = [LanguageHelper getStringWithKey:@"k_s10_settings" defaultValue:@"Configuración"];
    configLbl.font      = [UIFont fontWithName:@"NotoSans-Regular" size:16] ?: [UIFont systemFontOfSize:16];
    configLbl.textColor = darkText;
    [configContainer addSubview:configLbl];

    UIImageView *chevron = [[UIImageView alloc] initWithFrame:CGRectMake(sw - 32 - 36, 15, 22, 22)];
    chevron.image       = [[UIImage systemImageNamed:@"chevron.down"]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    chevron.tintColor   = grayText;
    chevron.contentMode = UIViewContentModeScaleAspectFit;
    [configContainer addSubview:chevron];
    self.configChevron = chevron;

    // Tap overlay
    UIButton *configTap = [UIButton buttonWithType:UIButtonTypeCustom];
    configTap.frame           = CGRectMake(0, 0, sw - 32, 52);
    configTap.backgroundColor = [UIColor clearColor];
    [configTap addTarget:self action:@selector(configTapped) forControlEvents:UIControlEventTouchUpInside];
    [configContainer addSubview:configTap];

    // Expandable content area (starts at height 0, clipped)
    UIView *configContent = [[UIView alloc] initWithFrame:CGRectMake(0, 52, sw - 32, 0)];
    configContent.clipsToBounds = YES;
    [configContainer addSubview:configContent];
    self.configContentView = configContent;

    // Pre-build toggle rows inside the content area
    [self buildConfigContent:configContent width:sw - 32
                    darkText:darkText grayText:grayText borderColor:borderClr];

    y += 52 + 12;

    UIView *payRow = [[UIView alloc] initWithFrame:CGRectMake(16, y, sw - 32, 60)];
    payRow.layer.borderWidth  = 1.0f;
    payRow.layer.borderColor  = borderClr.CGColor;
    payRow.layer.cornerRadius = 12;
    payRow.clipsToBounds      = YES;
    [cv addSubview:payRow];
    self.payRow = payRow;

    self.paymentIconView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 18, 24, 24)];
    UIImage *payImg = self.paymentIcon
                      ?: [[UIImage systemImageNamed:@"banknote.fill"]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.paymentIconView.image       = [payImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.paymentIconView.tintColor   = [UIColor colorWithRed:0.18f green:0.65f blue:0.32f alpha:1.0f];
    self.paymentIconView.contentMode = UIViewContentModeScaleAspectFit;
    [payRow addSubview:self.paymentIconView];

    self.paymentRowLabel = [[UILabel alloc] initWithFrame:CGRectMake(52, 0, sw - 32 - 52 - 96, 60)];
    self.paymentRowLabel.text      = [NSString stringWithFormat:[LanguageHelper getStringWithKey:@"k_s10_pay_with_format" defaultValue:@"Paga con %@"],
                                       self.paymentLabel.length > 0 ? self.paymentLabel : [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Efectivo"]];
    self.paymentRowLabel.font      = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    self.paymentRowLabel.textColor = darkText;
    [payRow addSubview:self.paymentRowLabel];

    UIView *badge = [[UIView alloc] initWithFrame:CGRectMake(sw - 32 - 86, 18, 66, 24)];
    badge.backgroundColor    = lightGray;
    badge.layer.cornerRadius = 5;
    badge.clipsToBounds      = YES;
    UILabel *badgeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 66, 24)];
    badgeLbl.text          = [LanguageHelper getStringWithKey:@"k_s10_default" defaultValue:@"Default"];
    badgeLbl.font          = [UIFont systemFontOfSize:11];
    badgeLbl.textColor     = [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f];
    badgeLbl.textAlignment = NSTextAlignmentCenter;
    [badge addSubview:badgeLbl];
    [payRow addSubview:badge];

    UIImageView *payChevron = [[UIImageView alloc] initWithFrame:CGRectMake(sw - 32 - 18, 18, 12, 22)];
    payChevron.image       = [[UIImage systemImageNamed:@"chevron.right"]
                               imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    payChevron.tintColor   = grayText;
    payChevron.contentMode = UIViewContentModeScaleAspectFit;
    [payRow addSubview:payChevron];

    UIButton *payTap = [UIButton buttonWithType:UIButtonTypeCustom];
    payTap.frame           = CGRectMake(0, 0, sw - 32, 60);
    payTap.backgroundColor = [UIColor clearColor];
    [payTap addTarget:self action:@selector(paymentTapped) forControlEvents:UIControlEventTouchUpInside];
    [payRow addSubview:payTap];

    y += 60 + 16;

    UIButton *pedirBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pedirBtn.frame              = CGRectMake(16, y, sw - 32, 56);
    pedirBtn.backgroundColor    = [UIColor colorNamed:@"app_theame"]
                                  ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    pedirBtn.layer.cornerRadius = 14;
    pedirBtn.clipsToBounds      = YES;
    [pedirBtn setTitle:[LanguageHelper getStringWithKey:@"k_s10_request_taxi" defaultValue:@"Pedir Taxi"] forState:UIControlStateNormal];
    [pedirBtn setTitleColor:darkText forState:UIControlStateNormal];
    pedirBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    [pedirBtn addTarget:self action:@selector(pedirTaxiTapped) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:pedirBtn];
    self.pedirBtn = pedirBtn;

    y += 56 + 20;

    // Finalise content view + scroll size
    cv.frame                = CGRectMake(0, 0, sw, y);
    scroll.contentSize      = CGSizeMake(sw, y);
}

#pragma mark - Config accordion content

- (void)buildConfigContent:(UIView *)cv width:(CGFloat)w
                  darkText:(UIColor *)darkText
                  grayText:(UIColor *)grayText
               borderColor:(UIColor *)borderColor {

    // Top divider separating header from content
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 1)];
    topLine.backgroundColor = borderColor;
    [cv addSubview:topLine];

    NSArray *rows = @[
        @{ @"icon":  @"person.3.fill",
           @"icon2": @"person.2.fill",
           @"title": [LanguageHelper getStringWithKey:@"k_s10_more_than_4_passengers" defaultValue:@"Llevo más de 4 Personas"],
           @"sub":   [LanguageHelper getStringWithKey:@"k_s10_4_passengers_limit" defaultValue:@"4 Personas es el límite por vehículo"] },
        @{ @"icon":  @"pawprint.fill",
           @"icon2": @"heart.fill",
           @"title": [LanguageHelper getStringWithKey:@"k_s10_i_have_pets" defaultValue:@"Llevo mascotas"],
           @"sub":   [LanguageHelper getStringWithKey:@"k_s10_some_drivers_pet_friendly" defaultValue:@"Algunos conductores son Pet Friendly"] },
        @{ @"icon":  @"shippingbox.fill",
           @"icon2": @"cube.fill",
           @"title": [LanguageHelper getStringWithKey:@"k_s10_its_delivery" defaultValue:@"Es un delivery"],
           @"sub":   [LanguageHelper getStringWithKey:@"k_s10_sending_package" defaultValue:@"Estoy enviando un paquete a otra persona"] },
    ];

    UIColor *yellowTint = [UIColor colorNamed:@"app_theame"]
                          ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    UIColor *iconTint   = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];

    NSArray *switches = @[
        (self.switchPassengers = [self makeSwitchWithTint:yellowTint]),
        (self.switchPets       = [self makeSwitchWithTint:yellowTint]),
        (self.switchDelivery   = [self makeSwitchWithTint:yellowTint]),
    ];

    for (NSInteger i = 0; i < (NSInteger)rows.count; i++) {
        NSDictionary *item = rows[(NSUInteger)i];
        CGFloat ry = 1.0 + i * (kRowH + 1.0); // +1 for separator slot

        // Row container
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, ry, w, kRowH)];
        [cv addSubview:row];

        // Icon
        UIImage *iconImg = [UIImage systemImageNamed:item[@"icon"]]
                           ?: [UIImage systemImageNamed:item[@"icon2"]];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(16, (kRowH - 28) / 2.0, 28, 28)];
        iconView.image       = [iconImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        iconView.tintColor   = iconTint;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [row addSubview:iconView];

        UISwitch *sw = switches[(NSUInteger)i];
        [sw sizeToFit];
        CGFloat swW = sw.frame.size.width;
        CGFloat swH = sw.frame.size.height;
        sw.frame = CGRectMake(w - 16 - swW, (kRowH - swH) / 2.0, swW, swH);
        [row addSubview:sw];

        // Available width for title + subtitle
        CGFloat textX    = 56.0;
        CGFloat textMaxW = w - textX - swW - 28.0; // 16 gap + 12 margin

        // Title
        UILabel *titleLbl = [[UILabel alloc] init];
        titleLbl.text      = item[@"title"];
        titleLbl.font      = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
        titleLbl.textColor = darkText;
        [titleLbl sizeToFit];
        CGFloat blockH    = titleLbl.frame.size.height + 3;

        UILabel *subLbl = [[UILabel alloc] init];
        subLbl.text          = item[@"sub"];
        subLbl.font          = [UIFont fontWithName:@"NotoSans-Regular" size:12] ?: [UIFont systemFontOfSize:12];
        subLbl.textColor     = grayText;
        subLbl.numberOfLines = 2;
        subLbl.frame         = CGRectMake(textX, 0, textMaxW, 0);
        [subLbl sizeToFit];
        blockH += subLbl.frame.size.height;

        CGFloat blockY = (kRowH - blockH) / 2.0;
        titleLbl.frame = CGRectMake(textX, blockY, textMaxW, titleLbl.frame.size.height);
        subLbl.frame   = CGRectMake(textX, CGRectGetMaxY(titleLbl.frame) + 3,
                                    textMaxW, subLbl.frame.size.height);
        [row addSubview:titleLbl];
        [row addSubview:subLbl];

        // Separator below row (not after last)
        if (i < (NSInteger)rows.count - 1) {
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(16, ry + kRowH, w - 32, 1)];
            sep.backgroundColor = borderColor;
            [cv addSubview:sep];
        }
    }
}

- (UISwitch *)makeSwitchWithTint:(UIColor *)tint {
    UISwitch *sw  = [[UISwitch alloc] init];
    sw.onTintColor = tint;
    sw.thumbTintColor = nil;
    return sw;
}

#pragma mark - Accordion toggle

- (void)configTapped {
    _configExpanded = !_configExpanded;
    CGFloat delta = _configExpanded ? kConfigContentH : -kConfigContentH;

    CGFloat sw = self.view.bounds.size.width;
    CGFloat sh = self.view.bounds.size.height;
    CGFloat newSheetStartY = _configExpanded ? sh * 0.10f : sh * 0.42f;
    CGFloat newSheetH      = sh - newSheetStartY;

    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        // Slide sheet up/down to 90% / original height
        self.sheetPanel.frame  = CGRectMake(0, newSheetStartY, sw, newSheetH);
        self.shadowPanel.frame = CGRectMake(0, newSheetStartY, sw, newSheetH);
        self.sheetScroll.frame = CGRectMake(0, 0, sw, newSheetH);
        ((UFareRootView *)self.view).sheetStartY = newSheetStartY;

        // Expand / collapse container height
        CGRect cf = self.configContainer.frame;
        cf.size.height += delta;
        self.configContainer.frame = cf;

        // Resize content view inside container
        CGRect ccf = self.configContentView.frame;
        ccf.size.height += delta;
        self.configContentView.frame = ccf;

        // Rotate chevron: down→up (180°) or up→down (0°)
        self.configChevron.transform = _configExpanded
            ? CGAffineTransformMakeRotation(M_PI)
            : CGAffineTransformIdentity;

        // Shift payRow and pedirBtn down/up by delta
        CGRect pf = self.payRow.frame;
        pf.origin.y += delta;
        self.payRow.frame = pf;

        CGRect bf = self.pedirBtn.frame;
        bf.origin.y += delta;
        self.pedirBtn.frame = bf;

        // Grow / shrink the content view and scroll area
        CGRect cvf = self.contentCV.frame;
        cvf.size.height += delta;
        self.contentCV.frame = cvf;
        self.sheetScroll.contentSize = CGSizeMake(sw, cvf.size.height);
    } completion:nil];
}

#pragma mark - Hint row helper

- (void)addHintIconName:(NSString *)iconName text:(NSString *)text
                 inView:(UIView *)parent x:(CGFloat)x y:(CGFloat)y width:(CGFloat)w {
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(x, y + 4, 16, 16)];
    icon.image       = [[UIImage systemImageNamed:iconName]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    icon.tintColor   = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [parent addSubview:icon];

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(x + 20, y, w - 22, 24)];
    lbl.text      = text;
    lbl.font      = [UIFont fontWithName:@"NotoSans-Regular" size:12] ?: [UIFont systemFontOfSize:12];
    lbl.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    [parent addSubview:lbl];
}

#pragma mark - Amount formatting

- (NSString *)formattedAmount:(float)amount {
    NSString *cur = self.currency.length > 0 ? self.currency : @"$";
    if (cur.length <= 1) return [NSString stringWithFormat:@"%.2f%@", amount, cur];
    return [NSString stringWithFormat:@"%.2f %@", amount, cur];
}

#pragma mark - Stepper actions

- (void)minusTapped {
    float step      = [self stepAmount];
    float newAmount = _currentAmount - step;
    if (self.minFare > 0 && newAmount < self.minFare) newAmount = self.minFare;
    if (newAmount < 0) newAmount = 0;
    _currentAmount        = newAmount;
    self.amountLabel.text = [self formattedAmount:_currentAmount];
}

- (void)plusTapped {
    float step      = [self stepAmount];
    float newAmount = _currentAmount + step;
    if (self.maxFare > 0 && newAmount > self.maxFare) newAmount = self.maxFare;
    _currentAmount        = newAmount;
    self.amountLabel.text = [self formattedAmount:_currentAmount];
}

/// Step = 5% of recommended fare, rounded to nearest 0.25 (min 0.25)
- (float)stepAmount {
    if (self.recommendedFare <= 0) return 0.25f;
    float raw     = self.recommendedFare * 0.05f;
    float rounded = (float)(round(raw * 4.0) / 4.0);
    return rounded > 0 ? rounded : 0.25f;
}

#pragma mark - Button actions

- (void)backTapped {
    [self.delegate fareOfferDidTapBack:self];
}

- (void)paymentTapped {
    [self.delegate fareOfferVCDidTapPayment:self];
}

- (void)pedirTaxiTapped {
    [self.delegate fareOfferVC:self didRequestTripWithAmount:_currentAmount];
}

#pragma mark - Public update

- (void)updatePaymentLabel:(NSString *)label icon:(UIImage *)icon {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.paymentRowLabel.text = [NSString stringWithFormat:[LanguageHelper getStringWithKey:@"k_s10_pay_with_format" defaultValue:@"Paga con %@"],
                                      label.length > 0 ? label : [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Efectivo"]];
        if (icon) {
            self.paymentIconView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    });
}

@end
