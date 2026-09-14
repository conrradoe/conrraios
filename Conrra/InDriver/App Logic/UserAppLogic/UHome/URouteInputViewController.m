//
//  URouteInputViewController.m
//  Conrra
//
//  Screen 2 — "Ingresa tu Ruta"
//  Fully programmatic. No storyboard/xib. Push from UHomeViewController.
//

#import "URouteInputViewController.h"
#import "SuggestedLocationDataSource.h"
#import "SuggestedLocationCell.h"
#import "UIViewController+LGSideMenuController.h"
#import "AppDelegate.h"
#import "Utilities.h"
#import "LanguageHelper.h"

@interface URouteInputViewController () <SuggestedLocationDataSourceDelegate>
{
    SuggestedLocationDataSource *locationDataSourcePickup;
    SuggestedLocationDataSource *locationDataSourceDrop;
}

@property (strong, nonatomic) UITextField *pickupField;
@property (strong, nonatomic) UITextField *destinationField;
@property (strong, nonatomic) UITableView *pickupTableView;
@property (strong, nonatomic) UITableView *destinationTableView;
@property (strong, nonatomic) UIView      *destContainer; // for border styling

@end

@implementation URouteInputViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildLayout];
    [self setupDataSources];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Auto-fill pickup from GPS if no address was passed (e.g. after trip cancel)
    if (self.pickupField.text.length == 0) {
        AppDelegate *app = APP_DELEGATE;
        CLLocationCoordinate2D coord = app.currLoc.coordinate;
        if (coord.latitude != 0) {
            [Utilities getAddressStrinByLat:coord.latitude
                                  longitude:coord.longitude
                      withcompletionHandler:^(NSString *address, NSString *shortAddress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *display = address.length > 0 ? address : shortAddress;
                    if (display.length > 0) {
                        self.pickupField.text      = display;
                        self.direction.pickAddress  = display;
                        self.direction.source       = app.currLoc;
                    }
                });
            }];
        }
    }

    [self.destinationField becomeFirstResponder];
}

#pragma mark - Layout

- (void)buildLayout {
    CGFloat sw      = self.view.bounds.size.width;
    CGFloat sh      = self.view.bounds.size.height;
    CGFloat statusH = [self statusBarHeight];
    CGFloat topBarH = 52.0;

    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, statusH + topBarH)];
    topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topBar];

    // Back button — gray circle with chevron
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    CGFloat btnY = statusH + (topBarH - 44.0) / 2.0;
    backBtn.frame = CGRectMake(16, btnY, 44, 44);
    backBtn.backgroundColor = [UIColor colorWithRed:0.918f green:0.918f blue:0.918f alpha:1.0f];
    backBtn.layer.cornerRadius = 22;
    backBtn.clipsToBounds = YES;
    UIImage *chevron = [UIImage systemImageNamed:@"chevron.left"];
    [backBtn setImage:chevron forState:UIControlStateNormal];
    backBtn.tintColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    [backBtn addTarget:self action:@selector(backTapped) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:backBtn];

    // Hamburger button — right side, mirrors back button
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    menuBtn.frame = CGRectMake(sw - 16 - 44, btnY, 44, 44);
    menuBtn.backgroundColor = [UIColor colorWithRed:0.918f green:0.918f blue:0.918f alpha:1.0f];
    menuBtn.layer.cornerRadius = 22;
    menuBtn.clipsToBounds = YES;
    UIImage *hamburger = [UIImage systemImageNamed:@"line.3.horizontal"];
    [menuBtn setImage:hamburger forState:UIControlStateNormal];
    menuBtn.tintColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    [menuBtn addTarget:self action:@selector(menuTapped) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:menuBtn];

    // Title label — centered
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = @"Ingresa tu Ruta";
    titleLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:18]
                    ?: [UIFont boldSystemFontOfSize:18];
    titleLbl.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    [titleLbl sizeToFit];
    CGFloat titleX = (sw - titleLbl.frame.size.width) / 2.0;
    CGFloat titleY = statusH + (topBarH - titleLbl.frame.size.height) / 2.0;
    titleLbl.frame = CGRectMake(titleX, titleY,
                                titleLbl.frame.size.width, titleLbl.frame.size.height);
    [topBar addSubview:titleLbl];

    // Bottom separator on top bar
    UIView *topSep = [[UIView alloc] initWithFrame:CGRectMake(0, statusH + topBarH - 0.5, sw, 0.5)];
    topSep.backgroundColor = [UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.0f];
    [topBar addSubview:topSep];

    CGFloat currentY = statusH + topBarH + 16.0;

    CGFloat vehicleRowH = [self buildVehicleCardsAtY:currentY width:sw];
    currentY += vehicleRowH + 16.0;

    // Thin divider below cards
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, currentY, sw, 0.5)];
    divider.backgroundColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.0f];
    [self.view addSubview:divider];
    currentY += 0.5 + 20.0;

    UIView *pickupContainer = [[UIView alloc] initWithFrame:CGRectMake(16, currentY, sw - 32, 52)];
    pickupContainer.backgroundColor = [UIColor colorWithRed:0.949f green:0.949f blue:0.949f alpha:1.0f];
    pickupContainer.layer.cornerRadius = 12;
    pickupContainer.clipsToBounds = YES;
    [self.view addSubview:pickupContainer];

    // Yellow circle with person icon
    UIView *personBg = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 32, 32)];
    personBg.layer.cornerRadius = 16;
    personBg.backgroundColor = [UIColor colorNamed:@"app_theame"]
                                ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    personBg.clipsToBounds = YES;
    [pickupContainer addSubview:personBg];

    UIImageView *personIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 20, 20)];
    personIcon.image = [[UIImage systemImageNamed:@"person.fill"]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    personIcon.tintColor = [UIColor whiteColor];
    personIcon.contentMode = UIViewContentModeScaleAspectFit;
    [personBg addSubview:personIcon];

    // Pickup text field
    CGFloat fieldX = 52.0;
    self.pickupField = [[UITextField alloc] initWithFrame:CGRectMake(fieldX, 0, sw - 32 - fieldX - 8, 52)];
    self.pickupField.text = self.direction.pickAddress ?: @"";
    self.pickupField.placeholder = [LanguageHelper getStringWithKey:@"k_s10_your_location" defaultValue:@"Tu ubicación"];
    self.pickupField.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                            ?: [UIFont systemFontOfSize:15];
    self.pickupField.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    self.pickupField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pickupField.borderStyle = UITextBorderStyleNone;
    self.pickupField.backgroundColor = [UIColor clearColor];
    self.pickupField.returnKeyType = UIReturnKeySearch;
    [pickupContainer addSubview:self.pickupField];

    currentY += 52.0 + 12.0;

    self.destContainer = [[UIView alloc] initWithFrame:CGRectMake(16, currentY, sw - 32, 52)];
    self.destContainer.backgroundColor = [UIColor whiteColor];
    self.destContainer.layer.cornerRadius = 12;
    self.destContainer.layer.borderWidth = 1.5f;
    self.destContainer.layer.borderColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f].CGColor;
    self.destContainer.clipsToBounds = YES;
    [self.view addSubview:self.destContainer];

    // Search icon left view
    UIView *iconContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 52)];
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 16, 20, 20)];
    searchIcon.image = [[UIImage systemImageNamed:@"magnifyingglass"]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    searchIcon.tintColor = [UIColor colorWithRed:0.62f green:0.62f blue:0.62f alpha:1.0f];
    searchIcon.contentMode = UIViewContentModeScaleAspectFit;
    [iconContainer addSubview:searchIcon];

    self.destinationField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, sw - 32, 52)];
    self.destinationField.leftView = iconContainer;
    self.destinationField.leftViewMode = UITextFieldViewModeAlways;
    self.destinationField.placeholder = @"Hacia:";
    self.destinationField.font = [UIFont fontWithName:@"NotoSans-Regular" size:15]
                                 ?: [UIFont systemFontOfSize:15];
    self.destinationField.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    self.destinationField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.destinationField.borderStyle = UITextBorderStyleNone;
    self.destinationField.backgroundColor = [UIColor clearColor];
    self.destinationField.returnKeyType = UIReturnKeySearch;
    [self.destContainer addSubview:self.destinationField];

    currentY += 52.0 + 8.0;

    CGFloat tableH = sh - currentY;

    self.pickupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, currentY, sw, tableH)
                                                        style:UITableViewStylePlain];
    self.pickupTableView.hidden = YES;
    self.pickupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pickupTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pickupTableView];

    self.destinationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, currentY, sw, tableH)
                                                             style:UITableViewStylePlain];
    self.destinationTableView.hidden = YES;
    self.destinationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.destinationTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.destinationTableView];

    // Register suggestion cell XIB for both tables
    UINib *cellNib = [UINib nibWithNibName:@"SuggestedLocationCell" bundle:nil];
    [self.pickupTableView      registerNib:cellNib forCellReuseIdentifier:@"SuggestedLocationCell"];
    [self.destinationTableView registerNib:cellNib forCellReuseIdentifier:@"SuggestedLocationCell"];
}

- (CGFloat)buildVehicleCardsAtY:(CGFloat)y width:(CGFloat)sw {
    NSInteger count = MIN((NSInteger)self.categories.count, 2);
    if (count == 0) return 0;

    CGFloat cardH   = 80.0;
    CGFloat cardW   = 80.0;
    CGFloat spacing = 12.0;
    CGFloat totalW  = count * cardW + (count - 1) * spacing;
    CGFloat startX  = (sw - totalW) / 2.0;

    UIColor *selectedBorder = [UIColor colorNamed:@"app_theame"]
                              ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];
    UIColor *selectedBg     = [UIColor colorWithRed:1.0f green:0.984f blue:0.918f alpha:1.0f];
    UIColor *normalBorder   = [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f];

    for (NSInteger i = 0; i < count; i++) {
        CategoryModel *cat = self.categories[i];
        BOOL isSelected = self.selectedCategory
                          && cat.categoryId == self.selectedCategory.categoryId;

        CGFloat cardX = startX + i * (cardW + spacing);
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(cardX, y, cardW, cardH)];
        card.backgroundColor    = isSelected ? selectedBg : [UIColor whiteColor];
        card.layer.cornerRadius = 12;
        card.layer.borderWidth  = 1.5f;
        card.layer.borderColor  = (isSelected ? selectedBorder : normalBorder).CGColor;
        card.clipsToBounds      = YES;
        [self.view addSubview:card];

        NSString *iconName  = (i == 0) ? @"ic_vehicle_moto" : @"ic_vehicle_car";
        UIImage  *icon      = [UIImage imageNamed:iconName] ?: [UIImage imageNamed:@"map_car_icon"];
        CGFloat   iconSize  = 48.0;
        UIImageView *iconIV = [[UIImageView alloc] initWithFrame:
            CGRectMake((cardW - iconSize) / 2.0, (cardH - iconSize) / 2.0, iconSize, iconSize)];
        iconIV.image       = icon;
        iconIV.contentMode = UIViewContentModeScaleAspectFit;
        [card addSubview:iconIV];
    }

    return cardH;
}

- (void)setupDataSources {
    locationDataSourcePickup = [[SuggestedLocationDataSource alloc]
        initWithTableView:self.pickupTableView textFiled:self.pickupField];
    locationDataSourcePickup.delegate = self;

    locationDataSourceDrop = [[SuggestedLocationDataSource alloc]
        initWithTableView:self.destinationTableView textFiled:self.destinationField];
    locationDataSourceDrop.delegate = self;
}

#pragma mark - Helpers

- (CGFloat)statusBarHeight {
    if (@available(iOS 13.0, *)) {
        UIWindowScene *scene = (UIWindowScene *)[UIApplication.sharedApplication.connectedScenes anyObject];
        return scene.statusBarManager.statusBarFrame.size.height;
    }
    return UIApplication.sharedApplication.statusBarFrame.size.height;
}

#pragma mark - Actions

- (void)backTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)menuTapped {
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

#pragma mark - SuggestedLocationDataSourceDelegate

- (void)source:(SuggestedLocationDataSource *)soure onSelectLocation:(NSDictionary *)dictLocation {
    if (soure == locationDataSourcePickup) {
        // Pickup changed — update direction locally and notify parent
        if (self.direction) {
            self.direction.pickAddress = [dictLocation objectForKey:@"description"] ?: @"";
        }
        self.pickupTableView.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(routeInputVC:didSelectPickup:)]) {
            [self.delegate routeInputVC:self didSelectPickup:dictLocation];
        }
    } else {
        // Destination selected.
        // Call delegate FIRST so it can set isReturningFromRouteInput = YES
        // on UHomeViewController before the pop triggers viewWillAppear: (which
        // would otherwise reset `direction` to a new empty object).
        [self.delegate routeInputVC:self didSelectDestination:dictLocation];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onAddressStartEditingsource:(SuggestedLocationDataSource *)soure {
    if (soure == locationDataSourcePickup) {
        self.pickupTableView.hidden      = NO;
        self.destinationTableView.hidden = YES;
        // Highlight destination border to inactive style while pickup is active
        self.destContainer.layer.borderColor =
            [UIColor colorWithRed:0.878f green:0.878f blue:0.878f alpha:1.0f].CGColor;
    } else {
        self.destinationTableView.hidden = NO;
        self.pickupTableView.hidden      = YES;
        // Active border on destination container
        self.destContainer.layer.borderColor =
            [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f].CGColor;
    }
}

- (void)onAddressEndEditingsource:(SuggestedLocationDataSource *)soure {
    if (soure == locationDataSourcePickup) {
        self.pickupTableView.hidden = YES;
    } else {
        self.destinationTableView.hidden = YES;
        // Reset dest border
        self.destContainer.layer.borderColor =
            [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f].CGColor;
    }
}

- (void)onAddressShouldClear:(SuggestedLocationDataSource *)soure {
    if (soure == locationDataSourcePickup) {
        if (self.direction) self.direction.pickAddress = @"";
        self.pickupTableView.hidden = YES;
    } else {
        self.destinationTableView.hidden = YES;
    }
}

- (void)onAddressEmptyShouldClear:(SuggestedLocationDataSource *)soure {
    if (soure == locationDataSourcePickup) {
        self.pickupTableView.hidden = YES;
    } else {
        self.destinationTableView.hidden = YES;
    }
}

@end
