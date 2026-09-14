//  RequestCardCell.m

#import "RequestCardCell.h"
#import "LanguageHelper.h"
#import "TripModel.h"
#import "UserModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Keys.h"

#define CARD_GREEN [UIColor colorWithRed:0.18 green:0.65 blue:0.40 alpha:1.0]

@interface RequestCardCell ()
@property (nonatomic, strong) UIView      *cardView;

// Top row
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *ratingLabel;
@property (nonatomic, strong) UILabel     *priceLabel;

// Route section
@property (nonatomic, strong) UIView      *routeContainerView;
@property (nonatomic, strong) UIImageView *originIconView;
@property (nonatomic, strong) UILabel     *originTitleLabel;
@property (nonatomic, strong) UILabel     *originSubLabel;
@property (nonatomic, strong) UIImageView *destIconView;
@property (nonatomic, strong) UILabel     *destTitleLabel;
@property (nonatomic, strong) UILabel     *destSubLabel;
@property (nonatomic, strong) CAShapeLayer *dashedLine;

// Tags row
@property (nonatomic, strong) UIStackView *tagsStackView;
@end

@implementation RequestCardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self buildCard];
    }
    return self;
}

#pragma mark - Build UI

- (void)buildCard {
    _cardView = [[UIView alloc] init];
    _cardView.translatesAutoresizingMaskIntoConstraints = NO;
    _cardView.backgroundColor = UIColor.whiteColor;
    _cardView.layer.cornerRadius = 20;
    _cardView.layer.masksToBounds = NO;
    _cardView.layer.shadowColor   = UIColor.blackColor.CGColor;
    _cardView.layer.shadowOpacity = 0.10f;
    _cardView.layer.shadowOffset  = CGSizeMake(0, 4);
    _cardView.layer.shadowRadius  = 8;
    [self.contentView addSubview:_cardView];
    [NSLayoutConstraint activateConstraints:@[
        [_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
        [_cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [_cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-4],
    ]];

    [self buildTopRow];
    [self buildRouteSection];
    [self buildTagsRow];
    [self buildCardLayout];
}

- (void)buildTopRow {
    _avatarImageView = [[UIImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarImageView.layer.cornerRadius = 22;
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    [_cardView addSubview:_avatarImageView];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    _nameLabel.textColor = UIColor.blackColor;
    [_cardView addSubview:_nameLabel];

    _ratingLabel = [[UILabel alloc] init];
    _ratingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _ratingLabel.font = [UIFont systemFontOfSize:13];
    _ratingLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    [_cardView addSubview:_ratingLabel];

    _priceLabel = [[UILabel alloc] init];
    _priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _priceLabel.font = [UIFont boldSystemFontOfSize:26];
    _priceLabel.textColor = UIColor.blackColor;
    _priceLabel.textAlignment = NSTextAlignmentRight;
    [_cardView addSubview:_priceLabel];
}

- (void)buildRouteSection {
    _routeContainerView = [[UIView alloc] init];
    _routeContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    _routeContainerView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    _routeContainerView.layer.cornerRadius = 12;
    [_cardView addSubview:_routeContainerView];

    // Origin icon — ic_trip_pickup asset
    _originIconView = [[UIImageView alloc] init];
    _originIconView.translatesAutoresizingMaskIntoConstraints = NO;
    _originIconView.contentMode = UIViewContentModeScaleAspectFit;
    _originIconView.image = [UIImage imageNamed:@"ic_trip_pickup"];
    [_routeContainerView addSubview:_originIconView];

    _originTitleLabel = [self makeTitleLabel];
    _originSubLabel   = [self makeSubLabel];
    [_routeContainerView addSubview:_originTitleLabel];
    [_routeContainerView addSubview:_originSubLabel];

    // Destination icon — ic_trip_drop asset
    _destIconView = [[UIImageView alloc] init];
    _destIconView.translatesAutoresizingMaskIntoConstraints = NO;
    _destIconView.contentMode = UIViewContentModeScaleAspectFit;
    _destIconView.image = [UIImage imageNamed:@"ic_trip_drop"];
    [_routeContainerView addSubview:_destIconView];

    _destTitleLabel = [self makeTitleLabel];
    _destSubLabel   = [self makeSubLabel];
    [_routeContainerView addSubview:_destTitleLabel];
    [_routeContainerView addSubview:_destSubLabel];

    // Icon column constraints (same for both)
    for (UIImageView *icon in @[_originIconView, _destIconView]) {
        [NSLayoutConstraint activateConstraints:@[
            [icon.leadingAnchor constraintEqualToAnchor:_routeContainerView.leadingAnchor constant:12],
            [icon.widthAnchor constraintEqualToConstant:28],
            [icon.heightAnchor constraintEqualToConstant:28],
        ]];
    }

    // Origin row
    [NSLayoutConstraint activateConstraints:@[
        [_originIconView.topAnchor constraintEqualToAnchor:_routeContainerView.topAnchor constant:12],
        [_originTitleLabel.leadingAnchor constraintEqualToAnchor:_originIconView.trailingAnchor constant:10],
        [_originTitleLabel.trailingAnchor constraintEqualToAnchor:_routeContainerView.trailingAnchor constant:-12],
        [_originTitleLabel.topAnchor constraintEqualToAnchor:_originIconView.topAnchor],
        [_originSubLabel.leadingAnchor constraintEqualToAnchor:_originTitleLabel.leadingAnchor],
        [_originSubLabel.trailingAnchor constraintEqualToAnchor:_originTitleLabel.trailingAnchor],
        [_originSubLabel.topAnchor constraintEqualToAnchor:_originTitleLabel.bottomAnchor constant:2],
        [_originIconView.centerYAnchor constraintEqualToAnchor:_originTitleLabel.centerYAnchor],
    ]];

    // Destination row — pinned directly below origin sub-label (no separator)
    [NSLayoutConstraint activateConstraints:@[
        [_destIconView.topAnchor constraintEqualToAnchor:_originSubLabel.bottomAnchor constant:14],
        [_destTitleLabel.leadingAnchor constraintEqualToAnchor:_destIconView.trailingAnchor constant:10],
        [_destTitleLabel.trailingAnchor constraintEqualToAnchor:_routeContainerView.trailingAnchor constant:-12],
        [_destTitleLabel.topAnchor constraintEqualToAnchor:_destIconView.topAnchor],
        [_destSubLabel.leadingAnchor constraintEqualToAnchor:_destTitleLabel.leadingAnchor],
        [_destSubLabel.trailingAnchor constraintEqualToAnchor:_destTitleLabel.trailingAnchor],
        [_destSubLabel.topAnchor constraintEqualToAnchor:_destTitleLabel.bottomAnchor constant:2],
        [_destSubLabel.bottomAnchor constraintEqualToAnchor:_routeContainerView.bottomAnchor constant:-12],
        [_destIconView.centerYAnchor constraintEqualToAnchor:_destTitleLabel.centerYAnchor],
    ]];
}

- (void)buildTagsRow {
    _tagsStackView = [[UIStackView alloc] init];
    _tagsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _tagsStackView.axis = UILayoutConstraintAxisVertical;
    _tagsStackView.spacing = 12;
    _tagsStackView.alignment = UIStackViewAlignmentFill;
    _tagsStackView.distribution = UIStackViewDistributionFill;
    [_cardView addSubview:_tagsStackView];
}

- (void)buildCardLayout {
    [NSLayoutConstraint activateConstraints:@[
        // Avatar
        [_avatarImageView.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:16],
        [_avatarImageView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_avatarImageView.widthAnchor constraintEqualToConstant:44],
        [_avatarImageView.heightAnchor constraintEqualToConstant:44],

        // Name
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_avatarImageView.trailingAnchor constant:12],
        [_nameLabel.topAnchor constraintEqualToAnchor:_avatarImageView.topAnchor constant:2],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:_priceLabel.leadingAnchor constant:-8],

        // Rating
        [_ratingLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_ratingLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:4],
        [_ratingLabel.trailingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],

        // Price
        [_priceLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_priceLabel.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor],
        [_priceLabel.widthAnchor constraintLessThanOrEqualToConstant:90],

        // Route section
        [_routeContainerView.topAnchor constraintEqualToAnchor:_avatarImageView.bottomAnchor constant:12],
        [_routeContainerView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:12],
        [_routeContainerView.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-12],

        // Tags row
        [_tagsStackView.topAnchor constraintEqualToAnchor:_routeContainerView.bottomAnchor constant:12],
        [_tagsStackView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_tagsStackView.trailingAnchor constraintLessThanOrEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_tagsStackView.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-16],
        [_tagsStackView.heightAnchor constraintGreaterThanOrEqualToConstant:20],
    ]];
}

#pragma mark - Dashed line (updated after layout pass)

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateDashedLine];
}

- (void)updateDashedLine {
    if (!_dashedLine) {
        _dashedLine = [CAShapeLayer layer];
        _dashedLine.strokeColor = [UIColor colorWithWhite:0.72 alpha:1].CGColor;
        _dashedLine.lineWidth   = 1.5f;
        _dashedLine.lineDashPattern = @[@5, @4];
        _dashedLine.fillColor   = UIColor.clearColor.CGColor;
        [_routeContainerView.layer addSublayer:_dashedLine];
    }

    CGRect originFrame = [_originIconView convertRect:_originIconView.bounds toView:_routeContainerView];
    CGRect destFrame   = [_destIconView   convertRect:_destIconView.bounds   toView:_routeContainerView];
    CGFloat x      = CGRectGetMidX(originFrame);
    CGFloat startY = CGRectGetMaxY(originFrame) + 4;
    CGFloat endY   = CGRectGetMinY(destFrame)   - 4;

    if (endY > startY) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(x, startY)];
        [path addLineToPoint:CGPointMake(x, endY)];
        _dashedLine.path = path.CGPath;
    }
}

#pragma mark - Configure

- (void)configureWithTrip:(TripModel *)trip {
    // Avatar — u_profile_image_path is a relative path; prepend base URL
    NSString *imgURL = trip.user.u_profile_image_path;
    if (imgURL.length > 0) {
        NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, imgURL]];
        [_avatarImageView sd_setImageWithURL:avatarURL
                            placeholderImage:[UIImage systemImageNamed:@"person.circle.fill"]];
    } else {
        _avatarImageView.image = [UIImage systemImageNamed:@"person.circle.fill"];
        _avatarImageView.tintColor = [UIColor colorWithWhite:0.7 alpha:1];
    }

    // Name
    _nameLabel.text = trip.user.u_name.length > 0
        ? trip.user.u_name
        : [LanguageHelper getStringWithKey:@"k_s3_passenger_name" defaultValue:@"Pasajero"];

    // Rating + trip distance (trip_distance is the pickup→drop km; user.distance is driver→rider which is often 0)
    float dist = [trip.trip_distance floatValue];
    NSString *distStr = dist > 0 ? [NSString stringWithFormat:@"  ·  %.2f km", dist] : @"";
    _ratingLabel.text = [NSString stringWithFormat:@"★ %.1f (%d)%@",
                         trip.user.rating, trip.user.rating_count, distStr];

    // Price
    NSString *fareStr = trip.trip_fare.length > 0 ? trip.trip_fare : trip.base_est_amt;
    _priceLabel.text = fareStr.length > 0 ? [NSString stringWithFormat:@"%@$", fareStr] : @"–";

    // Addresses — prefer trip_pick/drop_loc, fall back to actual_*
    NSString *pickStr = trip.trip_pick_loc.length > 0 ? trip.trip_pick_loc : trip.actual_from_loc;
    NSString *dropStr = trip.trip_drop_loc.length > 0 ? trip.trip_drop_loc : trip.actual_to_loc;
    [self setRouteTitle:_originTitleLabel sub:_originSubLabel forLocation:pickStr
           defaultTitle:[LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc" defaultValue:@"Origen"]];
    [self setRouteTitle:_destTitleLabel sub:_destSubLabel forLocation:dropStr
           defaultTitle:[LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location" defaultValue:@"Destino"]];

    // Tags
    [_tagsStackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addTagsForTrip:trip];
}

// Split "Place Name, Street detail, more detail" on first comma
- (void)setRouteTitle:(UILabel *)titleLbl sub:(UILabel *)subLbl
          forLocation:(NSString *)location defaultTitle:(NSString *)defaultTitle {
    NSString *trimmed = [location stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (trimmed.length == 0) {
        titleLbl.text = defaultTitle;
        subLbl.text   = @"–";
        return;
    }
    NSRange comma = [trimmed rangeOfString:@","];
    if (comma.location != NSNotFound) {
        titleLbl.text = [trimmed substringToIndex:comma.location];
        subLbl.text   = [[trimmed substringFromIndex:comma.location + 1]
                         stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    } else if (trimmed.length > 25) {
        // No comma but address is long — split at last word boundary before char 30
        NSUInteger limit = MIN(30, trimmed.length);
        NSRange searchRange = NSMakeRange(0, limit);
        NSRange spaceRange  = [trimmed rangeOfString:@" " options:NSBackwardsSearch range:searchRange];
        if (spaceRange.location != NSNotFound) {
            titleLbl.text = [trimmed substringToIndex:spaceRange.location];
            subLbl.text   = [trimmed substringFromIndex:spaceRange.location + 1];
        } else {
            titleLbl.text = trimmed;
            subLbl.text   = @"";
        }
    } else {
        titleLbl.text = trimmed;
        subLbl.text   = @"";
    }
}

- (void)addTagsForTrip:(TripModel *)trip {
    // Build ordered list of tags from pickup_notes (format: "PayMethod|Service|N Pasajero|time")
    NSMutableArray<NSDictionary *> *tags = [NSMutableArray array];

    NSString *notes = [trip.pickup_notes stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (notes.length > 0) {
        NSArray<NSString *> *parts = [notes componentsSeparatedByString:@"|"];

        // Part 0: payment method → always "Paga en Efectivo"
        if (parts.count > 0 && [parts[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].length > 0)
            [tags addObject:@{@"asset": @"ic_trip_cash", @"text": @"Paga en Efectivo"}];

        // Part 1: pet or delivery
        if (parts.count > 1) {
            NSString *sl = [parts[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].lowercaseString;
            if ([sl containsString:@"mascota"] || [sl containsString:@"pet"])
                [tags addObject:@{@"asset": @"ic_trip_pet", @"text": @"Lleva Mascotas"}];
            else if ([sl containsString:@"delivery"])
                [tags addObject:@{@"asset": @"ic_trip_delivery", @"text": @"Es un Delivery"}];
        }

        // Part 2: passenger count
        if (parts.count > 2) {
            int count = [[parts[2] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] intValue];
            if (count > 0)
                [tags addObject:@{@"asset": @"ic_trip_person",
                                  @"text": [NSString stringWithFormat:@"%d Persona%@", count, count == 1 ? @"" : @"s"]}];
        }
    } else {
        // Fallback: static cash tag
        [tags addObject:@{@"asset": @"ic_trip_cash",
                          @"text": [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Paga en Efectivo"]}];
        if (trip.is_share)
            [tags addObject:@{@"asset": @"ic_trip_person", @"text": @"Compartido"}];
    }

    // Build 2-column rows
    NSUInteger numRows = (tags.count + 1) / 2;
    for (NSUInteger row = 0; row < numRows; row++) {
        UIStackView *hRow = [[UIStackView alloc] init];
        hRow.axis = UILayoutConstraintAxisHorizontal;
        hRow.spacing = 16;
        hRow.distribution = UIStackViewDistributionFill;
        hRow.alignment = UIStackViewAlignmentCenter;

        UIView *leftTag  = nil;
        UIView *rightTag = nil;

        NSUInteger leftIdx  = row * 2;
        NSUInteger rightIdx = row * 2 + 1;

        if (leftIdx < tags.count) {
            leftTag = [self makeTagWithAsset:tags[leftIdx][@"asset"] text:tags[leftIdx][@"text"]];
        } else {
            leftTag = [[UIView alloc] init];
        }

        // Thin vertical separator
        UIView *sep = [[UIView alloc] init];
        sep.translatesAutoresizingMaskIntoConstraints = NO;
        sep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        [sep.widthAnchor constraintEqualToConstant:1.0].active = YES;

        if (rightIdx < tags.count) {
            rightTag = [self makeTagWithAsset:tags[rightIdx][@"asset"] text:tags[rightIdx][@"text"]];
        } else {
            rightTag = [[UIView alloc] init];
        }

        [hRow addArrangedSubview:leftTag];
        [hRow addArrangedSubview:sep];
        [hRow addArrangedSubview:rightTag];

        // Equal width for left and right columns
        [leftTag.widthAnchor constraintEqualToAnchor:rightTag.widthAnchor].active = YES;

        [_tagsStackView addArrangedSubview:hRow];
    }
}

#pragma mark - Factory helpers

- (UILabel *)makeTitleLabel {
    UILabel *l = [[UILabel alloc] init];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.font = [UIFont boldSystemFontOfSize:14];
    l.textColor = UIColor.blackColor;
    l.numberOfLines = 1;
    return l;
}

- (UILabel *)makeSubLabel {
    UILabel *l = [[UILabel alloc] init];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.font = [UIFont systemFontOfSize:12];
    l.textColor = [UIColor colorWithWhite:0.55 alpha:1];
    l.numberOfLines = 2;
    return l;
}

- (UIView *)makeTagWithAsset:(NSString *)assetName text:(NSString *)text {
    UIStackView *sv = [[UIStackView alloc] init];
    sv.axis = UILayoutConstraintAxisHorizontal;
    sv.spacing = 5;
    sv.alignment = UIStackViewAlignmentCenter;

    UIImageView *iv = [[UIImageView alloc] init];
    iv.image = [UIImage imageNamed:assetName];
    iv.tintColor = CARD_GREEN;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [iv setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [NSLayoutConstraint activateConstraints:@[
        [iv.widthAnchor constraintEqualToConstant:16],
        [iv.heightAnchor constraintEqualToConstant:16],
    ]];
    [sv addArrangedSubview:iv];

    UILabel *lbl = [[UILabel alloc] init];
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:13];
    lbl.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    [sv addArrangedSubview:lbl];

    return sv;
}

- (UIView *)makeTag:(NSString *)text iconName:(NSString *)icon {
    UIStackView *sv = [[UIStackView alloc] init];
    sv.axis = UILayoutConstraintAxisHorizontal;
    sv.spacing = 4;
    sv.alignment = UIStackViewAlignmentCenter;

    if (@available(iOS 13, *)) {
        UIImageView *iv = [[UIImageView alloc] init];
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:13 weight:UIImageSymbolWeightRegular];
        iv.image = [UIImage systemImageNamed:icon withConfiguration:cfg];
        iv.tintColor = CARD_GREEN;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [iv setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [sv addArrangedSubview:iv];
    }

    UILabel *lbl = [[UILabel alloc] init];
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:13];
    lbl.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    [sv addArrangedSubview:lbl];

    return sv;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _avatarImageView.image  = nil;
    _nameLabel.text         = nil;
    _ratingLabel.text       = nil;
    _priceLabel.text        = nil;
    _originTitleLabel.text  = nil;
    _originSubLabel.text    = nil;
    _destTitleLabel.text    = nil;
    _destSubLabel.text      = nil;
    [_tagsStackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
