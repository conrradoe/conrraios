//
//  SettingViewController.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 07/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FBSDKShareKit/FBSDKShareKit.h>
#import "LanguageHelper.h"
#import "BaseViewController.h"


@interface SettingViewController : BaseViewController/**<FBSDKSharingDelegate>*/

@property(strong, nonatomic) NSString *isfromBeginTripView;


@property (strong, nonatomic) IBOutlet UIView *settingView;
@property (strong, nonatomic) IBOutlet UITextField *txtContact1;
@property (strong, nonatomic) IBOutlet UITextField *txtContact2;
@property (strong, nonatomic) IBOutlet UITextField *txtContact3;
@property (strong, nonatomic) IBOutlet UITextField *txtemail1;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail2;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail3;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UIButton *btnAlertViaFacebook;
@property (strong, nonatomic) IBOutlet UIButton *btnAlertViaGmail;
@property (strong, nonatomic) IBOutlet UIButton *lblAlertViaSms;
@property (strong, nonatomic) IBOutlet UIButton *btnSetting;
@property (strong, nonatomic) IBOutlet UILabel *lblEmergencyContact;
@property (strong, nonatomic) IBOutlet UILabel *lblEmergencyEmail;
@property (strong, nonatomic) IBOutlet UIButton *btnContactUpdate;
@property (strong, nonatomic) IBOutlet UIButton *btnEmailUpdate;
@property (strong, nonatomic) IBOutlet UIImageView *imgHeaderView;
@property (strong, nonatomic) IBOutlet UIView *viewBgButtons;
@property (weak, nonatomic) IBOutlet UIImageView *contactIconOutlet;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *viewOnScroll;
@property (weak, nonatomic) IBOutlet UILabel *lblEmergencyCont;
@property (weak, nonatomic) IBOutlet UILabel *lblContact1;
@property (weak, nonatomic) IBOutlet UILabel *lblContact2;

@property (weak, nonatomic) IBOutlet UILabel *lblContact3;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail2;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail3;

@property (weak, nonatomic) IBOutlet UILabel *lblEmail1;
@property (weak, nonatomic) IBOutlet UITextField *txtContactName;

@property (weak, nonatomic) IBOutlet UITextField *txtContactName2;
@property (assign, nonatomic)BOOL isAddOneContact;

@property (weak, nonatomic) IBOutlet UIView *viewCountryCode1;

@property (weak, nonatomic) IBOutlet UILabel *lblCountryCode1;

@property (weak, nonatomic) IBOutlet UILabel *lblCountryCode2;

@property (weak, nonatomic) IBOutlet UIView *viewContryCodee2;

@property (weak, nonatomic) IBOutlet UITextField *txtName3;
@property (weak, nonatomic) IBOutlet UITextField *txtMobile3;
@property (weak, nonatomic) IBOutlet UILabel *lblContact4;
@property (weak, nonatomic) IBOutlet UITextField *txtNam4;
@property (weak, nonatomic) IBOutlet UITextField *txtMobile4;
@property (weak, nonatomic) IBOutlet UITextField *txtName5;
@property (weak, nonatomic) IBOutlet UITextField *txtMobile5;

@property (weak, nonatomic) IBOutlet UILabel *lblContact5;

@property (weak, nonatomic) IBOutlet UILabel *lblCountryCode3;
@property (weak, nonatomic) IBOutlet UILabel *lblCountryCode4;
@property (weak, nonatomic) IBOutlet UILabel *lblCountryCode5;

@end
