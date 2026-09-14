//
//  UploadDocumentViewController.m
//  Store_project
//
//  Created by  Appicial on 22/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "UploadDocumentViewController.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import <GIKit/GIKit.h>

#import "UIView+UpdateAutoLayoutConstraints.h"
#import "Utilities.h"
#import "UIViewController+AlertHelper.h"
#import "UploadDocView.h"
#import "UIImageView+WebCache.h"
#import "SettingsModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "CityModel.h"
#import "MainViewController.h"
#import "ConstantModel.h"
#import "DatePickerViewController.h"
#import "UserProfile.h"
@interface UploadDocumentViewController ()<UploadDocViewDelegate,DatePickerViewControllerDelegate,NIDropDownDelegate>
{
    NSArray *catArray;
    NSMutableArray *arrCarTypes;
    NSMutableArray *docArray;
    NSArray *jsonDocs;
    NSString *selectedCatID;
    NSString *selectedCarID;
    NSString *selectedCityId;
    BOOL isCarImage;
    int cellCount;
    NSString *carPlateNumber;
    int apiCallAttempt;
    int calcualatedHeight;
    BOOL isNextTapVehcleInfo;
    NSString *strCarImage;
    NSString *strProfileImage;
    NSString *strCarImagepath;
    NSString *strProfileImagepath;
    UploadDocView * uploadDocViewSelected;
    BOOL isProfileImageTabed;
    UIButton *dropDownBtnSelected;
    UITapGestureRecognizer *tapRecognizer;
    UIView *gestureBg;
    NIDropDown *dropDown;
}

@end

@implementation UploadDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewScrollDocs.hidden = NO;
    self.viewScrollVehicleInfo.hidden = YES;
    calcualatedHeight=0;
    isNextTapVehcleInfo=NO;
    [self setUIFiels];
    [self setThemeConstants];
    catArray =[[NSArray alloc]init];
    arrCarTypes =[[NSMutableArray alloc]init];
    cellCount = 8;
    apiCallAttempt =0;
    _btnBack.hidden=NO;
    [self setBorder:self.viewCategoryBg];
    [self setBorder:self.viewCity];
    [self setBorder:self.viewCarImage];
    [self.btnNext setTitle: [LanguageHelper getStringWithKey:@"k_14_s7_next"]   forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDone)
                                                 name:@"DoneCalled"
                                               object:nil];
    [self setTextFieldPlaceholderColor:self.txtVehicleName];
    [self setTextFieldPlaceholderColor:self.txtVehicleModel];
    [self setTextFieldPlaceholderColor:self.txtVehicleColor];
    [self setTextFieldPlaceholderColor:self.txtSelectYear];
    [self setTextFieldPlaceholderColor:self.txtSelectCategory];
    [self setTextFieldPlaceholderColor:self.txtLicenseNumber];
    
    [Utilities applyGrayTintOnImageView:self.imageVehicleModel];
    [Utilities applyGrayTintOnImageView:self.ImageDropDown];
    [Utilities applyGrayTintOnImageView:self.imageVehicleRegNum];
    [Utilities applyGrayTintOnImageView:self.imageVehicleName];
    [Utilities applyGrayTintOnImageView:self.imageVehicleColor];
    [Utilities applyGrayTintOnImageView:self.imageVehicleMfgColor];
     
//    NSDictionary * dictDriver = defaults_object(P_USER_DICT);
//    self.lblUserName.text =  [NSString stringWithFormat:@"%@ %@",[dictDriver objectForKey:P_FNAME],[dictDriver objectForKey:P_LNAME]];
//    NSString *profile=[dictDriver objectForKey:P_DRIVER_PROFILE_IMAGE_PATH];
//    if (profile.length>0) {
//        [self.imageProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
//          
//    }
    
    self.txtVehicleName.enabled=NO;
    self.txtSelectYear.enabled=NO;
    self.txtSelectCategory.dropDownTextColor = [UIColor colorNamed:@"color_app_label"];
    
    self.txtSelectCategory.delegate =self;
    self.txtSelectYear.delegate =self;
    self.txtVehicleName.delegate =self;
    self.txtCity.delegate =self;
    
    self.txtCity.tag=10;
    self.txtSelectCategory.tag=4;
    
    
    self.txtVehicleName.delegate=self;
    self.txtVehicleModel.delegate=self;
    self.txtSelectYear.delegate=self;
    self.txtLicenseNumber.delegate=self;
    [self updateDocumentDetail];
    [self setSelectCity];
    
    
    [self setUpUiForUploadImage];
    [self getAssets];
//    self.viewVehicleInfo.clipsToBounds=YES;
//    [self.viewVehicleInfo  setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    if([self getFilteredCities].count==1){
        [self.viewCity hideByHeight:YES];
        CityModel * cityModel=[self getFilteredCities].firstObject;
        selectedCityId=  [NSString stringWithFormat:@"%d",cityModel.city_id];
        selectedCatID=@"";
        [self.txtSelectCategory   setItemList:nil];
        [self getCarCategory:selectedCityId];
    }else{
        if([self->selectedCityId intValue]>0) {
            [self getCarCategory:self-> selectedCityId];
        }
    }
}



-(void) setUpUiForUploadImage{
    
    //    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"Doc" ofType:@"json"];
    NSError *error;
    //    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    SettingsModel *settingsModel=[SettingsModel getSettignsObject];
    NSString *fileContents = settingsModel.driver_docs;
    NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    docArray=[[NSMutableArray alloc] init];
    jsonDocs=[[NSArray alloc] initWithArray:json];
    if ([json isKindOfClass:[NSArray class]]){
        int index=0;
        int height=45;int topPadding=5;
        int heightFor=0;
        for (NSDictionary * dict in  json) {
            
            NSArray * inputs=[dict objectForKey:@"inputs"];
            
            int heightFinal= height*((int)inputs.count);
            UploadDocView * view= [[UploadDocView alloc] initWithView:self.viewDocs frame:CGRectMake(0, heightFor, SCREEN_WIDTH-40, heightFinal) dict:dict];
            index=index+1;
            view.delegate=self;
            view.viewController=self;
            
            [docArray addObject:view];
            heightFor=heightFor+[view getCalculatedHeight];
        }
        if(index>0)
        {
            
            self.viewDocumentHeight.constant=heightFor+index*topPadding;
            //            self.viewDocumentHeight.constant=600;
        }else
        {
            self.viewDocumentHeight.constant=0;
        }
        
        calcualatedHeight= self.viewDocumentHeight.constant;
       
    }
    
}



-(void)setUIFiels{
    
    if(isNextTapVehcleInfo) {
        self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_11_s7_vehicle_details"];
    }else{
        self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_3_s6_upload_doc"];
    }
    self.txtVehicleName.placeholder=[LanguageHelper getStringWithKey:@"k_7_s7_enter_vehicle_name"];
    self.txtSelectCategory.placeholder=[LanguageHelper getStringWithKey:@"k_31_s7_select_category"];
    self.lblVehicalName.text = [LanguageHelper getStringWithKey:@"k_6_s7_car_name"];
    self.txtVehicleModel.placeholder=[LanguageHelper getStringWithKey:@"k_9_s7_enter_vehicle_model"];
    self.lblVehicalModel.text = [LanguageHelper getStringWithKey:@"k_8_s7_vehicle_model"];
    self.lblVehicleColor.text = [LanguageHelper getStringWithKey:@"k_8_s7_vehicle_color"];
    self.lblVehicalMfgYear.text = [LanguageHelper getStringWithKey:@"k_10_s7_vehicle_year"];
    self.txtSelectYear.placeholder=[LanguageHelper getStringWithKey:@"k_11_s7_enter_vehicle_mfg_year"];
    self.lblRegNumber.text = [LanguageHelper getStringWithKey:@"k_12_s7_enter_licence_number"];
    self.txtLicenseNumber.placeholder=[LanguageHelper getStringWithKey:@"k_13_s7_enter_licence_number_hint"];
    self.lblCarImage.text=[LanguageHelper getStringWithKey:@"k_r43_s8_car_img_upld"];
    self.txtVehicleColor.placeholder=[LanguageHelper getStringWithKey:@"k_9_s7_enter_vehicle_color"];
    [self.btnNext setTitle: [LanguageHelper getStringWithKey:@"k_34_s6_save"]   forState:UIControlStateNormal];
    
}





-(void)docUploadView:(UploadDocView *)docUploadView startUploadDoc:(NSString *)status
{
}

-(void)docUploadView:(UploadDocView *)docUploadView dateSelect:(NSDate *)date{
    uploadDocViewSelected=docUploadView;
    DatePickerViewController *vc=[[DatePickerViewController alloc] initWithNibName:@"DatePickerViewController" bundle:nil];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    vc.delegate=self;
    vc.selectedDate=date;
    vc.titleText=[LanguageHelper getStringWithKey:@"k_r49_s8_plz_sel_exp_dte"];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

-(void) viewController:(DatePickerViewController *)datePicker dateSelected:(NSDate *)date{
    [datePicker dismissViewControllerAnimated:YES completion:^{
        self->uploadDocViewSelected.selectedDate=date;
        NSDateFormatter *df=[[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        self->uploadDocViewSelected.textField.text = [df stringFromDate:date];
    }];
}










 

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
}


-(void)setThemeConstants{
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
    [_btnNext.titleLabel setFont:FONTS_THEME_REGULAR(19)];
    [self.txtVehicleName setFont:FONTS_THEME_REGULAR(14)];
    [_txtSelectYear setFont:FONTS_THEME_REGULAR(14)];
    [_txtSelectCategory setFont:FONTS_THEME_REGULAR(14)];
    [_txtLicenseNumber setFont:FONTS_THEME_REGULAR(14)];
    [self.txtCity setFont:FONTS_THEME_REGULAR(14)];
}
-(void)setBorder:(UIView *)view{
    
    view.layer.borderWidth=1;
    view.layer.cornerRadius =2;
    view.layer.borderColor = [UIColor colorNamed:@"color_app_gray"].CGColor;
    [view clipsToBounds];
    
}

-(void) updateDocumentDetail{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    strProfileImagepath=[dict objectForKey:P_DRIVER_PROFILE_IMAGE_PATH];
    self.lblUserName.text =  [NSString stringWithFormat:@"%@ %@",[dict objectForKey:P_FNAME],[dict objectForKey:P_LNAME]];
    if (strProfileImagepath.length>0) {
        [self.imageProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, strProfileImagepath]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
        
    }else{
        self.imageProfile.image =[UIImage imageNamed:@"Profile Icon Crop Image"];
    }
    strCarImagepath =[dict objectForKey:@"d_car_image_path"];
    
    UIImage *imageTinit =[[UIImage imageNamed:@"google-docs"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imgCarImage.tintColor = [UIColor colorNamed:@"color_icon_tint"];
    if (strCarImagepath.length>0) {
        [self.imgCarImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images,strCarImagepath]] placeholderImage:imageTinit ];
    }else{
        self.imgCarImage.image=imageTinit;
    }
    selectedCatID=[NSString stringWithFormat:@"%d",[[dict objectForKey:P_CATEGORY_ID] intValue]];
    selectedCityId=[NSString stringWithFormat:@"%d",[[dict objectForKey:P_CITY_ID] intValue]];
    if([selectedCityId intValue]==0){
        if([self getFilteredCities].count==1){
            [self.viewCity hideByHeight:YES];
            CityModel * cityModel=[self getFilteredCities].firstObject;
            selectedCityId=  [NSString stringWithFormat:@"%d",cityModel.city_id];
            selectedCatID=@"";
            [self.txtSelectCategory   setItemList:nil];
            [self getCarCategory:selectedCityId];
        }else{
            if([self->selectedCityId intValue]>0) {
                [self getCarCategory:self-> selectedCityId];
            }
        }
    }
    NSString * vehicleName=[dict objectForKey:P_CAR_NAME];
    [self.txtVehicleName setText:vehicleName];
    
    NSString *  vehicleModel=[dict objectForKey:P_CAR_MODEL];
    [self.txtVehicleModel setText:vehicleModel];
    
    NSString * vehicleColor= [dict objectForKey:@"car_color"];
    self.txtVehicleColor.text = vehicleColor;
    
    NSString * vehicleMFGYear= [dict objectForKey:P_CAR_MAKE];
    [self.txtSelectYear setText:vehicleMFGYear];
    
    
    carPlateNumber  = [dict objectForKey:P_CAR_LICENSE_NUMBER];
    self.txtLicenseNumber.text =carPlateNumber;
    
    if (catArray.count>0) {
        
        [self setSelectCategory];
    }
}

-(BOOL)  isValidDocUploaded
{
    
    
    
    
    //    if (strrcpath.length ==0) {
    //        [self showAlert: [LanguageHelper getStringWithKey:@"k_33_s8_add_driver_permit"]];
    //        return NO;
    //    }
    //    if (strlpath.length ==0) {
    //        [self showAlert: [LanguageHelper getStringWithKey:@"k_34_s8_add_copy"]];
    //        return NO;
    //    }
    //
    //    if (strinsurance.length ==0) {
    //        [self showAlert: [LanguageHelper getStringWithKey:@"k_35_s8_add_vehicle_insurance"]];
    //        return NO;
    //    }
    
    
    
    
    return YES;
}


-(void) showAlert:(NSString *) message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        //[self dismissViewControllerAnimated:YES completion:nil];
    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)ButtonNext:(id)sender {
    if(isNextTapVehcleInfo==NO)  {
        for (UploadDocView * docs in docArray) {
            NSDictionary * dictValidate=[docs validateDocsData];
            if(dictValidate!=nil){
                [self showAlert:[LanguageHelper getStringWithKey:[dictValidate objectForKey:@"server_value"]]];
                return;
            }
        }
        self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_11_s7_vehicle_details"];
        [self updateDocumentDetail];
        self.viewDocumentHeight.constant=0;
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        self.viewScrollDocs.hidden = YES;
        self.viewScrollVehicleInfo.hidden = NO;
        isNextTapVehcleInfo=YES;
        if(self.isfromProfile)  {
            [self.btnNext setTitle: [LanguageHelper getStringWithKey:@"k_34_s6_save"]   forState:UIControlStateNormal];
        }
        return;
    }
    if(![self isValidDocUploaded])
    {
        //       return;
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if(strProfileImage==nil) {
        if (strProfileImagepath.length==0){
            [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_18_s2_plz_add_profile_picture"]];
            return;
        }
    }
    if ([selectedCityId intValue] ==0){
        [self showAlert:[LanguageHelper getStringWithKey:@"k_16_s7_please_select_city"]];
        return;
    }
    if ([selectedCatID intValue] ==0){
        [self showAlert:[LanguageHelper getStringWithKey:@"k_17_s7_please_select_car_category"]];
        return;
    }
    else if (self.txtVehicleName.text.length ==0){
        [self showAlert:[LanguageHelper getStringWithKey:@"k_49_s7_select_car_type"]];
        return;
    }
    else if (self.txtVehicleModel.text.length ==0 ){
        [self showAlert:[LanguageHelper getStringWithKey:@"k_19_s7_please_select_your_car_model_first"]];
        return;
    }
    else if (self.txtVehicleColor.text.length ==0 ){
        [self showAlert:[LanguageHelper getStringWithKey:@"k_19_s7_please_select_your_car_color_first"]];
        return;
    }
    else if ( self.txtSelectYear.text.length ==0){
        [self showAlert:[LanguageHelper getStringWithKey:@"k_20_s7_please_select_year_first"]];
        return;
    }
    else if (_txtLicenseNumber.text.length==0) {
        [self showAlert:[LanguageHelper getStringWithKey:@"k_50_s7_enter_lic_number"]];
        return;
    }
    if(strCarImage==nil) {
        if (strCarImagepath.length==0)    {
            [self showAlert:[LanguageHelper getStringWithKey:@"k_r42_s8_plz_upld_car_img"]];
            return;
        }
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID               :[dict1 objectForKey:P_DRIVER_ID],
        P_CAR_LICENSE_NUMBER   :_txtLicenseNumber.text,
        P_CATEGORY_ID           :selectedCatID,
    }];
    if(strCarImage!=nil) {
        [dict setObject:strCarImage forKey:@"car_image"];
    }
    if(strProfileImage!=nil){
        [dict setObject:strProfileImage forKey:@"driver_image"];
        [dict setObject:@"jpg" forKey:@"image_type"];
    }
    [dict setObject:self.txtVehicleName.text forKey:P_CAR_NAME];
    [dict setObject:self.txtVehicleModel.text forKey:P_CAR_MODEL];
    [dict setObject:self.txtSelectYear.text forKey:P_CAR_MAKE];
    [dict setObject:isEmpty(selectedCityId) forKey:P_CITY_ID];
    [dict setObject:self.txtVehicleColor.text forKey:@"car_color"];
    NSString * carId=[dict1 objectForKey:P_CAR_ID];
    if(carId.length>0)  {
        [dict setObject:isEmpty(carId) forKey:P_CAR_ID];
    }
    ConstantModel *constant=[ConstantModel getConstantsObject];
    if(self.isfromProfile)  {
        if([constant getCValueFK:ckey_adv]) {
            if([self isAnyChangeDetected]){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_22_s7_alert_on_city_or_category_change"]
                                                                                         message:[LanguageHelper getStringWithKey:@"k_23_s7_alert_message_on_city_or_category_change"]
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                    [dict setObject:@"0" forKey:P_DRIVER_VERIFIED];
                    [dict setObject:@"0" forKey:P_DRIVER_AVAILAILITY];
                    [self updateProfileWithDict:dict];
                }];
                [alertController addAction:actionOk];
                UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertController addAction:actionCancel];
                [self presentViewController:alertController animated:YES completion:nil];
            }else
            {
                [self updateProfileWithDict:dict];
            }
        }else{
            if([constant getCValueFK:ckey_adv]){
                [dict setObject:@"0" forKey:P_DRIVER_VERIFIED];
                [dict setObject:@"0" forKey:P_DRIVER_AVAILAILITY];
            }else{
                NSString *tripId = defaults_object(@"trip_id");
                if(tripId==nil) {
                    [dict setObject:@"1" forKey:P_DRIVER_VERIFIED];
                    [dict setObject:@"1" forKey:P_DRIVER_AVAILAILITY];
                }
            }
            [self updateProfileWithDict:dict];
        }
    }
    else {
        if([constant getCValueFK:ckey_adv]){
            [dict setObject:@"0" forKey:P_DRIVER_VERIFIED];
            [dict setObject:@"0" forKey:P_DRIVER_AVAILAILITY];
        }else{
            NSString *tripId = defaults_object(@"trip_id");
            if(tripId==nil) {
                [dict setObject:@"1" forKey:P_DRIVER_VERIFIED];
                [dict setObject:@"1" forKey:P_DRIVER_AVAILAILITY];
            }
        }
        [self updateProfileWithDict:dict];
    }
}
-(BOOL) isAnyChangeDetected{
    if(strProfileImage.length>0){
        return YES;
    }
    NSDictionary * dict1 = defaults_object(P_USER_DICT);
    if((![selectedCatID isEqualToString:[dict1 objectForKey:P_CATEGORY_ID]])||(![selectedCityId isEqualToString:[NSString stringWithFormat:@"%ld",(long)[UserProfile shared].cityID]])){
        return YES;
    }
    if(![self.txtVehicleName.text isEqualToString:[dict1 objectForKey:P_CAR_NAME]]){
        return YES;
    }
    if(![self.txtVehicleModel.text isEqualToString:[dict1 objectForKey:P_CAR_MODEL]]){
        return YES;
    }
    if(![self.txtVehicleColor.text isEqualToString:[dict1 objectForKey:@"car_color"]]){
        return YES;
    }
    if(![self.txtSelectYear.text isEqualToString:[dict1 objectForKey:P_CAR_MAKE]]){
        return YES;
    }
    if(![self.txtLicenseNumber.text isEqualToString:[dict1 objectForKey:P_CAR_LICENSE_NUMBER]]){
        return YES;
    }
    if(strCarImage.length>0){
        return YES;
    }
    return NO;
}


-(void) updateProfileWithDict:(NSMutableDictionary *)dict{
    [dict setObject:@"1" forKey:@"is_driver" ];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    NSDictionary *dictLogged = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    [dict setObject:[dictLogged objectForKey:P_USER_ID] forKey:@"usr_ref_id"];
    [GIC mkwerwu:UPDATE_DRIVER_PROFILE
               d:dict
              cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if(error!=nil){
            [Utilities handleError:error viewController:self defaultMessage:@"Internet Error"];
            return ;
        }
        if ([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]) {
            NSObject * dictResponse=[results objectForKey:P_RESPONSE];
            NSDictionary * dictUser;
            if([dictResponse isKindOfClass:[NSDictionary class ]]) {
                dictUser= (NSDictionary *)dictResponse;
            }else{
                dictUser = [((NSArray *)dictResponse) objectAtIndex:0];
            }
            defaults_set_object(P_USER_DICT, dictUser);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_category_notification" object:nil];
            if (self.isfromProfile) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                [self updateDeviceToken];
            }
        }
        else{
            [self showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_35_s2_car_registered"]];
        }
    }];
}


-(void)updateDeviceToken{
    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    [self navigateHome];
}


-(void)navigateHome{
    BOOL isSingleMode=  [[[NSUserDefaults standardUserDefaults] objectForKey:P_IS_SINGLE_MODE] boolValue];
    if(isSingleMode){
        [self loadInitailViewController:@[[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC],[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_SINGLE_VC]]];
    }else{
        [self loadUserHomeViewController];
    }
}


- (IBAction)ButtonBackAction:(id)sender {
    if( isNextTapVehcleInfo)
    {
        self.imgCarImage.image=nil;
        strCarImage=nil;
        isNextTapVehcleInfo=NO;
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        self.viewDocumentHeight.constant=calcualatedHeight;
//        [self.viewVehicleInfo setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        self.viewScrollDocs.hidden = NO;
        self.viewScrollVehicleInfo.hidden = YES;
        self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_3_s6_upload_doc"];
        [self.btnNext setTitle: [LanguageHelper getStringWithKey:@"k_14_s7_next"]   forState:UIControlStateNormal];
    }else
    {
        [self.navigationController popViewControllerAnimated:YES];
//        [self.btnNext setTitle: [LanguageHelper getStringWithKey:@"k_34_s6_save"]   forState:UIControlStateNormal];
    }
    
}

-(void)getCarCategory:(NSString * )cityId{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:isEmpty(cityId) forKey:P_CITY_ID];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:CAR_GETCATEGORY    d:dict     isa:NO cb:^(id results, NSError *error) {
        self->apiCallAttempt++;
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
            // success
            if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]])
            {
                NSMutableArray *arrCat = [[NSMutableArray alloc]initWithArray:[results objectForKey:P_RESPONSE]];
                NSArray *sortedArray;
                sortedArray = [arrCat sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDictionary *first = (NSDictionary*)a ;
                    NSDictionary *second = (NSDictionary*)b;
                    int orderFirst=[[first objectForKey:@"sort_order"] intValue];
                    int secondFirst=[[second objectForKey:@"sort_order"] intValue];
                    return orderFirst>secondFirst;
                    
                }];
                defaults_set_object(@"categoryResponse", sortedArray);
                self->catArray =sortedArray;
                [self setSelectCategory];
            }
        }
        else{
            
            if(self->apiCallAttempt<3){
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                [self getCarCategory:cityId];
            }
            
        }
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }];
}




-(UIImage*)imageWithImageScale: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImage *resizeImage= [Utilities imageWithImageHeight:chosenImage scaledToWidth:1024 scaledToHeight:1024];
        NSString *strImage =[Utilities encodeImageToBase64String:resizeImage];
      
        if(isCarImage) {
            self.imgCarImage.image=resizeImage;
            strCarImage=strImage;
            return;
        }else if(isProfileImageTabed){
            self.imageProfile.image=resizeImage;
            strProfileImage=strImage;
        }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    self->isProfileImageTabed = NO;
    self->isCarImage=NO;
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)editingInfo{
    self->isProfileImageTabed = NO;
    self->isCarImage=NO;
}

-(NSString *)encodeImageToBase64String:(UIImage *)image
{
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



#pragma mark - Picker
-(void)textField:(nonnull IQDropDownTextField*)textField didSelectItem:(nonnull NSString*)item {
    
    
    if (textField.tag ==4){
        for (NSDictionary *dic in catArray) {
            if ([[dic objectForKey:@"cat_name"] isEqualToString:item]) {
                selectedCatID=  [NSString stringWithFormat:@"%d",[[dic objectForKey:P_CATEGORY_ID] intValue]];
                return;
            }
            else{
                selectedCatID = @"";
            }
        }
        
    }else  if (textField.tag ==10){
        
        
        for (CityModel *dic in [self getFilteredCities]) {
            
            if ([dic.city_name isEqualToString:item]) {
                selectedCityId=  [NSString stringWithFormat:@"%d",dic.city_id];
                selectedCatID=@"";
                [self.txtSelectCategory   setItemList:nil];
                [self.txtSelectCategory setSelectedItem:@""];
                [self getCarCategory:selectedCityId];
                return;
            }
            else{
                
                selectedCityId = @"";
            }
        }
        
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField ==self.txtSelectYear && textField.text.length >= 4 && range.length == 0)
    {
        return NO; // return NO to not change text
    }
    else
    {
        return YES;
        
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.txtVehicleName){
        [self.txtVehicleModel becomeFirstResponder];
        
    }
    else if (textField == self.txtVehicleModel){
        
        [self.txtSelectYear becomeFirstResponder];
        
    }
    else if (textField == self.txtSelectYear){
        
        [self.txtLicenseNumber becomeFirstResponder];
        
    }
    else if (textField == self.txtLicenseNumber){
        
        [self.txtLicenseNumber resignFirstResponder];
        
    }
    return YES;
}

-(void)setCustomDoneTarget:(nullable id)target action:(nullable SEL)action{
    
}

-(void)textFieldDone{
    
    
    
}

-(void)text:(UITextField *)textField{
    if (textField.tag == 7) {
        carPlateNumber= textField.text;
    }
    else if (textField.tag ==3){
        //        selectedCarType =textField.text;
    }
    else if (textField.tag ==4){
        //        selectedCar =textField.text;
    }
    
}
- (IBAction)ButtonSelectImage:(UIButton *)sender {
    isCarImage=NO;
    [self openOptionForUploadDocument:sender];
    
}


-(void)openCheckPermission:(BOOL) isCamera{
    [UIImagePickerController obtainPermissionForMediaSourceType:isCamera?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary withSuccessHandler:^{
        UIImagePickerController *pickerNavController = [[UIImagePickerController alloc] init];
        pickerNavController.delegate = self;
//        pickerNavController.allowsEditing = YES;
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

- (void)openSelected:(UIButton *)sender isCamrea:(BOOL)isCamrea {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
//    picker.allowsEditing = YES;
    if(isCamrea) {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])   {
            //             picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            [self showAlert:[LanguageHelper getStringWithKey:@"k_32_s6_camera_permission_error"] title:@""];
            return;
        }
    }else {
        //          picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if (sender.tag ==2) {
        isCarImage=NO;
        isProfileImageTabed = YES;
    }else{
        isCarImage=YES;
        isProfileImageTabed = NO;
    }
    
    [self openCheckPermission:isCamrea];
}




-(void) openOptionForUploadDocument:(UIButton *)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_r18_s5_chse_img"]
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionCamera= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_28_s6_camera_j"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
        [self openSelected:sender isCamrea:YES];
    }];
    UIAlertAction *actionGallery= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_29_s6_gallery_j"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        [self openSelected:sender isCamrea:NO];
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


-(void)setSelectCategory{
    NSArray *arrCat1  =[catArray valueForKey:@"cat_name"] ;
    _txtSelectCategory.isOptionalDropDown = YES;
    _txtSelectCategory.optionalItemText = [LanguageHelper getStringWithKey:@"k_31_s7_select_category"];
    [_txtSelectCategory setItemList:arrCat1];
    [_txtSelectCategory setText:@""];
    for (NSDictionary *dic in catArray) {
        if ([[NSString stringWithFormat:@"%d",[[dic objectForKey:P_CATEGORY_ID] intValue]] isEqualToString:selectedCatID]) {
            [_txtSelectCategory setSelectedItem:[dic objectForKey:@"cat_name"]];
        }
    }
}



-(void) uploadDocuments:(UIImage *) resizeImage imageType:(NSString *)imageType{
    NSString *strImage =[Base64 encode:UIImagePNGRepresentation(resizeImage)];
    NSMutableDictionary *dict1 = [[[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT] mutableCopy];
    NSString *driverId=[dict1 objectForKey:P_DRIVER_ID];
    if(driverId==nil){
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID           :[dict1 objectForKey:P_DRIVER_ID],
        @"image_type"         :imageType,
        @"driver_image"    :strImage,
    }];
    [GIC mkwerwu:ADD_DRIVER_ASSET   d:dict   cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
        }
        else{
            if( error !=nil)  {
                [Utilities handleError:error viewController:self defaultMessage:@"Internet Error"];
                return;
            }
        }
    }];
}




-(void) getAssets{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    [dict setObject:isEmpty([dict1 objectForKey:P_DRIVER_ID]) forKey:P_DRIVER_ID];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:GET_DRIVER_ASSET
            d:dict
          isa:NO
           cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]])  {
            NSArray *arrayAssets=[results objectForKey:P_RESPONSE];
            for (UploadDocView *  uploadDocs in self->docArray) {
                [uploadDocs  handleDocsData:arrayAssets];
            }
        }
    }];
}



- (IBAction)onCarImageButTap:(UIButton *)sender {
    [self.view endEditing:YES];
    isCarImage=YES;
    sender.tag=4;
    [self openOptionForUploadDocument:sender];
}





-(NSMutableArray *) getFilteredCities{
    NSArray *array=[APP_DELEGATE arrayCities];
    NSMutableArray * arrayFiltered = [[NSMutableArray alloc]  init];
    NSDictionary * dict=defaults_object(P_USER_DICT);
    int   cityId = [[dict objectForKey:P_P_CITY_ID] intValue];
    for (CityModel * city in array) {
        if (city.parent_id == cityId) {
            [arrayFiltered addObject:city];
        }
    }
    return arrayFiltered;
}

-(void)setSelectCity{
    NSMutableArray *arrCity=[[NSMutableArray alloc] init];
    NSArray * arrayFiltered =[self getFilteredCities];
    for (CityModel * city in arrayFiltered) {
        [arrCity addObject:city.city_name];
    }
    _txtCity.isOptionalDropDown = YES;
    _txtCity.optionalItemText = [LanguageHelper  getStringWithKey:@"k_18_s6_city" defaultValue:@"City"];
    [_txtCity setItemList:arrCity];
    
    for (CityModel *dic in arrayFiltered) {
        if (dic.city_id ==[selectedCityId intValue]) {
            [_txtCity setSelectedItem:dic.city_name];
        }
    }
}
-(UIView *) getParentView{
    return self.view;
}

- (IBAction)onEditImageButtonTap:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_r18_s5_chse_img"]
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCamera= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_28_s6_camera_j"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])    {
            self->isProfileImageTabed = YES;
            self->isCarImage = NO;
            [self openCheckPermission:YES];
        }else{
            [self openCamerNotAlert ];
        }
    }];
    UIAlertAction *actionGallery= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_29_s6_gallery_j"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        self->isProfileImageTabed = YES;
        self->isCarImage = NO;
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

-(void) uploadDriverProfileImage:(UIImage *) chosenImage{
    UIImage *resizeImage= [Utilities imageWithImageHeight:chosenImage scaledToWidth:300 scaledToHeight:300 ];
//    NSString *strImage =[Utilities encodeImageToBase64String:resizeImage ];
//    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
//    NSDictionary * dictM=@{@"api_key":[dict1 objectForKey:P_API_KEY],P_DRIVER_ID:[dict1 objectForKey:P_DRIVER_ID],@"image_type":@"jpg",@"driver_image":strImage};
//    NSMutableDictionary *dict=[dictM mutableCopy];
//    NSDictionary *dictLogged = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
//    [dict setObject:[dictLogged objectForKey:P_USER_ID] forKey:@"usr_ref_id"];
//    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
//    [GIC mkwu:UPDATE_DRIVER_PROFILE  d:dict   isa:NO   cb:^(id results, NSError *error) {
//        if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"])  {
//            defaults_set_object(P_USER_DICT,[results objectForKey:P_RESPONSE] );
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_profile" object:nil];
//            NSString *profile=[[results objectForKey:P_RESPONSE] objectForKey:P_DRIVER_PROFILE_IMAGE_PATH];
//            if (profile.length>0) {
//                [self.imageProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
//            }
//        }
//        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
//    }];
}
- (IBAction)onSelectCarBrands:(id)sender {
    [self addTapGesture];
    dropDownBtnSelected=sender;
    CGPoint origin = [self.view convertPoint:CGPointZero fromView:sender];
    BOOL isDown;
    CGRect frame;
    isDown=YES;
    NSString * brands = [[ConstantModel getConstantsObject] car_brands];
    NSArray * arrLanguages =[brands  componentsSeparatedByString:@"|"];
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    for (NSString * name in arrLanguages) {
        CityModel *city=[[CityModel alloc] init];
        city.city_name=name;
        [arr addObject:city];
    }
    NSArray * arrImage = [[NSArray alloc] init];
    CGFloat f =120;
    if(arr.count<6){
        f=arr.count*40;
    }
    frame=CGRectMake(SCREEN_WIDTH-220, origin.y+40, 200,f);
    if(dropDown == nil) {
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down" view:self.view frame: frame up:isDown isLeftAligin:YES];
        dropDown.delegate = self;
        dropDown.tag=100;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown=nil;
    }
}
- (IBAction)onSlelecMFgYear:(id)sender {
    [self addTapGesture];
    dropDownBtnSelected=sender;
    CGPoint origin = [self.view convertPoint:CGPointZero fromView:sender];
    BOOL isDown;
    CGRect frame;
    isDown=YES;
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:now];
    int currentYear = (int) [components year];
    for (int i = currentYear; i> 1970 ; i-- ) {
        CityModel *city=[[CityModel alloc] init];
        city.city_name=[NSString stringWithFormat:@"%d",i];
        [arr addObject:city];
    }
    NSArray * arrImage = [[NSArray alloc] init];
    CGFloat f =120;
    if(arr.count<6){
        f=arr.count*40;
    }
    frame=CGRectMake(SCREEN_WIDTH-150, origin.y+40, 130,f);
    if(dropDown == nil) {
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down" view:self.view frame: frame up:isDown isLeftAligin:YES];
        dropDown.delegate = self;
        dropDown.tag=200;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown=nil;
    }
}
-(void) addTapGesture{
    gestureBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [gestureBg setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.4]];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandlerMethod:)];
    [gestureBg addGestureRecognizer:tapRecognizer];
    [self.view addSubview:gestureBg];
}

-(void) remoeGesture{
    [gestureBg  removeGestureRecognizer:tapRecognizer];
    [gestureBg removeFromSuperview];
}


-(void)gestureHandlerMethod:(UITapGestureRecognizer*)recognizer {
    [self remoeGesture];
    [dropDown hideDropDown:dropDownBtnSelected];
    dropDown=nil;
}
- (void) niDropDownDelegateMethod: (NIDropDown *) sender index:(int) index  result:(id) resullt{
    [self remoeGesture];
    CityModel *  cityModel=(CityModel *)resullt;
    if(sender.tag==100){
        self.txtVehicleName.text=cityModel.city_name;
    }else{
        self.txtSelectYear.text=cityModel.city_name;
    }
    dropDown=nil;
}
@end
