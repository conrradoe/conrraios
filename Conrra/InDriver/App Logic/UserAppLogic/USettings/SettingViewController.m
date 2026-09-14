//
//  SettingViewController.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 07/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "CounrySelectionView.h"
#import "ConstantModel.h"
#import "Utilities.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import <ContactsUI/ContactsUI.h>
#import "LanguageHelper.h"

@interface SettingViewController ()<MFMailComposeViewControllerDelegate,
                                    MFMessageComposeViewControllerDelegate,
                                    CNContactPickerDelegate,
                                    CounrySelectionViewDelegate,
                                    UITextFieldDelegate,
                                    UITableViewDelegate,
                                    UITableViewDataSource>
@end

@implementation SettingViewController
{
    ConstantModel *constantTaxiModel;
    int contactNumber;
    NSDictionary *countrySelected1;
    int contactOneSelectedIndex;

    // Pago móvil
    UILabel      *_ndPmCountryCodeLabel;
    UITextField  *_ndPmPhoneField;
    UILabel      *_ndBankLabel;
    UILabel      *_ndDocTypeLabel;
    UITextField  *_ndDocNumField;
    NSDictionary *_ndPmCountrySelected;
    NSString     *_ndSelectedBankName;
    NSString     *_ndSelectedDocType;

    // Bank selection sheet
    UIView        *_bankOverlay;
    UIView        *_bankSheet;
    UITableView   *_bankTableView;
    UITextField   *_bankSearchField;
    NSArray       *_allBanks;
    NSArray       *_filteredBanks;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    contactOneSelectedIndex = 0;
    contactNumber = 0;
    constantTaxiModel = [ConstantModel getConstantsObject];

    [self setupNewDesign];

    // Initialize country code pickers with current locale
    self.lblCountryCode1.attributedText = [CounrySelectionView getCurrentCountry];
    countrySelected1 = [CounrySelectionView getCurrentCountryDict];

    _ndPmCountryCodeLabel.attributedText = [CounrySelectionView getCurrentCountry];
    _ndPmCountrySelected = [CounrySelectionView getCurrentCountryDict];

    [self setContacts];
    [self loadPagoMovilData];
}

#pragma mark - New Design

- (void)setupNewDesign {
    for (UIView *v in [self.view.subviews copy]) { v.hidden = YES; }

    self.view.backgroundColor = [UIColor whiteColor];
    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;

    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:header];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    backBtn.layer.cornerRadius = 20;
    backBtn.tintColor = textMain;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightMedium];
        [backBtn setImage:[[UIImage systemImageNamed:@"chevron.left" withConfiguration:cfg]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    } else {
        [backBtn setTitle:@"‹" forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:26];
    }
    [backBtn addTarget:self action:@selector(ButtonBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = @"Contacto SOS";
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = textMain;
    [header addSubview:titleLbl];

    UIView *hSep = [[UIView alloc] init];
    hSep.translatesAutoresizingMaskIntoConstraints = NO;
    hSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [header addSubview:hSep];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:64],
        [backBtn.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [backBtn.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [backBtn.widthAnchor constraintEqualToConstant:40],
        [backBtn.heightAnchor constraintEqualToConstant:40],
        [titleLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLbl.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [hSep.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [hSep.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [hSep.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [hSep.heightAnchor constraintEqualToConstant:1],
    ]];

    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.backgroundColor = [UIColor clearColor];
    scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:content];

    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:header.bottomAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [content.topAnchor constraintEqualToAnchor:scroll.topAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scroll.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:scroll.trailingAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor],
        [content.widthAnchor constraintEqualToAnchor:scroll.widthAnchor],
    ]];

    CGFloat pad = 16.0;

    UIView *card1 = [self makeCard];
    [content addSubview:card1];

    // Card 1 header row
    UILabel *sosKey = [[UILabel alloc] init];
    sosKey.translatesAutoresizingMaskIntoConstraints = NO;
    sosKey.text = @"CONTACTO DE EMERGENCIA:";
    sosKey.font = FONTS_NOTO_BOLD(13);
    sosKey.textColor = textMain;
    [card1 addSubview:sosKey];

    UILabel *sosBadge = [[UILabel alloc] init];
    sosBadge.translatesAutoresizingMaskIntoConstraints = NO;
    sosBadge.text = @"SOS";
    sosBadge.font = FONTS_NOTO_BOLD(14);
    sosBadge.textColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    [card1 addSubview:sosBadge];

    UIView *card1Sep = [self makeSeparator];
    [card1 addSubview:card1Sep];

    // Name field
    UITextField *nameField = [self makeTextField:@"Nombre" keyboard:UIKeyboardTypeDefault];
    self.txtContactName = nameField;
    [card1 addSubview:nameField];

    // Phone row (contact 1)
    UILabel *ccLabel1 = nil;
    UITextField *phoneField1 = nil;
    UIView *phoneRow1 = [self buildPhoneRowWithCCLabel:&ccLabel1
                                           phoneField:&phoneField1
                                          placeholder:[LanguageHelper getStringWithKey:@"k_2_s1_mobile_number_hint" defaultValue:@"Número de teléfono"]
                                         countryAction:@selector(onCountryCodeOneButtonTap:)];
    self.lblCountryCode1 = ccLabel1;
    self.txtContact1 = phoneField1;
    [card1 addSubview:phoneRow1];

    [NSLayoutConstraint activateConstraints:@[
        [card1.topAnchor constraintEqualToAnchor:content.topAnchor constant:pad],
        [card1.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [card1.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],

        [sosKey.topAnchor constraintEqualToAnchor:card1.topAnchor constant:20],
        [sosKey.leadingAnchor constraintEqualToAnchor:card1.leadingAnchor constant:pad],
        [sosBadge.centerYAnchor constraintEqualToAnchor:sosKey.centerYAnchor],
        [sosBadge.trailingAnchor constraintEqualToAnchor:card1.trailingAnchor constant:-pad],

        [card1Sep.topAnchor constraintEqualToAnchor:sosKey.bottomAnchor constant:14],
        [card1Sep.leadingAnchor constraintEqualToAnchor:card1.leadingAnchor constant:pad],
        [card1Sep.trailingAnchor constraintEqualToAnchor:card1.trailingAnchor constant:-pad],

        [nameField.topAnchor constraintEqualToAnchor:card1Sep.bottomAnchor constant:14],
        [nameField.leadingAnchor constraintEqualToAnchor:card1.leadingAnchor constant:pad],
        [nameField.trailingAnchor constraintEqualToAnchor:card1.trailingAnchor constant:-pad],
        [nameField.heightAnchor constraintEqualToConstant:56],

        [phoneRow1.topAnchor constraintEqualToAnchor:nameField.bottomAnchor constant:10],
        [phoneRow1.leadingAnchor constraintEqualToAnchor:card1.leadingAnchor constant:pad],
        [phoneRow1.trailingAnchor constraintEqualToAnchor:card1.trailingAnchor constant:-pad],
        [phoneRow1.heightAnchor constraintEqualToConstant:56],
        [phoneRow1.bottomAnchor constraintEqualToAnchor:card1.bottomAnchor constant:-20],
    ]];

    UIView *card2 = [self makeCard];
    [content addSubview:card2];

    UILabel *pmTitle = [[UILabel alloc] init];
    pmTitle.translatesAutoresizingMaskIntoConstraints = NO;
    pmTitle.text = [LanguageHelper getStringWithKey:@"k_s10_mobile_payment_data" defaultValue:@"DATOS PARA PAGO MÓVIL"];
    pmTitle.font = FONTS_NOTO_BOLD(13);
    pmTitle.textColor = textMain;
    [card2 addSubview:pmTitle];

    UILabel *pmSubtitle = [[UILabel alloc] init];
    pmSubtitle.translatesAutoresizingMaskIntoConstraints = NO;
    pmSubtitle.text = [LanguageHelper getStringWithKey:@"k_s10_data_shown_to_passenger" defaultValue:@"Estos datos serán mostrados a tu pasajero"];
    pmSubtitle.font = FONTS_NOTO_REGULAR(12);
    pmSubtitle.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [card2 addSubview:pmSubtitle];

    // Seleccione Banco button
    UILabel *bankLabel = nil;
    UIView *bancoRow = [self buildSelectorRow:[LanguageHelper getStringWithKey:@"k_s10_select_bank" defaultValue:@"Seleccione Banco"]
                                        label:&bankLabel
                                       action:@selector(onBancoTapped)];
    _ndBankLabel = bankLabel;
    [card2 addSubview:bancoRow];

    // Phone row (pago móvil)
    UILabel *ccLabelPM = nil;
    UITextField *phoneFieldPM = nil;
    UIView *phoneRowPM = [self buildPhoneRowWithCCLabel:&ccLabelPM
                                            phoneField:&phoneFieldPM
                                           placeholder:[LanguageHelper getStringWithKey:@"k_s10_phone_example" defaultValue:@"Ej. 4129876543"]
                                          countryAction:@selector(onCountryCodePMTap:)];
    _ndPmCountryCodeLabel = ccLabelPM;
    _ndPmPhoneField = phoneFieldPM;
    [card2 addSubview:phoneRowPM];

    // Tipo de Documento ID button
    UILabel *docTypeLabel = nil;
    UIView *docTypeRow = [self buildSelectorRow:[LanguageHelper getStringWithKey:@"k_s10_id_doc_type" defaultValue:@"Tipo de Documento ID"]
                                          label:&docTypeLabel
                                         action:@selector(onTipoDocTapped)];
    _ndDocTypeLabel = docTypeLabel;
    [card2 addSubview:docTypeRow];

    // Document number field
    UITextField *docNumField = [self makeTextField:[LanguageHelper getStringWithKey:@"k_s10_doc_number_example" defaultValue:@"Ej. 15800645"] keyboard:UIKeyboardTypeNumberPad];
    _ndDocNumField = docNumField;
    [card2 addSubview:docNumField];

    [NSLayoutConstraint activateConstraints:@[
        [card2.topAnchor constraintEqualToAnchor:card1.bottomAnchor constant:14],
        [card2.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [card2.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],

        [pmTitle.topAnchor constraintEqualToAnchor:card2.topAnchor constant:20],
        [pmTitle.leadingAnchor constraintEqualToAnchor:card2.leadingAnchor constant:pad],

        [pmSubtitle.topAnchor constraintEqualToAnchor:pmTitle.bottomAnchor constant:4],
        [pmSubtitle.leadingAnchor constraintEqualToAnchor:card2.leadingAnchor constant:pad],
        [pmSubtitle.trailingAnchor constraintEqualToAnchor:card2.trailingAnchor constant:-pad],

        [bancoRow.topAnchor constraintEqualToAnchor:pmSubtitle.bottomAnchor constant:16],
        [bancoRow.leadingAnchor constraintEqualToAnchor:card2.leadingAnchor constant:pad],
        [bancoRow.trailingAnchor constraintEqualToAnchor:card2.trailingAnchor constant:-pad],
        [bancoRow.heightAnchor constraintEqualToConstant:56],

        [phoneRowPM.topAnchor constraintEqualToAnchor:bancoRow.bottomAnchor constant:10],
        [phoneRowPM.leadingAnchor constraintEqualToAnchor:card2.leadingAnchor constant:pad],
        [phoneRowPM.trailingAnchor constraintEqualToAnchor:card2.trailingAnchor constant:-pad],
        [phoneRowPM.heightAnchor constraintEqualToConstant:56],

        [docTypeRow.topAnchor constraintEqualToAnchor:phoneRowPM.bottomAnchor constant:10],
        [docTypeRow.leadingAnchor constraintEqualToAnchor:card2.leadingAnchor constant:pad],
        [docTypeRow.trailingAnchor constraintEqualToAnchor:card2.trailingAnchor constant:-pad],
        [docTypeRow.heightAnchor constraintEqualToConstant:56],

        [docNumField.topAnchor constraintEqualToAnchor:docTypeRow.bottomAnchor constant:10],
        [docNumField.leadingAnchor constraintEqualToAnchor:card2.leadingAnchor constant:pad],
        [docNumField.trailingAnchor constraintEqualToAnchor:card2.trailingAnchor constant:-pad],
        [docNumField.heightAnchor constraintEqualToConstant:56],
        [docNumField.bottomAnchor constraintEqualToAnchor:card2.bottomAnchor constant:-20],
    ]];

    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    saveBtn.backgroundColor = [UIColor colorNamed:@"app_theame"];
    saveBtn.layer.cornerRadius = 14;
    [saveBtn setTitle:@"Guardar" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = FONTS_NOTO_BOLD(16);
    [saveBtn addTarget:self action:@selector(saveAll:) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:saveBtn];

    [NSLayoutConstraint activateConstraints:@[
        [saveBtn.topAnchor constraintEqualToAnchor:card2.bottomAnchor constant:20],
        [saveBtn.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:pad],
        [saveBtn.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-pad],
        [saveBtn.heightAnchor constraintEqualToConstant:56],
        [saveBtn.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-pad],
    ]];
}

#pragma mark - UI Helpers

- (UIView *)makeCard {
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 16;
    card.layer.shadowColor = [UIColor blackColor].CGColor;
    card.layer.shadowOpacity = 0.15;
    card.layer.shadowRadius = 10;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    return card;
}

- (UIView *)makeSeparator {
    UIView *sep = [[UIView alloc] init];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    sep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    NSLayoutConstraint *h = [sep.heightAnchor constraintEqualToConstant:1];
    h.priority = UILayoutPriorityDefaultLow;
    h.active = YES;
    return sep;
}

- (UITextField *)makeTextField:(NSString *)placeholder keyboard:(UIKeyboardType)kbType {
    UITextField *tf = [[UITextField alloc] init];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    tf.placeholder = placeholder;
    tf.font = FONTS_NOTO_REGULAR(14);
    tf.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    tf.layer.cornerRadius = 12;
    tf.keyboardType = kbType;
    tf.delegate = self;
    // Left padding
    UIView *lp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 1)];
    tf.leftView = lp;
    tf.leftViewMode = UITextFieldViewModeAlways;
    return tf;
}

- (UIView *)buildPhoneRowWithCCLabel:(UILabel **)ccOut
                          phoneField:(UITextField **)tfOut
                         placeholder:(NSString *)placeholder
                        countryAction:(SEL)action {
    UIView *row = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    row.layer.cornerRadius = 12;

    // Country code area
    UIView *ccBox = [[UIView alloc] init];
    ccBox.translatesAutoresizingMaskIntoConstraints = NO;
    ccBox.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1];
    ccBox.layer.cornerRadius = 12;
    [row addSubview:ccBox];

    UILabel *ccLabel = [[UILabel alloc] init];
    ccLabel.translatesAutoresizingMaskIntoConstraints = NO;
    ccLabel.font = FONTS_NOTO_REGULAR(13);
    [ccBox addSubview:ccLabel];
    if (ccOut) *ccOut = ccLabel;

    UIImageView *ccChevron = [[UIImageView alloc] init];
    ccChevron.translatesAutoresizingMaskIntoConstraints = NO;
    ccChevron.contentMode = UIViewContentModeScaleAspectFit;
    ccChevron.tintColor = [UIColor colorWithWhite:0.4 alpha:1];
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightLight];
        ccChevron.image = [[UIImage systemImageNamed:@"chevron.down" withConfiguration:cfg]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [ccBox addSubview:ccChevron];

    UIButton *ccBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    ccBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [ccBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [ccBox addSubview:ccBtn];

    [NSLayoutConstraint activateConstraints:@[
        [ccBox.topAnchor constraintEqualToAnchor:row.topAnchor constant:6],
        [ccBox.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:6],
        [ccBox.bottomAnchor constraintEqualToAnchor:row.bottomAnchor constant:-6],
        [ccBox.widthAnchor constraintEqualToConstant:90],
        [ccLabel.leadingAnchor constraintEqualToAnchor:ccBox.leadingAnchor constant:8],
        [ccLabel.centerYAnchor constraintEqualToAnchor:ccBox.centerYAnchor],
        [ccChevron.leadingAnchor constraintEqualToAnchor:ccLabel.trailingAnchor constant:4],
        [ccChevron.centerYAnchor constraintEqualToAnchor:ccBox.centerYAnchor],
        [ccChevron.widthAnchor constraintEqualToConstant:12],
        [ccChevron.heightAnchor constraintEqualToConstant:12],
        [ccChevron.trailingAnchor constraintEqualToAnchor:ccBox.trailingAnchor constant:-6],
        [ccBtn.topAnchor constraintEqualToAnchor:ccBox.topAnchor],
        [ccBtn.leadingAnchor constraintEqualToAnchor:ccBox.leadingAnchor],
        [ccBtn.trailingAnchor constraintEqualToAnchor:ccBox.trailingAnchor],
        [ccBtn.bottomAnchor constraintEqualToAnchor:ccBox.bottomAnchor],
    ]];

    // Phone text field
    UITextField *tf = [[UITextField alloc] init];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    tf.placeholder = placeholder;
    tf.font = FONTS_NOTO_REGULAR(14);
    tf.backgroundColor = [UIColor clearColor];
    tf.keyboardType = UIKeyboardTypePhonePad;
    tf.delegate = self;
    [row addSubview:tf];
    if (tfOut) *tfOut = tf;

    [NSLayoutConstraint activateConstraints:@[
        [tf.leadingAnchor constraintEqualToAnchor:ccBox.trailingAnchor constant:10],
        [tf.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [tf.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-12],
    ]];

    return row;
}

- (UIView *)buildSelectorRow:(NSString *)placeholder
                       label:(UILabel **)labelOut
                      action:(SEL)action {
    UIView *row = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    row.layer.cornerRadius = 12;

    UILabel *lbl = [[UILabel alloc] init];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    lbl.text = placeholder;
    lbl.font = FONTS_NOTO_REGULAR(14);
    lbl.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [row addSubview:lbl];
    if (labelOut) *labelOut = lbl;

    UIImageView *chevron = [[UIImageView alloc] init];
    chevron.translatesAutoresizingMaskIntoConstraints = NO;
    chevron.contentMode = UIViewContentModeScaleAspectFit;
    chevron.tintColor = [UIColor colorWithWhite:0.4 alpha:1];
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightLight];
        chevron.image = [[UIImage systemImageNamed:@"chevron.down" withConfiguration:cfg]
                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [row addSubview:chevron];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [row addSubview:btn];

    [NSLayoutConstraint activateConstraints:@[
        [lbl.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:16],
        [lbl.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [lbl.trailingAnchor constraintLessThanOrEqualToAnchor:chevron.leadingAnchor constant:-8],
        [chevron.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-16],
        [chevron.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [chevron.widthAnchor constraintEqualToConstant:16],
        [chevron.heightAnchor constraintEqualToConstant:16],
        [btn.topAnchor constraintEqualToAnchor:row.topAnchor],
        [btn.leadingAnchor constraintEqualToAnchor:row.leadingAnchor],
        [btn.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
        [btn.bottomAnchor constraintEqualToAnchor:row.bottomAnchor],
    ]];

    return row;
}

#pragma mark - Data Load

-(void)setContacts {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    NSString *contact1 = [dict objectForKey:@"emergency_contact_1"];
    if (contact1.length > 0) {
        NSArray *parts = [contact1 componentsSeparatedByString:@"|"];
        if (parts.count > 1) {
            self.txtContact1.text = [parts objectAtIndex:0];
            self.txtContactName.text = [parts objectAtIndex:1];
            if (parts.count > 3) {
                countrySelected1 = [CounrySelectionView getCurrentCountryDictWithIsoCode:[parts objectAtIndex:3]];
                self.lblCountryCode1.attributedText = [CounrySelectionView getCurrentCountryWithCountryCode:[countrySelected1 objectForKey:@"code"]];
            } else if (parts.count > 2) {
                NSString *code = [NSString stringWithFormat:@"+%@", [parts objectAtIndex:2]];
                countrySelected1 = [CounrySelectionView getCurrentCountryDictWithDialCode:code];
                self.lblCountryCode1.attributedText = [CounrySelectionView getCurrentCountryWithCountryCode:[countrySelected1 objectForKey:@"code"]];
            }
        }
    }
}

/**
 Donde vive el pago movil, y por que no en campos propios.

 Android guarda SIEMPRE el mismo JSON -- {bank, phone, cc, idType, idNumber} -- pero en
 columnas distintas segun el rol: el conductor en d_bank_info y el pasajero en
 emergency_email_3, que en esta instalacion esta libre. Lo dice su propio comentario en
 EmergencyContactsActivity: el pasajero "no tiene un campo propio", asi que reutilizaron
 una columna existente en vez de crear otras.

 Esta pantalla escribia cuatro campos sueltos (pago_movil_banco, pago_movil_telefono,
 pago_movil_doc_tipo, pago_movil_doc_numero) que NO aparecen ni una sola vez en el
 backend ni en Android. Dos consecuencias, y la segunda no depende del esquema:

   1. CoreModel::update mete todos los campos en un unico UPDATE sin filtrar columnas,
      asi que una columna inexistente tumba la sentencia entera -- y con ella el
      emergency_contact_1 que va en la misma llamada.
   2. Aunque esas columnas existieran, RecargaC2PActivity de Android lee d_bank_info /
      emergency_email_3 para enseñarle al pasajero los datos del conductor. Un conductor
      de iOS que guardara en pago_movil_* seria invisible para el pasajero de Android.

 Las dos apps tienen que coincidir en donde viven los datos. Esto es ese contrato.
 */
- (void)loadPagoMovilData {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];

    BOOL isUserLogin = [defaults_object(P_IS_USER_LOGIN) boolValue];
    NSString *guardado = isUserLogin ? [dict objectForKey:@"emergency_email_3"]
                                     : [dict objectForKey:@"d_bank_info"];
    if (![guardado isKindOfClass:[NSString class]]) {
        return;
    }
    guardado = [guardado stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![guardado hasPrefix:@"{"]) {
        return;
    }

    NSError *err = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[guardado dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:0
                                                           error:&err];
    if (err || ![json isKindOfClass:[NSDictionary class]]) {
        return;
    }

    NSString *banco = [json objectForKey:@"bank"];
    if ([banco isKindOfClass:[NSString class]] && banco.length > 0) {
        _ndBankLabel.text = banco;
        _ndBankLabel.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
        _ndSelectedBankName = banco;
    }

    NSString *pm_phone = [json objectForKey:@"phone"];
    if ([pm_phone isKindOfClass:[NSString class]] && pm_phone.length > 0) {
        _ndPmPhoneField.text = pm_phone;
    }

    // cc es el codigo ISO del pais (VE, CO...), no el prefijo telefonico.
    NSString *iso = [json objectForKey:@"cc"];
    if ([iso isKindOfClass:[NSString class]] && iso.length > 0) {
        NSDictionary *pais = [CounrySelectionView getCurrentCountryDictWithIsoCode:iso];
        if (pais) {
            _ndPmCountrySelected = pais;
        }
    }

    NSString *doc_tipo = [json objectForKey:@"idType"];
    if ([doc_tipo isKindOfClass:[NSString class]] && doc_tipo.length > 0) {
        _ndDocTypeLabel.text = doc_tipo;
        _ndDocTypeLabel.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
        _ndSelectedDocType = doc_tipo;
    }

    NSString *doc_num = [json objectForKey:@"idNumber"];
    if ([doc_num isKindOfClass:[NSString class]] && doc_num.length > 0) {
        _ndDocNumField.text = doc_num;
    }
}

/** El JSON de pago movil tal y como lo escribe y lo lee Android. */
- (NSString *)pagoMovilJSON {
    if (_ndSelectedBankName.length == 0 && _ndPmPhoneField.text.length == 0
        && _ndSelectedDocType.length == 0 && _ndDocNumField.text.length == 0) {
        return nil;
    }
    NSDictionary *json = @{
        @"bank"     : isEmpty(_ndSelectedBankName),
        @"phone"    : isEmpty(_ndPmPhoneField.text),
        @"cc"       : isEmpty([_ndPmCountrySelected objectForKey:@"code"]),
        @"idType"   : isEmpty(_ndSelectedDocType),
        @"idNumber" : isEmpty(_ndDocNumField.text),
    };
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:&err];
    if (err || !data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ((textField == self.txtContact1 || textField == _ndPmPhoneField)
        && textField.text.length >= constantTaxiModel.max_phone_length
        && range.length == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - IBActions

- (IBAction)ButtonBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCountryCodeOneButtonTap:(id)sender {
    contactOneSelectedIndex = 1;
    [CounrySelectionView showCountrySelectionViewWithDelegate:self
                                                  parentView:self.view
                                                       label:self.lblCountryCode1];
}

- (IBAction)onCountryCodePMTap:(id)sender {
    contactOneSelectedIndex = 10;
    [CounrySelectionView showCountrySelectionViewWithDelegate:self
                                                  parentView:self.view
                                                       label:_ndPmCountryCodeLabel];
}

- (void)onBancoTapped {
    [self showBankSheet];
}

#pragma mark - Bank Selection Sheet

- (void)showBankSheet {
    _allBanks = @[
        @"100% Banco",
        @"Bancamiga",
        @"Bancaribe",
        @"Banco Activo",
        @"Banco Agrícola de Venezuela",
        @"Banco Bicentenario del Pueblo",
        @"Banco Caroní",
        @"Banco de Venezuela (BDV)",
        @"Banco del Tesoro",
        @"Banco Digital de los Trabajadores",
        @"Banco Exterior",
        @"Banco Fondo Común (BFC)",
        @"Banco Nacional de Crédito (BNC)",
        @"Banco Plaza",
        @"Banco Provincial (BBVA)",
        @"Banco Sofitasa",
        @"Banco Venezolano de Crédito",
        @"Banesco",
        @"Banfanb",
        @"Banplus",
        @"Bantrab",
        @"DelSur",
        @"Mi Banco"
    ];
    _filteredBanks = [_allBanks copy];

    // Dim overlay
    _bankOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    _bankOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    _bankOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissBankSheet)];
    [_bankOverlay addGestureRecognizer:tap];
    [self.view addSubview:_bankOverlay];

    // Sheet card
    CGFloat screenW = self.view.bounds.size.width;
    CGFloat screenH = self.view.bounds.size.height;
    CGFloat sheetH  = screenH * 0.75;
    _bankSheet = [[UIView alloc] initWithFrame:CGRectMake(0, screenH, screenW, sheetH)];
    _bankSheet.backgroundColor = [UIColor whiteColor];
    _bankSheet.layer.cornerRadius = 20;
    _bankSheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _bankSheet.clipsToBounds = YES;
    [self.view addSubview:_bankSheet];

    // Title
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = @"Selecciona el Banco";
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = [UIColor blackColor];
    [_bankSheet addSubview:titleLbl];

    // Close button
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dismissBankSheet) forControlEvents:UIControlEventTouchUpInside];
    [_bankSheet addSubview:closeBtn];

    // Search container
    UIView *searchBox = [[UIView alloc] init];
    searchBox.translatesAutoresizingMaskIntoConstraints = NO;
    searchBox.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    searchBox.layer.cornerRadius = 12;
    [_bankSheet addSubview:searchBox];

    UIImageView *magnifier = [[UIImageView alloc] init];
    magnifier.translatesAutoresizingMaskIntoConstraints = NO;
    magnifier.contentMode = UIViewContentModeScaleAspectFit;
    magnifier.tintColor = [UIColor colorWithWhite:0.5 alpha:1];
    if (@available(iOS 13, *)) {
        magnifier.image = [[UIImage systemImageNamed:@"magnifyingglass"]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [searchBox addSubview:magnifier];

    _bankSearchField = [[UITextField alloc] init];
    _bankSearchField.translatesAutoresizingMaskIntoConstraints = NO;
    _bankSearchField.placeholder = @"Buscar...";
    _bankSearchField.font = FONTS_NOTO_REGULAR(15);
    _bankSearchField.backgroundColor = [UIColor clearColor];
    [_bankSearchField addTarget:self action:@selector(onBankSearch:) forControlEvents:UIControlEventEditingChanged];
    [searchBox addSubview:_bankSearchField];

    // Table
    _bankTableView = [[UITableView alloc] init];
    _bankTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _bankTableView.delegate = self;
    _bankTableView.dataSource = self;
    _bankTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _bankTableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:1];
    _bankTableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    _bankTableView.rowHeight = 56;
    _bankTableView.tableFooterView = [[UIView alloc] init];
    [_bankSheet addSubview:_bankTableView];

    [NSLayoutConstraint activateConstraints:@[
        [titleLbl.topAnchor constraintEqualToAnchor:_bankSheet.topAnchor constant:24],
        [titleLbl.centerXAnchor constraintEqualToAnchor:_bankSheet.centerXAnchor],

        [closeBtn.centerYAnchor constraintEqualToAnchor:titleLbl.centerYAnchor],
        [closeBtn.trailingAnchor constraintEqualToAnchor:_bankSheet.trailingAnchor constant:-20],
        [closeBtn.widthAnchor constraintEqualToConstant:36],
        [closeBtn.heightAnchor constraintEqualToConstant:36],

        [searchBox.topAnchor constraintEqualToAnchor:titleLbl.bottomAnchor constant:20],
        [searchBox.leadingAnchor constraintEqualToAnchor:_bankSheet.leadingAnchor constant:16],
        [searchBox.trailingAnchor constraintEqualToAnchor:_bankSheet.trailingAnchor constant:-16],
        [searchBox.heightAnchor constraintEqualToConstant:48],

        [magnifier.leadingAnchor constraintEqualToAnchor:searchBox.leadingAnchor constant:14],
        [magnifier.centerYAnchor constraintEqualToAnchor:searchBox.centerYAnchor],
        [magnifier.widthAnchor constraintEqualToConstant:18],
        [magnifier.heightAnchor constraintEqualToConstant:18],

        [_bankSearchField.leadingAnchor constraintEqualToAnchor:magnifier.trailingAnchor constant:10],
        [_bankSearchField.trailingAnchor constraintEqualToAnchor:searchBox.trailingAnchor constant:-10],
        [_bankSearchField.centerYAnchor constraintEqualToAnchor:searchBox.centerYAnchor],

        [_bankTableView.topAnchor constraintEqualToAnchor:searchBox.bottomAnchor constant:12],
        [_bankTableView.leadingAnchor constraintEqualToAnchor:_bankSheet.leadingAnchor],
        [_bankTableView.trailingAnchor constraintEqualToAnchor:_bankSheet.trailingAnchor],
        [_bankTableView.bottomAnchor constraintEqualToAnchor:_bankSheet.bottomAnchor],
    ]];

    // Slide up animation
    _bankOverlay.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self->_bankOverlay.alpha = 1;
        self->_bankSheet.frame = CGRectMake(0, screenH - sheetH, screenW, sheetH);
    } completion:nil];
}

- (void)dismissBankSheet {
    CGFloat screenH = self.view.bounds.size.height;
    CGFloat sheetH  = _bankSheet.bounds.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self->_bankOverlay.alpha = 0;
        self->_bankSheet.frame = CGRectMake(0, screenH, self->_bankSheet.bounds.size.width, sheetH);
    } completion:^(BOOL finished) {
        [self->_bankOverlay removeFromSuperview];
        [self->_bankSheet removeFromSuperview];
        self->_bankOverlay   = nil;
        self->_bankSheet     = nil;
        self->_bankTableView = nil;
        self->_bankSearchField = nil;
    }];
}

- (void)onBankSearch:(UITextField *)tf {
    NSString *query = tf.text;
    if (query.length == 0) {
        _filteredBanks = [_allBanks copy];
    } else {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", query];
        _filteredBanks = [_allBanks filteredArrayUsingPredicate:pred];
    }
    [_bankTableView reloadData];
}

#pragma mark - UITableViewDataSource / Delegate (bank sheet)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _bankTableView) return (NSInteger)_filteredBanks.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bankTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BankCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BankCell"];
            cell.textLabel.font = FONTS_NOTO_REGULAR(16);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        cell.textLabel.text = _filteredBanks[(NSUInteger)indexPath.row];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bankTableView) {
        NSString *bank = _filteredBanks[(NSUInteger)indexPath.row];
        _ndSelectedBankName = bank;
        _ndBankLabel.text = bank;
        _ndBankLabel.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
        [self dismissBankSheet];
    }
}

- (void)onTipoDocTapped {
    // TODO: Open document type selection modal (coming from user)
}

- (IBAction)saveAll:(id)sender {
    [self.view endEditing:YES];

    // Validate SOS contact
    if (self.txtContactName.text.length == 0 && self.txtContact1.text.length == 0) {
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_1_s26_contct_req"]];
        return;
    }
    if (self.txtContactName.text.length > 0 || self.txtContact1.text.length > 0) {
        if (countrySelected1 == nil) {
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_10_s1_plz_sel_country_code"]];
            return;
        }
        if (self.txtContact1.text.length < constantTaxiModel.min_phone_length) {
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_21_s2_plz_enter_valid_mobile_number"]];
            return;
        }
        if (self.txtContactName.text.length == 0) {
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_22_s40_co_pass_name"]];
            return;
        }
    }

    [self updateProfileContact];
}

#pragma mark - Profile Update

/**
 Esta pantalla se abre desde LOS DOS menus -- LeftViewController (conductor) y
 ULeftViewController (pasajero) -- pero guardaba siempre por driverapi, con driver_id y
 sin usr_ref_id. Tres cosas rompia, todas comprobadas contra el backend:

   1. El PASAJERO no tiene driver_id, asi que su contacto de emergencia no se guardaba
      en ningun sitio. Android reparte: userapi/updateuserprofile para el pasajero y
      driverapi/updatedriverprofile para el conductor (EmergencyContactsActivity).

   2. Sin usr_ref_id, lo que guarda el CONDUCTOR se queda solo en la tabla drivers.
      DriverAPI::postUpdateDriverProfile propaga a users unicamente dentro de
      `if ($userID)`, y $userID sale de usr_ref_id. Peor aun: DriverModel::updateDriver
      copia los emergency_* de users HACIA drivers, asi que el valor del conductor se
      pisa en la siguiente sincronizacion. El SOS lee P_USER_DICT_LOGGED, que es el
      registro de usuario: sin propagar, nunca ve el contacto.

   3. El pago movil iba en cuatro campos inventados. Ver loadPagoMovilData.

 Contra que se comprobo: DriverAPI.php (propagacion por usr_ref_id), CoreModel::update
 (un solo UPDATE sin filtrar columnas), DriverModel::updateDriver (sentido de la copia)
 y EmergencyContactsActivity de Android (el reparto por rol).
 */
-(void)updateProfileContact {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    NSDictionary *dictLogged = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT_LOGGED];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    BOOL isUserLogin = [defaults_object(P_IS_USER_LOGIN) boolValue];

    // Contacto SOS 1. Formato movil|nombre|prefijo|iso, el mismo que Android.
    NSString *contacto1 = @"|";
    if (self.txtContactName.text.length > 0 && self.txtContact1.text.length >= constantTaxiModel.min_phone_length) {
        NSString *code    = [Utilities removePlusBeforeNumber:[countrySelected1 objectForKey:@"dial_code"]];
        NSString *mobile  = [Utilities removeAllLeadingZero:[Utilities removePlusBeforeNumber:self.txtContact1.text]];
        NSString *isoCode = [countrySelected1 objectForKey:@"code"];
        contacto1 = [NSString stringWithFormat:@"%@|%@|%@|%@", mobile, self.txtContactName.text, code, isoCode];
    }
    [dict setValue:contacto1 forKey:P_EMERGENCY_CONTACT_1];

    NSString *pagoMovil = [self pagoMovilJSON];

    NSString *api = nil;
    if (isUserLogin) {
        api = UPDATE_USER_PROFILE;
        [dict setValue:isEmpty([dict1 objectForKey:P_USER_ID]) forKey:P_USER_ID];
        // Android manda tambien el 2 y el 3 en blanco, y esta pantalla solo edita el 1:
        // si no se mandan, quedarian valores viejos que el SOS si leeria.
        [dict setValue:@" " forKey:@"emergency_contact_2"];
        [dict setValue:@" " forKey:@"emergency_contact_3"];
        if (pagoMovil) {
            [dict setValue:pagoMovil forKey:@"emergency_email_3"];
        }
    } else {
        api = UPDATE_DRIVER_PROFILE;
        [dict setValue:isEmpty([dict1 objectForKey:P_DRIVER_ID]) forKey:P_DRIVER_ID];
        // Sin esto el backend no propaga nada a la tabla users.
        NSString *usrRefId = [dict1 objectForKey:@"usr_ref_id"];
        if (usrRefId.length == 0) {
            usrRefId = [dictLogged objectForKey:P_USER_ID];
        }
        [dict setValue:isEmpty(usrRefId) forKey:@"usr_ref_id"];
        if (pagoMovil) {
            [dict setValue:pagoMovil forKey:@"d_bank_info"];
        }
    }

    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];

    [GIC mkwerwu:api d:dict cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if (error) { [Utilities handleError:error viewController:self defaultMessage:@""]; return; }
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            NSDictionary *respuesta = [results objectForKey:P_RESPONSE];
            defaults_set_object(P_USER_DICT, respuesta);
            if (isUserLogin) {
                // La respuesta ES el registro de usuario: el SOS lo ve enseguida.
                defaults_set_object(P_USER_DICT_LOGGED, respuesta);
            } else if ([dictLogged isKindOfClass:[NSDictionary class]]) {
                // La respuesta es el registro de conductor. El servidor ya propago a
                // users por usr_ref_id, pero la copia local seguiria vieja y el SOS lee
                // de ahi, asi que se parchea el contacto a mano.
                NSMutableDictionary *copia = [NSMutableDictionary dictionaryWithDictionary:dictLogged];
                [copia setValue:contacto1 forKey:P_EMERGENCY_CONTACT_1];
                defaults_set_object(P_USER_DICT_LOGGED, copia);
            }
            if (self.isAddOneContact) {
                [self loadHomeViewController:YES];
            } else {
                [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_r35_s1_updated_success"]];
            }
        } else if (results != nil) {
            // Antes no habia rama de error: un fallo del servidor no decia nada y la
            // pantalla se quedaba como si hubiera guardado.
            [self showWarningWithMessgae:[results objectForKey:P_MESSAGE]];
        }
    }];
}

#pragma mark - CounrySelectionView Delegate

-(void)onCountrySelction:(NSDictionary *)countryDict {
    if (contactOneSelectedIndex == 1) {
        countrySelected1 = countryDict;
    } else if (contactOneSelectedIndex == 10) {
        _ndPmCountrySelected = countryDict;
    }
}

#pragma mark - Contact Picker

- (IBAction)onContactOneButtonTap:(id)sender {
    contactNumber = 1;
    CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
    picker.delegate = self;
    picker.displayedPropertyKeys = @[CNContactGivenNameKey, CNContactMiddleNameKey, CNContactPhoneNumbersKey];
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSString *phone = @"";
    for (CNLabeledValue *pv in contact.phoneNumbers) {
        NSString *s = [[[NSString stringWithFormat:@"%@", ((CNPhoneNumber *)pv.value).stringValue]
                        stringByReplacingOccurrencesOfString:@" " withString:@""] copy];
        if (s.length > 0) { phone = s; break; }
    }
    phone = [Utilities removePlusBeforeNumber:phone];
    NSString *clean = [[phone componentsSeparatedByCharactersInSet:
                        [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]]
                       componentsJoinedByString:@""];
    if (contactNumber == 1) {
        self.txtContactName.text = [NSString stringWithFormat:@"%@ %@", isEmpty(contact.givenName), isEmpty(contact.middleName)];
        self.txtContact1.text = isEmpty(clean);
    }
}

-(void)contactPickerDidCancel:(CNContactPickerViewController *)picker { contactNumber = 0; }

#pragma mark - Mail / SMS (kept for SOS send functionality)

- (IBAction)ButtonGmail:(id)sender {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    if (![MFMailComposeViewController canSendMail]) {
        [UtilityClass swa:@"Whoops!" m:[LanguageHelper getStringWithKey:@"k_65_s4_config_mail"]
                      cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
        return;
    }
    MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
    mailCont.mailComposeDelegate = self;
    NSMutableArray *emails = [NSMutableArray array];
    for (NSString *key in @[@"emergency_email_1", @"emergency_email_2", @"emergency_email_3"]) {
        NSString *e = [dict1 objectForKey:key];
        if (e.length > 0) [emails addObject:e];
    }
    [mailCont setToRecipients:emails];
    [mailCont setSubject:@"SOS Alert"];
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com?q=%f,%f",
                     [APP_DELEGATE currLoc].coordinate.latitude, [APP_DELEGATE currLoc].coordinate.longitude];
    NSString *body = [NSString stringWithFormat:@"%@,<a href=\"%@\">Click Here</a>",
                      [LanguageHelper getStringWithKey:@"k_r34_s8_sos_help_text"], url];
    [mailCont setMessageBody:body isHTML:YES];
    [self presentViewController:mailCont animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

/**
 Saca el telefono marcable de un contacto de emergencia.

 Se guardan como movil|nombre|prefijo|iso (lo mismo que Android escribe en
 EmergencyContactsActivity) y cuando el campo esta vacio se guarda "|" a secas. Android
 arma el numero como prefijo+movil cuando hay tres partes o mas; si solo viene el movil,
 lo usa tal cual.

 Devuelve nil si no hay nada marcable, para que quien llame no tenga que repetir la
 comprobacion.
 */
+ (NSString *)telefonoDeContactoDeEmergencia:(NSString *)guardado {
    if (![guardado isKindOfClass:[NSString class]] || guardado.length == 0) {
        return nil;
    }
    NSArray *partes = [guardado componentsSeparatedByString:@"|"];
    NSString *movil = [[partes firstObject] stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (movil.length == 0) {
        return nil;
    }
    if (partes.count > 2) {
        NSString *prefijo = [[partes objectAtIndex:2] stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (prefijo.length > 0) {
            return [NSString stringWithFormat:@"+%@%@", prefijo, movil];
        }
    }
    return movil;
}

- (IBAction)ButtonSms:(id)sender {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults] objectForKey:P_USER_DICT];
    NSString *url = [NSString stringWithFormat:@"http://maps.google.com?q=%f,%f",
                     [APP_DELEGATE currLoc].coordinate.latitude, [APP_DELEGATE currLoc].coordinate.longitude];
    NSString *body = [NSString stringWithFormat:@"%@,%@.",
                      [LanguageHelper getStringWithKey:@"k_r34_s8_sos_help_text"], url];
    // El contacto se guarda como movil|nombre|prefijo|iso, no como numero suelto.
    // Aqui se metia la cadena ENTERA como destinatario del SMS, pipes incluidos, y
    // cuando no habia contacto se guarda "|", que tambien pasaba el n.length>0.
    NSMutableArray *numbers = [NSMutableArray array];
    for (NSString *key in @[@"emergency_contact_1", @"emergency_contact_2", @"emergency_contact_3"]) {
        NSString *numero = [SettingViewController telefonoDeContactoDeEmergencia:[dict1 objectForKey:key]];
        if (numero.length > 0) [numbers addObject:numero];
    }
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *msgVC = [[MFMessageComposeViewController alloc] init];
        msgVC.messageComposeDelegate = self;
        msgVC.body = body;
        msgVC.recipients = numbers;
        [self presentViewController:msgVC animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Unused stubs (kept for IBAction compatibility)

-(void)setUIFields {}
-(void)setThemeConstants {}
-(void)setLocalization {}
- (IBAction)ButtonUpdateContact:(id)sender { [self saveAll:sender]; }
- (IBAction)ButtonUpdateEmail:(id)sender {}
- (IBAction)ButtonFacebook:(id)sender {}
- (IBAction)ButtonSetting:(id)sender {}
- (IBAction)onContactTwoButtonTap:(id)sender {}
- (IBAction)onCountryCodeTwoButtonTap:(id)sender {}
- (IBAction)onAddContact3:(id)sender {}
- (IBAction)onAddContact4:(id)sender {}
- (IBAction)onAddContact5:(id)sender {}
- (IBAction)onCountryCode3:(id)sender {}
- (IBAction)onCountryCode4:(id)sender {}
- (IBAction)onCountryCode5:(id)sender {}

@end
