//
//  ChangePasswordViewController.m
//  HireMe Rider
//
//  Created by Grepix Infotech on 01/01/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "EditProfileViewController.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "Utilities.h"
#import "ConstantModel.h"
@interface ChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end

@implementation ChangePasswordViewController
{
    ConstantModel *  constantTaxiModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    constantTaxiModel =[ConstantModel getConstantsObject];;
    [self setUIFields];
    if(self.isRestPassword) {
        [self.lbHeader setText:[LanguageHelper getStringWithKey:@"k_19_s6_update_password"]];
    }
    [self.nPassView.layer setBorderWidth:1];
    [self.nPassView.layer setCornerRadius:2];
    [self.nPassView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.nPassView setClipsToBounds:YES];
    [self.cPassView.layer setBorderWidth:1];
    [self.cPassView.layer setCornerRadius:2];
    [self.cPassView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.cPassView setClipsToBounds:YES];
    [self setupTextField:_txtNewPassword];
    [self setupTextField:_txtConfirmPassword];
    [self.viewContainer.layer setCornerRadius:5];
    [self.viewContainer setClipsToBounds:YES];
}

-(void) setUIFields{
    self.lbHeader.text = [LanguageHelper getStringWithKey:@"k_19_s6_update_password"];
    self.lblNewPassword.text = [LanguageHelper getStringWithKey:@"k_21_s6_new_password"];
    self.lblConfirmPassword.text = [LanguageHelper getStringWithKey:@"k_13_s2_confirm_password"];
    self.txtNewPassword.placeholder    = [LanguageHelper getStringWithKey:@"k_21_s6_new_password"];
    self.txtConfirmPassword.placeholder    =[LanguageHelper getStringWithKey:@"k_14_s2_confirm_password_hint"];
    [self.btnSave setTitle: [LanguageHelper getStringWithKey:@"k_34_s6_save"]   forState:UIControlStateNormal];
}



- (IBAction)savePassword:(id)sender {
    if(self.isRestPassword)
    {
        if ([self checkUpdatePasswordValidity]){
            [self updateRestPassordPassword];
            return;
        } else {
            return;
        }
    }else{
        if ([self checkPasswordValidity]){
            return;
        } else {
            return;
        }
    }
}




-(BOOL)checkPasswordValidity{
    if (_txtNewPassword.text.length<constantTaxiModel.min_password_length){
        [self showAlertWithMessgae:[Utilities validPasswordMessage]];
        return NO;
    }
    if (_txtConfirmPassword.text.length<constantTaxiModel.min_password_length){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_23_s2_plz_enter_confirm_password"]];
        return NO;
    }
    else if (![_txtNewPassword.text isEqualToString:_txtConfirmPassword.text]){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_25_s2_password_not_match"]];
        return NO;
    }
    return YES;
}




-(BOOL) checkUpdatePasswordValidity{
     if (_txtNewPassword.text.length<constantTaxiModel.min_password_length){
         [self showAlertWithMessgae:[Utilities validPasswordMessage]];
        return NO;
    }
    if (_txtConfirmPassword.text.length<constantTaxiModel.min_password_length){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_23_s2_plz_enter_confirm_password"]];
        return NO;
    }
    else if (![_txtNewPassword.text isEqualToString:_txtConfirmPassword.text]){
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_25_s2_password_not_match"]];
        return NO;
    }
    return YES;
}



-(void)updateRestPassordPassword{
    if(self.dictUserRestPassword==nil) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY:[self.dictUserRestPassword objectForKey:P_API_KEY],
        P_DRIVER_ID          :[self.dictUserRestPassword objectForKey:P_DRIVER_ID],
        P_PASSWORD        : _txtNewPassword.text,
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:UPDATE_DRIVER_PROFILE
                  d:dict
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [self showAlertWithOk:@"" message:[LanguageHelper getStringWithKey:@"k_19_s6_update_password"] handler:^(UIAlertAction * _Nonnull action) {
                [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else{
            if(results!=nil){
                [self showAlertWithMessgae:[results objectForKey:P_MESSAGE]];
            }else{
                [Utilities handleError:error viewController:self defaultMessage:@"" ];
            }
        }
    }];
}



- (IBAction)btnBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)setupTextField:(UITextField*)textField{
    [self setTextFieldPlaceholderColor:textField];
}

@end
