//
//  EditProfileViewController.h
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 23/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"
#import "Utilities.h"
#import "BaseViewController.h"

@interface UEditProfileViewController : BaseViewController<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;
@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (strong, nonatomic) IBOutlet UISwitch *switchChangePass;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (strong, nonatomic) IBOutlet UIView *viewPassword;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblChangePassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIView *viewChangePass;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *userMobileLbl;
@property (weak, nonatomic) IBOutlet UIScrollView *profileScrollView;
@property (weak, nonatomic) IBOutlet UIView *viewOnScroll;
@property (weak, nonatomic) IBOutlet UIView *profileImageView;
//@property (weak, nonatomic) IBOutlet UILabel *txtEmailLbl;
@property (weak, nonatomic) IBOutlet UILabel *lblCityName;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblFname;
@property (weak, nonatomic) IBOutlet UILabel *lblLname;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;

@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UILabel *lblMobile;
@property (weak, nonatomic) IBOutlet UILabel *lblCurPassword;

@property (weak, nonatomic) IBOutlet UILabel *lblNewPassword;

@property (weak, nonatomic) IBOutlet UILabel *lblConfirmPassword;

@property (weak, nonatomic) IBOutlet UILabel *lblReferralCode;
@property (weak, nonatomic) IBOutlet UIView *viewCity;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteAccount;

@property (weak, nonatomic) IBOutlet UIImageView *imageFname;
@property (weak, nonatomic) IBOutlet UIImageView *imageLname;
@property (weak, nonatomic) IBOutlet UIImageView *imageEmail;
@property (weak, nonatomic) IBOutlet UIImageView *imageCity;
@property (weak, nonatomic) IBOutlet UIImageView *imageMobile;

@property (weak, nonatomic) IBOutlet UIImageView *imageCurrentPassword;

@property (weak, nonatomic) IBOutlet UIImageView *imageNewPassword;
@property (weak, nonatomic) IBOutlet UIImageView *imageConfirmPassword;


@end
