//
//  UploadDocumentViewController.h
//  Store_project
//
//  Created by  Appicial on 22/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQDropDownTextField.h"
#import "TextFieldPadding.h"
#import "LanguageHelper.h"
#import "BaseViewController.h"
#import "UIImagePickerController+Extension.h"
@interface UploadDocumentViewController : BaseViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,IQDropDownTextFieldDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet TextFieldPadding *txtVehicleName;
@property (weak, nonatomic) IBOutlet TextFieldPadding *txtVehicleModel;
@property (strong, nonatomic) IBOutlet UITextField *txtSelectYear;
@property (strong, nonatomic) IBOutlet IQDropDownTextField *txtSelectCategory;
@property (strong, nonatomic) IBOutlet TextFieldPadding *txtLicenseNumber;
@property (strong, nonatomic) IBOutlet UIView *viewMakeBg;
@property (strong, nonatomic) IBOutlet UIView *viewModelBg;
@property (strong, nonatomic) IBOutlet UIView *viewYearBg;
@property (strong, nonatomic) IBOutlet UIView *viewCategoryBg;
@property (strong, nonatomic) IBOutlet UIView *viewPlateNumberBg;

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIView *headerSepView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblVehicalName;
@property (weak, nonatomic) IBOutlet UILabel *lblVehicalModel;
@property (weak, nonatomic) IBOutlet UILabel *lblVehicalMfgYear;
@property (weak, nonatomic) IBOutlet UILabel *lblRegNumber;

@property (weak, nonatomic) IBOutlet UIView *viewDocs;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewDocumentHeight;

@property (weak, nonatomic) IBOutlet UIView *viewVehicleInfo;

@property (weak, nonatomic) IBOutlet TextFieldPadding *txtVehicleColor;
@property (weak, nonatomic) IBOutlet UILabel *lblVehicleColor;
@property (weak, nonatomic) IBOutlet UIView *viewVehicleColorBg;


@property (weak, nonatomic) IBOutlet UIButton *btnCarImage;
@property (weak, nonatomic) IBOutlet UIView *viewCarImage;
@property (weak, nonatomic) IBOutlet UILabel *lblCarImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgCarImage;

@property (weak, nonatomic) IBOutlet UIView *viewCity;

@property (weak, nonatomic) IBOutlet UIImageView *ImageDropDown;
@property (weak, nonatomic) IBOutlet IQDropDownTextField *txtCity;
@property (weak, nonatomic) IBOutlet UIImageView *imageVehicleName;
@property (weak, nonatomic) IBOutlet UIImageView *imageVehicleModel;
@property (weak, nonatomic) IBOutlet UIImageView *imageVehicleColor;
@property (weak, nonatomic) IBOutlet UIImageView *imageVehicleMfgColor;

@property (weak, nonatomic) IBOutlet UIScrollView *viewScrollDocs;
@property (weak, nonatomic) IBOutlet UIScrollView *viewScrollVehicleInfo;

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIImageView *imageVehicleRegNum;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;


@property (nonatomic) BOOL isfromProfile;

@end
