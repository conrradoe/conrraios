//  OfferCardCell.m

#import "OfferCardCell.h"
#import <Conrra-Swift.h>
#import "TripModel.h"
#import "UserModel.h"
#import "CityModel.h"
#import "Utilities.h"
#import "LanguageHelper.h"
#import "Keys.h"
#import <SDWebImage/UIImageView+WebCache.h>

static UIColor *kCardGreen(void) { return [UIColor colorWithRed:0.18 green:0.65 blue:0.40 alpha:1.0]; }

@interface OfferCardCell ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *statsLabel;
@property (nonatomic, strong) UILabel *pickupLabel;
@property (nonatomic, strong) UILabel *dropLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *acceptButton;
@property (nonatomic, strong) TripOffer *offer;
@end

@implementation OfferCardCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self buildCard];
    }
    return self;
}

- (void)buildCard {
    _cardView = [[UIView alloc] init];
    _cardView.translatesAutoresizingMaskIntoConstraints = NO;
    _cardView.backgroundColor = UIColor.whiteColor;
    _cardView.layer.cornerRadius = 20;
    _cardView.layer.masksToBounds = NO;
    _cardView.layer.shadowColor = UIColor.blackColor.CGColor;
    _cardView.layer.shadowOpacity = 0.10f;
    _cardView.layer.shadowOffset = CGSizeMake(0, 4);
    _cardView.layer.shadowRadius = 8;
    [self.contentView addSubview:_cardView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    _titleLabel.numberOfLines = 1;
    _titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    [_cardView addSubview:_titleLabel];

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
    _nameLabel.numberOfLines = 1;
    [_cardView addSubview:_nameLabel];

    _statsLabel = [[UILabel alloc] init];
    _statsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _statsLabel.font = [UIFont systemFontOfSize:13];
    _statsLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    _statsLabel.numberOfLines = 1;
    [_cardView addSubview:_statsLabel];

    _pickupLabel = [[UILabel alloc] init];
    _pickupLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _pickupLabel.font = [UIFont systemFontOfSize:12];
    _pickupLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    _pickupLabel.numberOfLines = 2;
    [_cardView addSubview:_pickupLabel];

    _dropLabel = [[UILabel alloc] init];
    _dropLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dropLabel.font = [UIFont systemFontOfSize:12];
    _dropLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    _dropLabel.numberOfLines = 2;
    [_cardView addSubview:_dropLabel];

    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelButton setTitle:[LanguageHelper getStringWithKey:@"k_1_s9_cancel_offer" defaultValue:@"Cancelar mi oferta"] forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_cancelButton setTitleColor:[UIColor colorWithRed:0.78 green:0.16 blue:0.16 alpha:1.0] forState:UIControlStateNormal];
    _cancelButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.92 blue:0.93 alpha:1.0];
    _cancelButton.layer.cornerRadius = 10;
    _cancelButton.clipsToBounds = YES;
    [_cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
    [_cardView addSubview:_cancelButton];

    _acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _acceptButton.translatesAutoresizingMaskIntoConstraints = NO;
    _acceptButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_acceptButton setTitleColor:kCardGreen() forState:UIControlStateNormal];
    _acceptButton.backgroundColor = [UIColor colorWithRed:0.85 green:0.95 blue:0.88 alpha:1.0];
    _acceptButton.layer.cornerRadius = 10;
    _acceptButton.clipsToBounds = YES;
    [_acceptButton addTarget:self action:@selector(acceptTapped) forControlEvents:UIControlEventTouchUpInside];
    [_cardView addSubview:_acceptButton];

    [NSLayoutConstraint activateConstraints:@[
        [_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:2],
        [_cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [_cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-4],
        [_titleLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:10],
        [_titleLabel.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_titleLabel.heightAnchor constraintEqualToConstant:22],
        [_avatarImageView.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:6],
        [_avatarImageView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_avatarImageView.widthAnchor constraintEqualToConstant:44],
        [_avatarImageView.heightAnchor constraintEqualToConstant:44],
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_avatarImageView.trailingAnchor constant:10],
        [_nameLabel.centerYAnchor constraintEqualToAnchor:_avatarImageView.centerYAnchor constant:-10],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_statsLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_statsLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:2],
        [_statsLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_pickupLabel.topAnchor constraintEqualToAnchor:_statsLabel.bottomAnchor constant:18],
        [_pickupLabel.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_pickupLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_dropLabel.topAnchor constraintEqualToAnchor:_pickupLabel.bottomAnchor constant:4],
        [_dropLabel.leadingAnchor constraintEqualToAnchor:_pickupLabel.leadingAnchor],
        [_dropLabel.trailingAnchor constraintEqualToAnchor:_pickupLabel.trailingAnchor],
        [_cancelButton.topAnchor constraintEqualToAnchor:_dropLabel.bottomAnchor constant:40],
        [_cancelButton.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_cancelButton.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_cancelButton.heightAnchor constraintEqualToConstant:44],
        [_acceptButton.topAnchor constraintEqualToAnchor:_cancelButton.bottomAnchor constant:8],
        [_acceptButton.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [_acceptButton.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [_acceptButton.heightAnchor constraintEqualToConstant:44],
    ]];
}

- (void)configureWithOffer:(TripOffer *)offer {
    self.offer = offer;
    TripModel *trip = offer.trip;
    UserModel *user = trip.user;

    _titleLabel.text = [LanguageHelper getStringWithKey:@"k_1_s9_waiting_passenger" defaultValue:@"Esperando respuesta del Pasajero..."];

    NSString *profilePath = user.u_profile_image_path;
    if (profilePath.length > 0) {
        NSString *imgURL = [NSString stringWithFormat:@"%@%@", url_base_images, profilePath];
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    } else {
        _avatarImageView.image = [UIImage imageNamed:@"Profile Icon Crop Image"];
    }

    NSString *name = user.u_name.length > 0 ? user.u_name : [NSString stringWithFormat:@"%@ %@", user.u_fname ?: @"", user.u_lname ?: @""];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (name.length == 0) name = [LanguageHelper getStringWithKey:@"k_s3_passenger_name" defaultValue:@"Pasajero"];
    _nameLabel.text = name;

    float rating = user.rating;
    int rCount = user.rating_count;
    float dist = [trip.trip_distance floatValue];
    NSString *fareStr = offer.offer_amt.length > 0 ? offer.offer_amt : (trip.trip_fare.length > 0 ? trip.trip_fare : @"0");
    int cityId = (int)[trip city_id];
    CityModel *city = [CityModel getCityByCityId:(long)cityId];
    NSString *fareFmt = [Utilities formatAmountAndCurrency:[fareStr floatValue] currency:city.city_cur];
    NSString *statsText = [NSString stringWithFormat:@" %.1f (%d)  %.2f Km  %@", rating, rCount, dist, fareFmt ?: fareStr];
    NSDictionary *textAttrs = @{NSFontAttributeName: _statsLabel.font, NSForegroundColorAttributeName: _statsLabel.textColor};
    NSMutableAttributedString *statsAttr = [[NSMutableAttributedString alloc] init];
    UIImage *starImg = [UIImage imageNamed:@"ic_star"];
    if (starImg) {
        NSTextAttachment *att = [[NSTextAttachment alloc] init];
        att.image = starImg;
        CGFloat sz = _statsLabel.font.capHeight;
        att.bounds = CGRectMake(0, -1, sz, sz);
        [statsAttr appendAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
    } else {
        [statsAttr appendAttributedString:[[NSAttributedString alloc] initWithString:@"★" attributes:textAttrs]];
    }
    [statsAttr appendAttributedString:[[NSAttributedString alloc] initWithString:statsText attributes:textAttrs]];
    _statsLabel.attributedText = statsAttr;

    _pickupLabel.text = trip.trip_pick_loc.length > 0 ? trip.trip_pick_loc : @"–";
    _dropLabel.text = trip.trip_drop_loc.length > 0 ? trip.trip_drop_loc : @"–";

    NSString *acceptAmt = offer.user_offer_amt.length > 0 ? offer.user_offer_amt : offer.offer_amt;
    NSString *acceptFmt = acceptAmt.length > 0 ? [Utilities formatAmountAndCurrency:[acceptAmt floatValue] currency:city.city_cur] : nil;
    NSString *acceptTitle = acceptFmt.length > 0
        ? [NSString stringWithFormat:[LanguageHelper getStringWithKey:@"k_1_s9_accept_with" defaultValue:@"Aceptar con (%@)"], acceptFmt]
        : [LanguageHelper getStringWithKey:@"k_1_s9_accept" defaultValue:@"Aceptar"];
    [_acceptButton setTitle:acceptTitle forState:UIControlStateNormal];
}

- (void)cancelTapped {
    if (self.offer && [self.delegate respondsToSelector:@selector(offerCardCellDidRequestCancelOffer:)]) {
        [self.delegate offerCardCellDidRequestCancelOffer:self.offer];
    }
}

- (void)acceptTapped {
    if (self.offer && [self.delegate respondsToSelector:@selector(offerCardCellDidSelectOffer:)]) {
        [self.delegate offerCardCellDidSelectOffer:self.offer];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _avatarImageView.image = nil;
    _nameLabel.text = nil;
    _statsLabel.text = nil;
    _pickupLabel.text = nil;
    _dropLabel.text = nil;
    self.offer = nil;
}

@end
