//
//  EditProfileViewController.m
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 23/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "UEditProfileViewController.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "CityModel.h"
#import "UIImagePickerController+Extension.h"
#import "ConstantModel.h"
#import "AskLast4DigitDeleteVC.h"
#import "UserProfile.h"
#import "CounrySelectionView.h"
@interface UEditProfileViewController ()
@end

@implementation UEditProfileViewController
{
    ConstantModel *constantTaxiModel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    constantTaxiModel = [ConstantModel getConstantsObject];
    [self setupNewDesign];
}


-(void)setUIFiels{
    
    self.txtLastName.text = [LanguageHelper getStringWithKey:@"k_3_s2_lname"];
    self.txtFirstName.placeholder=[LanguageHelper getStringWithKey:@"k_1_s2_fname"];
    self.lblFname.text = [LanguageHelper getStringWithKey:@"k_1_s2_fname"];
    self.lblLname.text = [LanguageHelper getStringWithKey:@"k_3_s2_lname"];
    self.lblEmail.text = [LanguageHelper getStringWithKey:@"k_13_s1_email"];
    self.txtEmail.placeholder=[LanguageHelper getStringWithKey:@"k_13_s1_email"];
    self.lblCity.text = [LanguageHelper getStringWithKey:@"k_27_s5_city"];
    self.lblMobile.text = [LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint"];
    self.txtMobile.placeholder=[LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint"];
    self.lblChangePassword.text = [LanguageHelper getStringWithKey:@"k_19_s6_update_password"];
    
    self.lblCurPassword.text = [LanguageHelper getStringWithKey:@"k_20_s6_current_password"];
    self.txtOldPassword.placeholder=[LanguageHelper getStringWithKey:@"k_20_s6_current_password"];
    self.lblNewPassword.text = [LanguageHelper getStringWithKey:@"k_21_s6_new_password"];
    self.txtNewPassword.placeholder=[LanguageHelper getStringWithKey:@"k_21_s6_new_password"];
    self.lblConfirmPassword.text = [LanguageHelper getStringWithKey:@"k_13_s2_confirm_password"];
    self.txtConfirmPassword.placeholder=[LanguageHelper getStringWithKey:@"k_13_s2_confirm_password"];
    [self.btnSave setTitle: [LanguageHelper getStringWithKey:@"k_34_s6_save"]   forState:UIControlStateNormal];
    self.lblCity.text=[LanguageHelper getStringWithKey:@"k_18_s6_city"];
    [self.btnDeleteAccount setTitle: [LanguageHelper getStringWithKey:@"k_s7_dte_ac" ]   forState:UIControlStateNormal];
}




-(void)setThemeConstants{}

#pragma mark - Full programmatic rebuild

- (void)setupNewDesign {
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;

    UIColor *darkText  = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    UIColor *grayText  = [UIColor colorWithRed:0.502f green:0.502f blue:0.502f alpha:1.0f];
    UIColor *fieldBg   = [UIColor colorWithRed:0.945f green:0.945f blue:0.945f alpha:1.0f];
    UIColor *sepColor  = [UIColor colorWithRed:0.906f green:0.906f blue:0.906f alpha:1.0f];
    UIColor *deleteBg  = [UIColor colorWithRed:1.0f   green:0.933f blue:0.933f alpha:1.0f];
    UIColor *deleteRed = [UIColor colorWithRed:0.941f green:0.169f blue:0.169f alpha:1.0f];
    UIColor *yellow    = [UIColor colorNamed:@"app_theame"]
                         ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];

    self.view.backgroundColor = [UIColor whiteColor];
    for (UIView *v in self.view.subviews) v.hidden = YES;

    CGFloat statusH = UIApplication.sharedApplication.statusBarFrame.size.height;
    if (statusH < 20) statusH = 20;
    CGFloat barH = statusH + 56.0f;

    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, barH)];
    topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topBar];

    // Main scroll view (starts below the fixed header)
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, barH, sw, sh - barH)];
    sv.backgroundColor = [UIColor whiteColor];
    sv.showsVerticalScrollIndicator = NO;
    [self.view addSubview:sv];
    self.profileScrollView = sv;

    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 900)];
    [sv addSubview:cv];

    CGFloat y = 0;

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(16, statusH + 6, 44, 44);
    backBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    backBtn.layer.cornerRadius = 22;
    backBtn.clipsToBounds = YES;
    UIImage *chevronImg = [[UIImage systemImageNamed:@"chevron.left"]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backBtn setImage:chevronImg forState:UIControlStateNormal];
    backBtn.tintColor = darkText;
    [backBtn addTarget:self action:@selector(ButtonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = @"Mi perfil";
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = darkText;
    [titleLbl sizeToFit];
    titleLbl.center = CGPointMake(sw / 2.0f, statusH + 28.0f);
    [topBar addSubview:titleLbl];

    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, barH - 1, sw, 1)];
    topBorder.backgroundColor = sepColor;
    [topBar addSubview:topBorder];

    y = 32;

    CGFloat photoSize = 100.0f;
    UIView *photoWrap = [[UIView alloc] initWithFrame:CGRectMake((sw - photoSize) / 2.0f, y, photoSize, photoSize)];
    [cv addSubview:photoWrap];

    UIImageView *photoIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, photoSize, photoSize)];
    photoIV.layer.cornerRadius = photoSize / 2.0f;
    photoIV.clipsToBounds      = YES;
    photoIV.contentMode        = UIViewContentModeScaleAspectFill;
    photoIV.backgroundColor    = [UIColor colorWithWhite:0.88 alpha:1];
    photoIV.image              = [UIImage imageNamed:@"Profile Icon Crop Image"];
    [photoWrap addSubview:photoIV];
    self.imgProfile = photoIV;

    // Edit badge (dark circle with pencil icon at bottom-right)
    UIView *badge = [[UIView alloc] initWithFrame:CGRectMake(photoSize - 30, photoSize - 30, 32, 32)];
    badge.backgroundColor    = [UIColor colorWithRed:0.18f green:0.18f blue:0.22f alpha:1];
    badge.layer.cornerRadius = 16;
    badge.clipsToBounds      = YES;
    UIImageView *pencilIV = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 18, 18)];
    UIImage *pencilImg = [[UIImage systemImageNamed:@"pencil"]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    pencilIV.image       = pencilImg;
    pencilIV.tintColor   = [UIColor whiteColor];
    pencilIV.contentMode = UIViewContentModeScaleAspectFit;
    [badge addSubview:pencilIV];
    [photoWrap addSubview:badge];

    UIButton *photoTapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoTapBtn.frame = CGRectMake(0, 0, photoSize, photoSize);
    [photoTapBtn addTarget:self action:@selector(ButtonProfileTapped:) forControlEvents:UIControlEventTouchUpInside];
    [photoWrap addSubview:photoTapBtn];

    // Spinner (shown during photo upload)
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    spinner.center = CGPointMake(photoSize / 2, photoSize / 2);
    spinner.hidden = YES;
    [photoWrap addSubview:spinner];
    self.spinnerView = spinner;

    y += photoSize + 16;

    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, y, sw - 32, 28)];
    nameLbl.font          = FONTS_NOTO_BOLD(20);
    nameLbl.textColor     = darkText;
    nameLbl.textAlignment = NSTextAlignmentCenter;
    [cv addSubview:nameLbl];
    self.userNameLbl = nameLbl;
    y += 28 + 6;

    UILabel *phoneLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, y, sw, 20)];
    phoneLbl.font          = FONTS_NOTO_REGULAR(14);
    phoneLbl.textColor     = grayText;
    phoneLbl.textAlignment = NSTextAlignmentCenter;
    [cv addSubview:phoneLbl];
    self.userMobileLbl = phoneLbl;
    y += 20 + 8;

    NSDictionary *ud = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    float rating = [[ud objectForKey:@"rating"] floatValue];
    UILabel *ratingLbl = [[UILabel alloc] init];
    ratingLbl.font = FONTS_NOTO_REGULAR(14);
    UIColor *starYellow = [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    NSString *ratingVal = [NSString stringWithFormat:@"%.1f", rating > 0 ? rating : 0.0f];
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:19.5 weight:UIImageSymbolWeightRegular];
        UIImage *base = [UIImage systemImageNamed:@"star.fill" withConfiguration:cfg];
        UIGraphicsBeginImageContextWithOptions(base.size, NO, 0);
        [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeSourceIn);
        [starYellow setFill];
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, base.size.width, base.size.height));
        UIImage *starImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSTextAttachment *att = [[NSTextAttachment alloc] init];
        att.image = starImg;
        CGFloat cap = ratingLbl.font.capHeight;
        CGFloat size = cap * 1.5;
        att.bounds = CGRectMake(0, (cap - size) / 2.0, size, size);
        NSMutableAttributedString *full = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
        [full appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", ratingVal] attributes:@{NSFontAttributeName: ratingLbl.font, NSForegroundColorAttributeName: starYellow}]];
        ratingLbl.attributedText = full;
    } else {
        ratingLbl.text = [NSString stringWithFormat:@"★ %@", ratingVal];
        ratingLbl.textColor = starYellow;
    }
    ratingLbl.numberOfLines = 1;
    CGSize fit = [ratingLbl sizeThatFits:CGSizeMake(sw, 40)];
    ratingLbl.frame = CGRectMake((sw - fit.width) / 2.0f, y, fit.width, fit.height);
    [cv addSubview:ratingLbl];
    y += ratingLbl.frame.size.height + 28;

    UIView *div1 = [[UIView alloc] initWithFrame:CGRectMake(0, y, sw, 1)];
    div1.backgroundColor = sepColor;
    [cv addSubview:div1];
    y += 1 + 24;

    CGFloat fH = 56.0f, fX = 16.0f, fW = sw - 32.0f;

    UIView *fnBox = [[UIView alloc] initWithFrame:CGRectMake(fX, y, fW, fH)];
    fnBox.backgroundColor = fieldBg; fnBox.layer.cornerRadius = 14;
    [cv addSubview:fnBox];
    UITextField *fnTf = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, fW - 32, fH)];
    fnTf.font = FONTS_NOTO_REGULAR(16); fnTf.textColor = darkText;
    fnTf.keyboardType = UIKeyboardTypeDefault; fnTf.delegate = self;
    fnTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Nombre"
        attributes:@{NSForegroundColorAttributeName: grayText, NSFontAttributeName: FONTS_NOTO_REGULAR(16)}];
    [fnBox addSubview:fnTf];
    self.txtFirstName = fnTf;
    y += fH + 12;

    UIView *lnBox = [[UIView alloc] initWithFrame:CGRectMake(fX, y, fW, fH)];
    lnBox.backgroundColor = fieldBg; lnBox.layer.cornerRadius = 14;
    [cv addSubview:lnBox];
    UITextField *lnTf = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, fW - 32, fH)];
    lnTf.font = FONTS_NOTO_REGULAR(16); lnTf.textColor = darkText;
    lnTf.keyboardType = UIKeyboardTypeDefault; lnTf.delegate = self;
    lnTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Apellido"
        attributes:@{NSForegroundColorAttributeName: grayText, NSFontAttributeName: FONTS_NOTO_REGULAR(16)}];
    [lnBox addSubview:lnTf];
    self.txtLastName = lnTf;
    y += fH + 12;

    UIView *emBox = [[UIView alloc] initWithFrame:CGRectMake(fX, y, fW, fH)];
    emBox.backgroundColor = fieldBg; emBox.layer.cornerRadius = 14;
    [cv addSubview:emBox];
    UITextField *emTf = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, fW - 32, fH)];
    emTf.font = FONTS_NOTO_REGULAR(16); emTf.textColor = darkText;
    emTf.keyboardType = UIKeyboardTypeEmailAddress; emTf.delegate = self;
    emTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_13_s1_email" defaultValue:@"Correo electrónico"]
        attributes:@{NSForegroundColorAttributeName: grayText, NSFontAttributeName: FONTS_NOTO_REGULAR(16)}];
    [emBox addSubview:emTf];
    self.txtEmail = emTf;
    y += fH + 12;

    UIView *phBox = [[UIView alloc] initWithFrame:CGRectMake(fX, y, fW, fH)];
    phBox.backgroundColor    = fieldBg;
    phBox.layer.cornerRadius = 14;
    phBox.clipsToBounds      = YES;
    [cv addSubview:phBox];

    // Country code lookup
    NSString *rawCode   = isEmpty([ud objectForKey:P_C_CODE]);
    NSString *dialCode  = rawCode.length > 0 ? [NSString stringWithFormat:@"+%@", rawCode] : @"+58";
    NSDictionary *cDict = [CounrySelectionView getCurrentCountryDictWithDialCode:dialCode]
                          ?: [CounrySelectionView getCurrentCountryDictWithCountryCode:@"VE"];
    NSString *flagEmoji = [CounrySelectionView flagEmojiForCode:cDict[@"code"] ?: @"VE"];

    UIButton *countryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    countryBtn.frame = CGRectMake(0, 0, 96, fH);
    NSString *countryTitle = [NSString stringWithFormat:@"%@  %@  ▾", flagEmoji, dialCode];
    [countryBtn setTitle:countryTitle forState:UIControlStateNormal];
    [countryBtn setTitleColor:darkText forState:UIControlStateNormal];
    countryBtn.titleLabel.font = FONTS_NOTO_REGULAR(14);
    [phBox addSubview:countryBtn];

    UIView *phDivider = [[UIView alloc] initWithFrame:CGRectMake(96, 16, 1, fH - 32)];
    phDivider.backgroundColor = sepColor;
    [phBox addSubview:phDivider];

    UITextField *phTf = [[UITextField alloc] initWithFrame:CGRectMake(108, 0, fW - 120, fH)];
    phTf.font          = FONTS_NOTO_REGULAR(16);
    phTf.textColor     = darkText;
    phTf.keyboardType  = UIKeyboardTypePhonePad;
    phTf.delegate      = self;
    phTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint" defaultValue:@"Número de teléfono"]
        attributes:@{NSForegroundColorAttributeName: grayText,
                     NSFontAttributeName: FONTS_NOTO_REGULAR(16)}];
    [phBox addSubview:phTf];
    self.txtMobile = phTf;
    y += fH + 24;

    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame               = CGRectMake(fX, y, fW, 56);
    saveBtn.backgroundColor     = yellow;
    saveBtn.layer.cornerRadius  = 14;
    saveBtn.clipsToBounds       = YES;
    saveBtn.titleLabel.font     = FONTS_NOTO_BOLD(17);
    [saveBtn setTitle:@"Guardar" forState:UIControlStateNormal];
    [saveBtn setTitleColor:darkText forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(ButtonSavePressed:) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:saveBtn];
    self.btnSave = saveBtn;
    y += 56 + 28;

    UIView *div2 = [[UIView alloc] initWithFrame:CGRectMake(0, y, sw, 1)];
    div2.backgroundColor = sepColor;
    [cv addSubview:div2];
    y += 1 + 24;

    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame               = CGRectMake(fX, y, fW, 56);
    deleteBtn.backgroundColor     = deleteBg;
    deleteBtn.layer.cornerRadius  = 14;
    deleteBtn.clipsToBounds       = YES;

    NSMutableAttributedString *delAttr = [[NSMutableAttributedString alloc]
        initWithString:@"Eliminar mi cuenta  "
            attributes:@{NSFontAttributeName: FONTS_NOTO_REGULAR(16),
                         NSForegroundColorAttributeName: deleteRed}];
    NSTextAttachment *trashAtt = [[NSTextAttachment alloc] init];
    UIImage *trashImg = [UIImage imageNamed:@"ic_trash"];
    trashAtt.image = trashImg;
    [trashAtt setBounds:CGRectMake(0, -3, 18, 18)];
    [delAttr appendAttributedString:[NSAttributedString attributedStringWithAttachment:trashAtt]];
    [deleteBtn setAttributedTitle:delAttr forState:UIControlStateNormal];
    deleteBtn.tintColor = deleteRed;
    [deleteBtn addTarget:self action:@selector(onDeleteAccountButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:deleteBtn];
    self.btnDeleteAccount = deleteBtn;
    y += 56 + 40;

    cv.frame             = CGRectMake(0, 0, sw, y);
    sv.contentSize       = CGSizeMake(sw, y);

    // Populate new fields with user data
    [self setData];

    // Strip dial code prefix from phone field (it's shown in the country button)
    NSString *storedPhone = self.txtMobile.text;
    if (dialCode.length > 0 && [storedPhone hasPrefix:dialCode]) {
        self.txtMobile.text = [storedPhone substringFromIndex:dialCode.length];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}



-(void)setupTextField:(UITextField*)textField{
    [self setTextFieldPlaceholderColor:textField];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

 
-(void)setData{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    if (!dict1) return;
    if (self.viewCity) {
        self.viewCity.hidden = NO;
        [self.viewCity hideByHeight:YES];
        if ([APP_DELEGATE arrayCities].count <= 1) {
            if (self.lblCity) self.lblCity.text = @"";
            [self.viewCity hideByHeight:YES];
        } else {
            CityModel *city = [CityModel getCityByCityId:[UserProfile shared].cityID];
            if (self.lblCityName) self.lblCityName.text = isEmpty(city.city_name);
            [self.viewCity setConstraintConstant:50 forAttribute:(NSLayoutAttributeHeight)];
            self.viewCity.hidden = NO;
        }
    }
//    _txtEmailLbl.text =[dict1 objectForKey:P_U_EMAIL];
//    _txtMobile.text = [NSString stringWithFormat:@"+%@%@",[dict1 objectForKey:P_C_CODE],[dict1 objectForKey:P_U_MOBILE] ];
    
    if(IS_PHONE_VERIFICATION==1){
        self.txtEmail.enabled=YES;
        self.txtMobile.enabled=NO;
        self.txtEmail.text=[dict1 objectForKey:P_U_EMAIL];
        _txtMobile.text = [NSString stringWithFormat:@"+%@%@",isEmpty([dict1 objectForKey:P_C_CODE]),[dict1 objectForKey:P_U_MOBILE]];
    }else{
        self.txtEmail.enabled=NO;
        self.txtMobile.enabled=YES;
        self.txtEmail.text=[dict1 objectForKey:P_U_EMAIL];
        _txtMobile.text = [NSString stringWithFormat:@"%@",[dict1 objectForKey:P_U_MOBILE]];
    }
    
    
    _txtFirstName.text =[NSString stringWithFormat:@"%@", [dict1 objectForKey:P_U_FNAME]];
    _txtLastName.text =[NSString stringWithFormat:@"%@",[dict1 objectForKey:P_U_LNAME]];
    _userNameLbl.text = [NSString stringWithFormat:@"%@  %@", [dict1 objectForKey:P_U_FNAME],[dict1 objectForKey:P_U_LNAME]];
    if(IS_PHONE_VERIFICATION == 1){
        _userMobileLbl.text = [NSString stringWithFormat:@"+%@%@",[dict1 objectForKey:P_C_CODE],[dict1 objectForKey:P_U_MOBILE] ];
    }else{
        _userMobileLbl.text = [NSString stringWithFormat:@"%@",[dict1 objectForKey:P_U_EMAIL]];
    }
    
    NSString *profile=[dict1 objectForKey:P_PROFILE_IMAGE_PATH];
    if (profile.length>0) {
        [_imgProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    if (self.lblReferralCode) {
        if ([constantTaxiModel getCValueFK:ckey_erf] == NO) {
            self.lblReferralCode.text = @"";
            [self.lblReferralCode hideByHeight:YES];
        } else {
            [self.lblReferralCode hideByHeight:YES];
            self.lblReferralCode.text = [NSString stringWithFormat:@"%@ : UHME%@", [LanguageHelper getStringWithKey:@"k_15_s2_referral_id"], [dict1 objectForKey:P_USER_ID]];
        }
    }
}


- (IBAction)ButtonSavePressed:(id)sender {
    NSString *trimmedFirstName = [_txtFirstName.text stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedLastName = [_txtLastName.text stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedFirstName.length==0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_18_s2_plz_enter_first_name"]];
        return;
    }
    if (trimmedLastName.length==0){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_19_s2_plz_enter_last_name"]];
        return;
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if (_txtMobile.text.length<constantTaxiModel.min_phone_length ){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"]];
        return;
    }
    if(_txtEmail.text>0 && ![UtilityClass validateEmailWithString:_txtEmail.text]){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_14_s3_plz_enter_valid_email"]];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID          :[dict1 objectForKey:P_USER_ID],
        P_U_FNAME            : trimmedFirstName,
        P_U_LNAME             : trimmedLastName,
    }];
    if(IS_PHONE_VERIFICATION==0){
        [dict setObject:_txtMobile.text forKey:P_U_MOBILE];
    }
    [dict setObject:self.txtEmail.text forKey:P_U_EMAIL];
    if (_switchChangePass.isOn) {
        if ([self checkPasswordValidity]) {
            [self.profileScrollView setContentSize:CGSizeMake(SCREEN_WIDTH, 730)];
            [self updatePassword];
            return;
        }
        else{
            return;
        }
    }
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:UPDATE_USER_PROFILE
                  d:dict
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT,[results objectForKey:P_RESPONSE]);
            defaults_set_object(P_USER_DICT_LOGGED,[results objectForKey:P_RESPONSE]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_profile" object:nil];
            if (self.switchChangePass.isOn) {
                [[NSUserDefaults standardUserDefaults]setObject:self.txtNewPassword.text forKey:@"password"];
            }
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r10_s5_profile_updtd_success"]];
        }else{
            if(results!=nil){
                [self showWarningWithMessgae:[results objectForKey:P_MESSAGE]];
            }else{
                [Utilities handleError:error viewController:self defaultMessage:@""];
            }
        }
    }];
}



-(void)updatePassword{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if (_txtMobile.text.length<constantTaxiModel.min_phone_length  ){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"]];
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID          :[dict1 objectForKey:P_USER_ID],
        P_U_PASSWORD        : _txtOldPassword.text,
        P_NEW_PASSWORD       : _txtNewPassword.text,
        P_U_FNAME             : _txtFirstName.text,
        P_U_LNAME             : _txtLastName.text,
    }];
    
    NSString * email=[dict1 objectForKey:P_U_EMAIL];
    if(email==nil||email.length==0)   {
        [dict setObject:@"0" forKey:P_IS_SEND_EMAIL];
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:UPDATE_USER_PASSWORD
                  d:dict
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT,[results objectForKey:P_RESPONSE]);
            defaults_set_object(P_USER_DICT_LOGGED,[results objectForKey:P_RESPONSE]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_profile" object:nil];
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_c_s1_update_password"]];
        }
        else{
            if(results!=nil){
                [self showWarningWithMessgae:[results objectForKey:P_MESSAGE]];
            }else{
                [Utilities handleError:error viewController:self defaultMessage:@""];
            }
        }
    }];
}




-(void)openCheckPermission:(BOOL) isCamera{
    [UIImagePickerController obtainPermissionForMediaSourceType:isCamera?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary withSuccessHandler:^{
        UIImagePickerController *pickerNavController = [[UIImagePickerController alloc] init];
        pickerNavController.delegate = self;
        pickerNavController.allowsEditing = YES;
        pickerNavController.sourceType =isCamera?UIImagePickerControllerSourceTypeCamera: UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerNavController animated:YES completion:nil];
    } andFailure:^{
        UIAlertController *alertController= [UIAlertController
                                             alertControllerWithTitle:nil
                                             message:NSLocalizedString(@"You have disabled Photos access", nil)
                                             preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Open Settings", @"Photos access denied: open the settings app to change privacy settings")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }]
         ];
        [alertController addAction:[UIAlertAction
                                    actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j" defaultValue:@"Cancel"]
                                    style:UIAlertActionStyleCancel
                                    handler:NULL]
         ];
        [self presentViewController:alertController animated:YES completion:^{}];
    }];
}


- (IBAction)ButtonProfileTapped:(id)sender {
    
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_r18_s5_chse_img"]
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCamera= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_28_s6_camera_j"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])  {
            [self openCheckPermission:YES];
        }else{
            [self openCamerNotAlert ];
        }
    }];
    UIAlertAction *actionGallery= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_29_s6_gallery_j"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        [self openCheckPermission:NO];
    }];
    
    UIAlertAction *actionCancel= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"]
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
    }];
    [alertController addAction:actionCamera];
    [alertController addAction:actionGallery];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}



-(void) openCamerNotAlert{
    [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_32_s6_camera_permission_error"]];
}






- (IBAction)ButtonBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)checkPasswordValidity{
    
    
    if (_txtOldPassword.text.length==0) {
        [self showAlertWithMessgae:[Utilities validPasswordMessage]];
        return NO;
    }
    
    else if (_txtNewPassword.text.length<constantTaxiModel.min_password_length){
        [self showAlertWithMessgae:[Utilities validPasswordMessage]];
        return NO;
    }
    else if (_txtConfirmPassword.text.length<constantTaxiModel.min_password_length){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_23_s2_plz_enter_confirm_password"]];
    }
    else if (![_txtNewPassword.text isEqualToString:_txtConfirmPassword.text]){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_25_s2_password_not_match"]];
        return NO;
    }
    else  if (_txtMobile.text.length<constantTaxiModel.min_phone_length ){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"]];
        return NO;
    }
    return YES;
}



- (IBAction)switchChange:(UISwitch *)sender {
    
    if (sender.isOn) {
        _viewPassword.alpha=1;
        [UIView animateWithDuration:0.3 animations:^{
            [self.viewPassword setConstraintConstant:165 forAttribute:NSLayoutAttributeHeight];
        }];
    }
    else{
        [UIView animateWithDuration:0.3 animations:^{
            [self.viewPassword setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        } completion:^(BOOL finished) {
            self.viewPassword.alpha=0;
        }];
    }
}




- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    _spinnerView.hidden=NO;
    [_spinnerView startAnimating];
    UIImage *resizeImage= [Utilities imageWithImageHeight:chosenImage scaledToWidth:300 scaledToHeight:300 ];
    NSString *strImage =[Utilities encodeImageToBase64String:resizeImage ];
    NSDictionary * dict=@{@"api_key":[dict1 objectForKey:P_API_KEY],@"user_id":[dict1 objectForKey:@"user_id"],@"image_type":@"jpg",@"user_image":strImage};
    [GIC mkwerwu:UPDATE_USER_PROFILE
                                    d:dict
              cb:^(id results, NSError *error) {
        if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]) {
            NSDictionary * dictUser=[results objectForKey:P_RESPONSE];
            defaults_set_object(P_USER_DICT,dictUser );
            defaults_set_object(P_USER_DICT_LOGGED,dictUser );
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_profile" object:nil];
            NSString *profile=[dictUser objectForKey:P_PROFILE_IMAGE_PATH];
            if (profile.length>0) {
                [self.imgProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
            }
        }else{
            [Utilities handleError:error viewController:self defaultMessage:@"internet error"];
        }
        self.spinnerView.hidden=YES;
        [self.spinnerView stopAnimating];
    }];
}







-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.txtFirstName){
        [self.txtLastName becomeFirstResponder];
    }
    else if (textField == self.txtLastName){
        [self.txtMobile becomeFirstResponder];
    }
    else if (textField == self.txtMobile){
        [textField resignFirstResponder];
    }
    if (textField == self.txtOldPassword){
        [self.txtNewPassword becomeFirstResponder];
    }
    else if (textField == self.txtNewPassword){
        [self.txtConfirmPassword becomeFirstResponder];    }
    else if (textField == self.txtConfirmPassword){
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField ==self.txtMobile && textField.text.length >= constantTaxiModel.max_phone_length  && range.length == 0){
        return NO; // return NO to not change text
    }
    else{
        return YES;
    }
}


- (IBAction)onChangeCityButtonTap:(id)sender {
    //    ChangeCityViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ChangeCityViewController"];
    //    vc.dictUserRestPassword=[[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onDeleteAccountButtonTap:(id)sender {
    UIAlertController * alert = [UIAlertController   alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s7_dte_ac_alrt" ]   message: @""
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        [self deleteAccount];
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)deleteAccount{
    AskLast4DigitDeleteVC *vc=[AskLast4DigitDeleteVC openWithViewController:self];
    vc.delegate=self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)onOtpEnteredForBegin:(NSString *)otp{
    NSString * last4DigitOfUser=@"";
    NSDictionary * dictUser=defaults_object(P_USER_DICT_LOGGED);
    NSString *p_phone=[dictUser objectForKey:P_U_MOBILE];
    last4DigitOfUser=[p_phone substringFromIndex:p_phone.length-4];
    if(!([otp isEqualToString:last4DigitOfUser])){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_s7_vld_last4"  ]];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID          :[dictUser objectForKey:P_USER_ID],
        @"is_delete"   : @1
    }];
    [self showPleaseWaitLoader];
    [GIC mkwu:UPDATE_USER_PROFILE d:dict isa:NO cb:^(id results, NSError *error) {
        [self hidePleaseWaitLoader];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            // success
            defaults_remove(P_API_KEY);
            defaults_remove(TRIP_ID);
            defaults_remove(@"trip_status");
            defaults_remove(P_USER_DICT);
            defaults_remove(P_USER_DICT_LOGGED);
//            [UserProfile shared]
            UINavigationController *nav = IS_PHONE_VERIFICATION==1?[StoryBoardUtiles navigationPhone]:[StoryBoardUtiles navigationEmail];
            UIWindow *window = UIApplication.sharedApplication.delegate.window;
            window.rootViewController = nav;
            [nav setNavigationBarHidden:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
        
    }];
}
@end
