//
//  EditProfileViewController.m
//  Store_project
//
//  Created by  Appicial on 23/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "EditProfileViewController.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+LGSideMenuController.h"
#import "UploadDocumentViewController.h"
#import "StarRatingView.h"
#import "CityModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "UIViewController+AlertHelper.h"
#define kStarViewHeight 35.0f*0.75
#define kStarViewWidth 180.0f*0.75
#import "ConstantModel.h"
#import "Utilities.h"
#import "AskLast4DigitDeleteVC.h"
#import "UserProfile.h"
#import "CounrySelectionView.h"
#import "Keys.h"

@interface EditProfileViewController ()<AskLast4DigitDeleteVCDelegate>
@end

@implementation EditProfileViewController
{
    ConstantModel *constantTaxiModel;
    UILabel *_ndRatingLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    constantTaxiModel = [ConstantModel getConstantsObject];
    [self setupNewDesign];
    NSDictionary *dict = defaults_object(P_USER_DICT);
    [self getDriverProfile:[dict objectForKey:P_API_KEY] showLoader:NO];
}





-(void)setUIFiels{
    
    self.txtLastName.text = [LanguageHelper getStringWithKey:@"k_3_s2_lname"];
    self.txtFirstName.placeholder=[LanguageHelper getStringWithKey:@"k_1_s2_fname"];
    self.lblFirstName.text = [LanguageHelper getStringWithKey:@"k_1_s2_fname"];
    self.lblLastName.text = [LanguageHelper getStringWithKey:@"k_3_s2_lname"];
    self.lblEmail.text = [LanguageHelper getStringWithKey:@"k_13_s1_email"];
    self.txtEmail.placeholder=[LanguageHelper getStringWithKey:@"k_13_s1_email"];
    self.lblCity.text = [LanguageHelper getStringWithKey:@"k_18_s6_city"];
    self.lblMobileNumber.text = [LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint"];
    self.txtMobile.placeholder=[LanguageHelper getStringWithKey:@"k_9_s6_mobile_number_hint"];
    self.lblUpdatePassword.text = [LanguageHelper getStringWithKey:@"k_19_s6_update_password"];
    self.lblCurrentPassword.text = [LanguageHelper getStringWithKey:@"k_20_s6_current_password"];
    self.txtOldPassword.placeholder=[LanguageHelper getStringWithKey:@"k_20_s6_current_password"];
    self.lblNewPass.text = [LanguageHelper getStringWithKey:@"k_21_s6_new_password"];
    self.txtNewPassword.placeholder=[LanguageHelper getStringWithKey:@"k_21_s6_new_password"];
    self.lblConfirmPassword.text = [LanguageHelper getStringWithKey:@"k_13_s2_confirm_password"];
    self.txtConfirmPassword.placeholder=[LanguageHelper getStringWithKey:@"k_13_s2_confirm_password"];
//    self.lblCityName.text = [LanguageHelper getStringWithKey:@"k_18_s6_city"];
    [self.btnSave setTitle: [LanguageHelper getStringWithKey:@"k_34_s6_save"]   forState:UIControlStateNormal];
    [self.btnUploadDocument setTitle: [LanguageHelper getStringWithKey:@"k_3_s6_upload_doc"]   forState:UIControlStateNormal];
//    [self.btnBack setBackgroundImage:[UIImage imageNamed:@"backward-arrow"] forState:UIControlStateNormal];
    self.lblBankInfo.text=[LanguageHelper getStringWithKey:@"k_2_s2_bank_info"];
    
    
    self.lblBankName.text=[LanguageHelper getStringWithKey:@"k_2_s2_bank_name"];
    self.txtBankName.placeholder=[LanguageHelper getStringWithKey:@"k_2_s2_bank_name_hint"];
    self.lblUserName.text=[LanguageHelper getStringWithKey:@"k_2_s2_bank_user_name"];
    self.txtUserName.placeholder=[LanguageHelper getStringWithKey:@"k_2_s2_bank_user_name_hint"];
    self.lblAccountNumber.text=[LanguageHelper getStringWithKey:@"k_2_s2_bank_account_number"];
    self.txtAccountNumber.placeholder=[LanguageHelper getStringWithKey:@"k_2_s2_bank_account_number_hint"];
    self.lblIFSCode.text=[LanguageHelper getStringWithKey:@"k_2_s2_bank_ifsc_code"];
    self.txtIfscCode.placeholder=[LanguageHelper getStringWithKey:@"k_2_s2_bank_ifsc_code_hint"];

    [self.btnDeleteAccount setTitle: [LanguageHelper getStringWithKey:@"k_s7_dte_ac" ]   forState:UIControlStateNormal];
}


-(void)localizedString{
}

-(void)setThemeConstants{
   
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
    [_btnSave.titleLabel setFont:FONTS_THEME_REGULAR(18)];
    [_txtEmail setFont:FONTS_THEME_REGULAR(14)];
    [_txtFirstName setFont:FONTS_THEME_REGULAR(14)];
    [_txtLastName setFont:FONTS_THEME_REGULAR(14)];
    [_txtMobile setFont:FONTS_THEME_REGULAR(14)];
     [_txtOldPassword setFont:FONTS_THEME_REGULAR(14)];
     [_txtNewPassword setFont:FONTS_THEME_REGULAR(14)];
     [_txtConfirmPassword setFont:FONTS_THEME_REGULAR(14)];
    [_lblChangePassword setFont:FONTS_THEME_REGULAR(14)];
   [_btnUploadDocument.titleLabel setFont:FONTS_THEME_REGULAR(17)];
}

#pragma mark - New design (match rider Mi perfil + keep Upload documents)
- (void)setupNewDesign {
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    NSDictionary *ud = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    if (!ud) ud = @{};

    UIColor *darkText  = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    UIColor *grayText  = [UIColor colorWithRed:0.502f green:0.502f blue:0.502f alpha:1.0f];
    UIColor *fieldBg   = [UIColor colorWithRed:0.945f green:0.945f blue:0.945f alpha:1.0f];
    UIColor *sepColor  = [UIColor colorWithRed:0.906f green:0.906f blue:0.906f alpha:1.0f];
    UIColor *deleteBg  = [UIColor colorWithRed:1.0f green:0.933f blue:0.933f alpha:1.0f];
    UIColor *deleteRed = [UIColor colorWithRed:0.941f green:0.169f blue:0.169f alpha:1.0f];
    UIColor *yellow    = [UIColor colorNamed:@"app_theame"] ?: [UIColor colorWithRed:0.922f green:0.710f blue:0.094f alpha:1.0f];

    self.view.backgroundColor = [UIColor whiteColor];
    for (UIView *v in self.view.subviews) v.hidden = YES;

    CGFloat topInset = 0;
    if (@available(iOS 11.0, *)) {
        topInset = self.view.safeAreaInsets.top;
    }
    if (topInset < 1) {
        topInset = UIApplication.sharedApplication.statusBarFrame.size.height;
    }
    if (topInset < 20) topInset = 20;
    CGFloat barH = topInset + 56.0f;

    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, barH)];
    topBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topBar];

    // Main scroll view (starts below the fixed header)
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, barH, sw, sh - barH)];
    sv.backgroundColor = [UIColor whiteColor];
    sv.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        sv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:sv];
    self.profileScrollView = sv;

    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, 1000)];
    [sv addSubview:cv];

    CGFloat y = 0;

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(16, topInset + 6, 44, 44);
    backBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    backBtn.layer.cornerRadius = 22;
    backBtn.clipsToBounds = YES;
    UIImage *chevronImg = [[UIImage systemImageNamed:@"chevron.left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backBtn setImage:chevronImg forState:UIControlStateNormal];
    backBtn.tintColor = darkText;
    [backBtn addTarget:self action:@selector(ButtonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = [LanguageHelper getStringWithKey:@"k_24_s6_mi_perfil" defaultValue:@"Mi perfil"];
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = darkText;
    [titleLbl sizeToFit];
    titleLbl.center = CGPointMake(sw / 2.0f, topInset + 28.0f);
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
    photoIV.clipsToBounds = YES;
    photoIV.contentMode = UIViewContentModeScaleAspectFill;
    photoIV.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    photoIV.image = [UIImage imageNamed:@"Profile Icon Crop Image"];
    [photoWrap addSubview:photoIV];
    self.profileImage = photoIV;

    UIView *badge = [[UIView alloc] initWithFrame:CGRectMake(photoSize - 30, photoSize - 30, 32, 32)];
    badge.backgroundColor = [UIColor colorWithRed:0.18f green:0.18f blue:0.22f alpha:1];
    badge.layer.cornerRadius = 16;
    badge.clipsToBounds = YES;
    UIImageView *pencilIV = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 18, 18)];
    pencilIV.image = [[UIImage systemImageNamed:@"pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    pencilIV.tintColor = [UIColor whiteColor];
    pencilIV.contentMode = UIViewContentModeScaleAspectFit;
    [badge addSubview:pencilIV];
    [photoWrap addSubview:badge];

    UIButton *photoTapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoTapBtn.frame = CGRectMake(0, 0, photoSize, photoSize);
    [photoTapBtn addTarget:self action:@selector(ButtonProfileTapped:) forControlEvents:UIControlEventTouchUpInside];
    [photoWrap addSubview:photoTapBtn];

    y += photoSize + 16;

    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, y, sw - 32, 28)];
    nameLbl.font = FONTS_NOTO_BOLD(20);
    nameLbl.textColor = darkText;
    nameLbl.textAlignment = NSTextAlignmentCenter;
    [cv addSubview:nameLbl];
    self.userNamelbl = nameLbl;
    y += 28 + 6;

    UILabel *phoneLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, y, sw, 20)];
    phoneLbl.font = FONTS_NOTO_REGULAR(14);
    phoneLbl.textColor = grayText;
    phoneLbl.textAlignment = NSTextAlignmentCenter;
    [cv addSubview:phoneLbl];
    self.userMobilelbl = phoneLbl;
    y += 20 + 8;

    NSString *ratingStr = [ud objectForKey:@"d_rating"];
    float rating = ratingStr ? [ratingStr floatValue] : 0.0f;
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
    _ndRatingLabel = ratingLbl;
    y += ratingLbl.frame.size.height + 28;

    UIView *div1 = [[UIView alloc] initWithFrame:CGRectMake(0, y, sw, 1)];
    div1.backgroundColor = sepColor;
    [cv addSubview:div1];
    y += 1 + 24;

    CGFloat fH = 56.0f, fX = 16.0f, fW = sw - 32.0f;

    UIView *fnBox = [[UIView alloc] initWithFrame:CGRectMake(fX, y, fW, fH)];
    fnBox.backgroundColor = fieldBg;
    fnBox.layer.cornerRadius = 14;
    [cv addSubview:fnBox];
    UITextField *fnTf = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, fW - 32, fH)];
    fnTf.font = FONTS_NOTO_REGULAR(16);
    fnTf.textColor = darkText;
    fnTf.delegate = self;
    fnTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_1_s2_fname" defaultValue:@"Nombre"] attributes:@{ NSForegroundColorAttributeName: grayText, NSFontAttributeName: FONTS_NOTO_REGULAR(16) }];
    [fnBox addSubview:fnTf];
    self.txtFirstName = fnTf;
    y += fH + 12;

    UIView *lnBox = [[UIView alloc] initWithFrame:CGRectMake(fX, y, fW, fH)];
    lnBox.backgroundColor = fieldBg;
    lnBox.layer.cornerRadius = 14;
    [cv addSubview:lnBox];
    UITextField *lnTf = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, fW - 32, fH)];
    lnTf.font = FONTS_NOTO_REGULAR(16);
    lnTf.textColor = darkText;
    lnTf.delegate = self;
    lnTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_3_s2_lname" defaultValue:@"Apellido"] attributes:@{ NSForegroundColorAttributeName: grayText, NSFontAttributeName: FONTS_NOTO_REGULAR(16) }];
    [lnBox addSubview:lnTf];
    self.txtLastName = lnTf;
    y += fH + 12;

    UIView *emBox = [[UIView alloc] initWithFrame:CGRectMake(fX, y, fW, fH)];
    emBox.backgroundColor = fieldBg;
    emBox.layer.cornerRadius = 14;
    [cv addSubview:emBox];
    UITextField *emTf = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, fW - 32, fH)];
    emTf.font = FONTS_NOTO_REGULAR(16);
    emTf.textColor = darkText;
    emTf.keyboardType = UIKeyboardTypeEmailAddress;
    emTf.delegate = self;
    emTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_13_s1_email" defaultValue:@"Correo electrónico"] attributes:@{ NSForegroundColorAttributeName: grayText, NSFontAttributeName: FONTS_NOTO_REGULAR(16) }];
    [emBox addSubview:emTf];
    self.txtEmail = emTf;
    y += fH + 12;

    NSString *rawCode = [ud objectForKey:P_C_CODE];
    if (![rawCode isKindOfClass:[NSString class]]) rawCode = nil;
    NSString *dialCode = (rawCode.length > 0) ? [NSString stringWithFormat:@"+%@", rawCode] : @"+58";
    NSDictionary *cDict = [CounrySelectionView getCurrentCountryDictWithDialCode:dialCode] ?: [CounrySelectionView getCurrentCountryDictWithCountryCode:@"VE"];
    NSString *flagEmoji = [CounrySelectionView flagEmojiForCode:cDict[@"code"] ?: @"VE"];

    UIView *phBox = [[UIView alloc] initWithFrame:CGRectMake(fX, y, fW, fH)];
    phBox.backgroundColor = fieldBg;
    phBox.layer.cornerRadius = 14;
    phBox.clipsToBounds = YES;
    [cv addSubview:phBox];

    UIButton *countryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    countryBtn.frame = CGRectMake(0, 0, 96, fH);
    [countryBtn setTitle:[NSString stringWithFormat:@"%@  %@  ▾", flagEmoji, dialCode] forState:UIControlStateNormal];
    [countryBtn setTitleColor:darkText forState:UIControlStateNormal];
    countryBtn.titleLabel.font = FONTS_NOTO_REGULAR(14);
    [phBox addSubview:countryBtn];

    UIView *phDivider = [[UIView alloc] initWithFrame:CGRectMake(96, 16, 1, fH - 32)];
    phDivider.backgroundColor = sepColor;
    [phBox addSubview:phDivider];

    UITextField *phTf = [[UITextField alloc] initWithFrame:CGRectMake(108, 0, fW - 120, fH)];
    phTf.font = FONTS_NOTO_REGULAR(16);
    phTf.textColor = darkText;
    phTf.keyboardType = UIKeyboardTypePhonePad;
    phTf.delegate = self;
    phTf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint" defaultValue:@"Número de teléfono"] attributes:@{ NSForegroundColorAttributeName: grayText, NSFontAttributeName: FONTS_NOTO_REGULAR(16) }];
    [phBox addSubview:phTf];
    self.txtMobile = phTf;
    y += fH + 24;

    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(fX, y, fW, 56);
    saveBtn.backgroundColor = yellow;
    saveBtn.layer.cornerRadius = 14;
    saveBtn.clipsToBounds = YES;
    saveBtn.titleLabel.font = FONTS_NOTO_BOLD(17);
    [saveBtn setTitle:[LanguageHelper getStringWithKey:@"k_34_s6_save" defaultValue:@"Guardar"] forState:UIControlStateNormal];
    [saveBtn setTitleColor:darkText forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(ButtonSavePressed:) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:saveBtn];
    self.btnSave = saveBtn;
    y += 56 + 12;

    UIButton *uploadDocBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    uploadDocBtn.frame = CGRectMake(fX, y, fW, 56);
    uploadDocBtn.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    uploadDocBtn.layer.cornerRadius = 14;
    uploadDocBtn.clipsToBounds = YES;
    uploadDocBtn.titleLabel.font = FONTS_NOTO_BOLD(17);
    [uploadDocBtn setTitle:[LanguageHelper getStringWithKey:@"k_3_s6_upload_doc" defaultValue:@"Subir documentos"] forState:UIControlStateNormal];
    [uploadDocBtn setTitleColor:darkText forState:UIControlStateNormal];
    [uploadDocBtn addTarget:self action:@selector(ButtonUploadDocuments:) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:uploadDocBtn];
    self.btnUploadDocument = uploadDocBtn;
    y += 56 + 28;

    UIView *div2 = [[UIView alloc] initWithFrame:CGRectMake(0, y, sw, 1)];
    div2.backgroundColor = sepColor;
    [cv addSubview:div2];
    y += 1 + 24;

    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(fX, y, fW, 56);
    deleteBtn.backgroundColor = deleteBg;
    deleteBtn.layer.cornerRadius = 14;
    deleteBtn.clipsToBounds = YES;
    NSMutableAttributedString *delAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ", [LanguageHelper getStringWithKey:@"k_s7_dte_ac" defaultValue:@"Eliminar mi cuenta"]] attributes:@{ NSFontAttributeName: FONTS_NOTO_REGULAR(16), NSForegroundColorAttributeName: deleteRed }];
    NSTextAttachment *trashAtt = [[NSTextAttachment alloc] init];
    trashAtt.image = [UIImage imageNamed:@"ic_trash"];
    [trashAtt setBounds:CGRectMake(0, -3, 18, 18)];
    [delAttr appendAttributedString:[NSAttributedString attributedStringWithAttachment:trashAtt]];
    [deleteBtn setAttributedTitle:delAttr forState:UIControlStateNormal];
    deleteBtn.tintColor = deleteRed;
    [deleteBtn addTarget:self action:@selector(onDeleteAccountButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [cv addSubview:deleteBtn];
    self.btnDeleteAccount = deleteBtn;
    y += 56 + 40;

    cv.frame = CGRectMake(0, 0, sw, y);
    sv.contentSize = CGSizeMake(sw, y);
    if (@available(iOS 11.0, *)) {
        sv.contentInset = UIEdgeInsetsMake(0, 0, self.view.safeAreaInsets.bottom, 0);
    }

    [self setData];

    NSString *storedPhone = self.txtMobile.text;
    if (dialCode.length > 0 && [storedPhone hasPrefix:dialCode]) {
        self.txtMobile.text = [storedPhone substringFromIndex:dialCode.length];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:StoryBoardUtiles.UPLOAD_DOCUMENT]) {
        UploadDocumentViewController *view =(UploadDocumentViewController *)[segue destinationViewController];
        view.isfromProfile = YES;
    }
}



-(void)setupTextField:(UITextField*)textField{
    [self setTextFieldPlaceholderColor:textField];
    textField.delegate=self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setData];
    
    
}

-(void)setData{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    if (!dict1) return;

    if (self.lblCityName) {
        CityModel *cityModel = [CityModel getCityByCityId:[UserProfile shared].cityID];
        if (cityModel) self.lblCityName.text = cityModel.city_name;
    }
    if (self.btnUploadDocument) {
        [self.btnUploadDocument setTitle:[LanguageHelper getStringWithKey:@"k_1_s7_update_documents"] forState:UIControlStateNormal];
        [self.btnUploadDocument setTitle:[LanguageHelper getStringWithKey:@"k_3_s6_upload_doc"] forState:UIControlStateNormal];
    }

    if (IS_PHONE_VERIFICATION == 1) {
        self.txtEmail.enabled = YES;
        self.txtMobile.enabled = NO;
        self.txtEmail.text = [dict1 objectForKey:P_EMAIL];
        _txtMobile.text = [NSString stringWithFormat:@"+%@%@", isEmpty([dict1 objectForKey:P_C_CODE]), [dict1 objectForKey:P_MOBILE]];
    } else {
        self.txtEmail.enabled = NO;
        self.txtMobile.enabled = YES;
        self.txtEmail.text = [dict1 objectForKey:P_EMAIL];
        _txtMobile.text = [dict1 objectForKey:P_MOBILE] ?: @"";
    }

    _txtFirstName.text = [dict1 objectForKey:P_FNAME] ?: @"";
    _txtLastName.text = [dict1 objectForKey:P_LNAME] ?: @"";
    _userNamelbl.text = [NSString stringWithFormat:@"%@ %@", [dict1 objectForKey:P_FNAME] ?: @"", [dict1 objectForKey:P_LNAME] ?: @""];
    self.txtLastName.text = [dict1 objectForKey:P_LNAME] ?: @"";

    if (self.userMobilelbl) {
        if (IS_PHONE_VERIFICATION == 1) {
            self.userMobilelbl.text = [NSString stringWithFormat:@"+%@ %@", isEmpty([dict1 objectForKey:P_C_CODE]), [dict1 objectForKey:P_MOBILE] ?: @""];
        } else {
            self.userMobilelbl.text = [dict1 objectForKey:P_EMAIL] ?: @"";
        }
        self.userMobilelbl.hidden = NO;
    }

    if (_ndRatingLabel) {
        NSString *rStr = [dict1 objectForKey:@"d_rating"];
        float r = rStr ? [rStr floatValue] : 0.0f;
        NSString *ratingVal = [NSString stringWithFormat:@"%.1f", r > 0 ? r : 0.0f];
        UIColor *starYellow = [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
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
            CGFloat cap = _ndRatingLabel.font.capHeight;
            CGFloat size = cap * 1.5;
            att.bounds = CGRectMake(0, (cap - size) / 2.0, size, size);
            NSMutableAttributedString *full = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
            [full appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", ratingVal] attributes:@{NSFontAttributeName: _ndRatingLabel.font, NSForegroundColorAttributeName: starYellow}]];
            _ndRatingLabel.attributedText = full;
        } else {
            _ndRatingLabel.text = [NSString stringWithFormat:@"★ %@", ratingVal];
            _ndRatingLabel.textColor = starYellow;
        }
    }

    NSString *profile = [dict1 objectForKey:P_DRIVER_PROFILE_IMAGE_PATH];
    if (profile.length>0) {
        [self.profileImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
          
    }
    
    // Bank Info
    NSString *bank_info=[dict1 objectForKey:@"d_bank_info"];
    if (bank_info)
    {
        NSError *jsonError;
        NSData *objectData = [bank_info dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        if(json)
        {
            self.txtBankName.text=[json objectForKey:@"bank_name"];
            self.txtUserName.text=[json objectForKey:@"user_name"];
            self.txtAccountNumber.text=[json objectForKey:@"account_number"];
            self.txtIfscCode.text=[json objectForKey:@"ifsc_code"];
        }
    }
    
}


- (IBAction)ButtonSavePressed:(id)sender {
    
    NSString *trimmedFirstName = [_txtFirstName.text stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedLastName = [self.txtLastName.text stringByTrimmingCharactersInSet:
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
    
    if  (_txtMobile.text.length<constantTaxiModel.min_phone_length ){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r6_s2_enter_mob_no"]];
        return;
    }
    
    if(_txtEmail.text>0 && ![UtilityClass validateEmailWithString:_txtEmail.text]){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_14_s3_plz_enter_valid_email"]];
        return;
    }
    else  if (_txtMobile.text.length<6 ){
        [self showAlert:[LanguageHelper getStringWithKey:@"k_r6_s2_enter_mob_no"]  title:[LanguageHelper getStringWithKey:@"k_33_s7_alert"]];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        P_FNAME            : trimmedFirstName,
        P_LNAME           : trimmedLastName,
    }];
    
    if(IS_PHONE_VERIFICATION==0){
        [dict setObject:_txtMobile.text forKey:P_MOBILE];
    }
    [dict setObject:self.txtEmail.text forKey:P_EMAIL];
    if (self.switchBankInfo.isOn) {
        if(self.txtBankName.text.length==0) {
            [self showAlert:[LanguageHelper getStringWithKey:@"k_2_s2_bank_name_hint"]  title:[LanguageHelper getStringWithKey:@"k_33_s7_alert"]];
            return;
        }
        if(self.txtUserName.text.length==0){
            [self showAlert:[LanguageHelper getStringWithKey:@"k_2_s2_bank_user_name_hint"]  title:[LanguageHelper getStringWithKey:@"k_33_s7_alert"]];
            return;
        }
        if(self.txtAccountNumber.text.length==0){
            [self showAlert:[LanguageHelper getStringWithKey:@"k_2_s2_bank_account_number_hint"]  title:[LanguageHelper getStringWithKey:@"k_33_s7_alert"]];
            return;
        }
        if(self.txtIfscCode.text.length==0) {
            [self showAlert:[LanguageHelper getStringWithKey:@"k_2_s2_bank_ifsc_code_hint"]  title:[LanguageHelper getStringWithKey:@"k_33_s7_alert"]];
            return;
        }
        
        NSMutableDictionary * dictBankInfo =[[NSMutableDictionary alloc] init];
        [dictBankInfo setObject:self.txtBankName.text forKey:@"bank_name"];
        [dictBankInfo setObject:self.txtUserName.text forKey:@"user_name"];
        [dictBankInfo setObject:self.txtAccountNumber.text forKey:@"account_number"];
        [dictBankInfo setObject:self.txtIfscCode.text forKey:@"ifsc_code"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictBankInfo
                                                           options: 0
                                                             error:&error];
        
        if (! jsonData) {
            NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        } else {
            NSString * dictjsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [dict setObject:isEmpty(dictjsonString) forKey:@"d_bank_info"];
        }
    }
    if (_switchChangePass.isOn) {
        if ([self checkPasswordValidity]) {
            [self updatePassword];
            return;
        }
        else{
            return;
        }
    }
    NSDictionary *dictLogged = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    [dict setObject:[dictLogged objectForKey:P_USER_ID] forKey:@"usr_ref_id"];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:UPDATE_DRIVER_PROFILE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT,[results objectForKey:P_RESPONSE] );
            [self setData];
            if (self.switchChangePass.isOn) {
                [[NSUserDefaults standardUserDefaults]setObject:self.txtNewPassword.text forKey:@"password"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_profile" object:nil];
            [self showAlert:@"" title:[LanguageHelper getStringWithKey:@"k_24_s6_profile_updated_sucessfully"]];
        }
    }];
}





-(void)updatePassword{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if (_txtMobile.text.length<constantTaxiModel.min_phone_length){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r6_s2_enter_mob_no"]];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID           :[dict1 objectForKey:P_DRIVER_ID],
        P_PASSWORD           : _txtOldPassword.text,
        P_NEW_PASSWORD        : _txtNewPassword.text,
        P_FNAME               : _txtFirstName.text,
        P_LNAME               : _txtLastName.text,
    }];
    
    NSString * email=[dict1 objectForKey:P_EMAIL];
    if(email==nil||email.length==0){
        [dict setObject:@"0" forKey:P_IS_SEND_EMAIL];
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:UPDATE_DRIVER_PASSWORD
                  d:dict
              cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT,[results objectForKey:P_RESPONSE] );
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_profile" object:nil];
            [self showAlert:@"" title:[LanguageHelper getStringWithKey:@"k_c_s1_update_password"]];
        }
        else{
            if(results!=nil){
                [self showAlert:@"" title:[LanguageHelper getStringWithKey:[results objectForKey:P_MESSAGE]]];
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
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                    
                }];
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
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
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
    [self showAlert:@"" title:[LanguageHelper getStringWithKey:@"k_32_s6_camera_permission_error"]];
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
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_13_s2_confirm_password"]];
      
    }
    else if (![_txtNewPassword.text isEqualToString:_txtConfirmPassword.text]){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_25_s2_password_not_match"]];
        return NO;
    }
    return YES;
}




- (IBAction)switchChange:(UISwitch *)sender {
    if (sender.isOn){
        [self.viewPassword setConstraintConstant:165 forAttribute:NSLayoutAttributeHeight];
    }else{
        [self.viewPassword setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    }
}




- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *resizeImage= [Utilities imageWithImageHeight:chosenImage scaledToWidth:300 scaledToHeight:300 ];
    NSString *strImage =[Utilities encodeImageToBase64String:resizeImage ];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSDictionary * dictM=@{@"api_key":[dict1 objectForKey:P_API_KEY],P_DRIVER_ID:[dict1 objectForKey:P_DRIVER_ID],@"image_type":@"jpg",@"driver_image":strImage};
    NSMutableDictionary *dict=[dictM mutableCopy];
    NSDictionary *dictLogged = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    [dict setObject:[dictLogged objectForKey:P_USER_ID] forKey:@"usr_ref_id"];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:UPDATE_DRIVER_PROFILE
                  d:dict
      isa:NO 
           cb:^(id results, NSError *error) {
                      if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"])  {
                          defaults_set_object(P_USER_DICT,[results objectForKey:P_RESPONSE] );
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"change_profile" object:nil];
                          NSString *profile=[[results objectForKey:P_RESPONSE] objectForKey:P_DRIVER_PROFILE_IMAGE_PATH];
                          if (profile.length>0) {
                              [self.profileImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
                          }
                      }
                      [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                  }];
    
}
- (IBAction)onEditImageButtonTap:(id)sender {
    [self ButtonProfileTapped:sender];
}


-(NSString *)encodeImageToBase64String:(UIImage *)image
{
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


- (IBAction)ButtonUploadDocuments:(id)sender {
    UploadDocumentViewController *vc = (UploadDocumentViewController *)[StoryBoardUtiles viewContollerWithIdentifier:StoryBoardUtiles.UPLOAD_DOCUMENT name:StoryBoardUtiles.STORYBOARD_SIGNUP];
    vc.isfromProfile = YES;
    [self.navigationController pushViewController: vc animated:NO];
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
            
            [self.txtConfirmPassword becomeFirstResponder];
            
        }
        else if (textField == self.txtConfirmPassword){
            
            [textField resignFirstResponder];
        }
        
        return YES;
        
    }

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField ==self.txtMobile && textField.text.length >= constantTaxiModel.max_phone_length && range.length == 0){
        return NO; // return NO to not change text
    }
    else{
        return YES;
    }
}

-(void)getDriverProfile:(NSString *)apikey showLoader:(BOOL)showLoader{
    if (apikey == nil) return;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ P_API_KEY : apikey }];
    if (showLoader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:GET_DRIVER_PROFILE
          d:dict
        isa:NO
         cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            NSDictionary *dictDriver;
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]) {
                dictDriver = [results objectForKey:P_RESPONSE];
            } else {
                dictDriver = [[results objectForKey:P_RESPONSE] objectAtIndex:0];
            }
            defaults_set_object(P_USER_DICT, dictDriver);
            [self setData];
        }
        if (!_ndRatingLabel) [self showRating];
        if (showLoader) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
    }];
}


-(void)showRating{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSString *rating = [dict1 objectForKey:@"d_rating"];
    StarRatingView* starViewNoLabel = [[StarRatingView alloc]initWithFrame:CGRectMake(self.viewStarRating.frame.size.width/2-kStarViewWidth/2, 0, kStarViewWidth, kStarViewHeight) andRating:[rating floatValue]*20 withLabel:NO animated:YES];
    [starViewNoLabel setUserInteractionEnabled:NO];
    [self.viewStarRating addSubview:starViewNoLabel];
}



- (IBAction)onBankInfoSwitchChnaged:(UISwitch *)sender {
    if (sender.isOn) {
        [self.viewBankInfoInput setConstraintConstant:215 forAttribute:NSLayoutAttributeHeight];
    }else  {
        [self.viewBankInfoInput setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    }
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
