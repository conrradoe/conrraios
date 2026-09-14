//
//  EditProfileViewController.h
//  Store_project
//
//  Created by  Appicial on 23/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"

#import <objc/runtime.h>
#import "BaseViewController.h"
#import "UIImagePickerController+Extension.h"
@interface EditProfileViewController : BaseViewController<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPassword;

@property (strong, nonatomic) IBOutlet UISwitch *switchChangePass;

@property (strong, nonatomic) IBOutlet UIView *viewPassword;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

@property (strong, nonatomic) IBOutlet UIButton *btnUploadDocument;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;

@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblChangePassword;
@property (weak, nonatomic) IBOutlet UILabel *userNamelbl;
@property (weak, nonatomic) IBOutlet UILabel *userMobilelbl;
@property (weak, nonatomic) IBOutlet UIView *viewOnScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *profileScrollView;
@property (weak, nonatomic) IBOutlet UIView *profileImageuiView;
//@property (weak, nonatomic) IBOutlet UILabel *txtEmailLbl;
@property (weak, nonatomic) IBOutlet UIView *viewStarRating;
//@property (weak, nonatomic) IBOutlet UILabel *lbCity;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *btnProfileImage;
@property (weak, nonatomic) IBOutlet UIView *firstNameView;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfileIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UIImageView *imgFirstName;
@property (weak, nonatomic) IBOutlet UIView *lastNameView;
@property (weak, nonatomic) IBOutlet UIImageView *lastNameIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblLastName;

@property (weak, nonatomic) IBOutlet UIImageView *imgLastName;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIImageView *imgEmailIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;

@property (weak, nonatomic) IBOutlet UIView *cityView;

@property (weak, nonatomic) IBOutlet UIImageView *imgCityscape;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UILabel *lblCityName;

@property (weak, nonatomic) IBOutlet UIImageView *imgCity;
@property (weak, nonatomic) IBOutlet UIView *mobileView;
@property (weak, nonatomic) IBOutlet UIImageView *imgMobileIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblMobileNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imgMobile;
@property (weak, nonatomic) IBOutlet UIView *updatePassView;
@property (weak, nonatomic) IBOutlet UIImageView *imgUpdatePassIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblUpdatePassword;
@property (weak, nonatomic) IBOutlet UIView *oldPassView;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentPassword;
@property (weak, nonatomic) IBOutlet UIImageView *updatePassIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgCurretPass;
@property (weak, nonatomic) IBOutlet UIImageView *imgNewPassView;
@property (weak, nonatomic) IBOutlet UILabel *lblNewPass;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmPassword;
@property (weak, nonatomic) IBOutlet UIView *viewBankInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblBankInfo;
@property (weak, nonatomic) IBOutlet UIView *viewBankInfoInput;

@property (weak, nonatomic) IBOutlet UISwitch *switchBankInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblBankName;
@property (weak, nonatomic) IBOutlet UITextField *txtBankName;

@property (weak, nonatomic) IBOutlet UILabel *lblAccountNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtAccountNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblIFSCode;
@property (weak, nonatomic) IBOutlet UITextField *txtIfscCode;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteAccount;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;

@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imageFirstname;
@property (weak, nonatomic) IBOutlet UIImageView *imageEmail;

@property (weak, nonatomic) IBOutlet UIImageView *imageCity;
@property (weak, nonatomic) IBOutlet UIImageView *imageMobile;
@property (weak, nonatomic) IBOutlet UIImageView *imageBankInfo;

@end
