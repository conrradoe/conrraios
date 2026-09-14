//
//  BaseViewController.m

//
//  Created by Grepix on 27/11/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "BaseViewController.h"
#import "LanguageHelper.h"
#import "MainViewController.h"
#import "UMainViewController.h"
#import "HomeViewController.h"
#import "UHomeViewController.h"
#import "CheckAppUpdateVersion.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "AboutUsViewController.h"
#import "SettingsModel.h"
#import "BeginTripViewController.h"
@interface BaseViewController ()<MFMailComposeViewControllerDelegate,CheckAppUpdateVersionDelegate>

@end

@implementation BaseViewController
{
    CheckAppUpdateVersion *checkAppUpdateVersion;
}
- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)checkAndShowAlertWith{
    checkAppUpdateVersion = [[CheckAppUpdateVersion alloc] init ];
    checkAppUpdateVersion.delegate = self;
    [ checkAppUpdateVersion checkAndShowAlertWith:[ConstantModel getConstantsObject]];
}

-(void)openAlertViewController:(UIAlertController *)alertViewController{
    [self presentViewController:alertViewController animated:YES completion:^{
        
    }];
}

-(void) showWarningWithMessgae:(NSString *) message
{
    [self showAlert:[LanguageHelper getStringWithKey:@"k_23_s3_warning"] message:message];
}
-(void) showAlertWithMessgae:(NSString *) message
{
    [self showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:message];
}

-(void) showAlert:(NSString *) title message:(NSString *) message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil]; //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(UIAlertController *) showAlertWithOk:(NSString *) title message:(NSString *) message  handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

-(void) loadUserHomeViewController{
    BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
    if(is_user_login){
        [self loadUserInitailViewController:@[[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UHOME_VC]]];
    }else{
        [self loadHomeViewController];
    }
}

-(void) loadHomeViewController{
    [self loadHomeViewController:NO];
}


-(void) loadHomeViewController:(BOOL) isFromLoading{
    HomeViewController *vc=(HomeViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC ];
    vc.isRegireToLoadCities=isFromLoading;
    [self loadInitailViewController:@[vc]];
}

-(void) loadUserInitailViewController:(NSArray *) viewControllers
{
    UINavigationController *navigationController = [StoryBoardUtiles navigationHome];
    [navigationController setViewControllers:viewControllers];
    UMainViewController *mainViewController =(UMainViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UMAIN_VC ];
    mainViewController.rootViewController = navigationController;
    [mainViewController setupWithType:2];
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    window.rootViewController = mainViewController;
    [UIView transitionWithView:window
                      duration:0.1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}


-(void) loadInitailViewController:(NSArray *) viewControllers
{
    UINavigationController *navigationController = [StoryBoardUtiles navigationHome];
    [navigationController setViewControllers:viewControllers];
    MainViewController *mainViewController =(MainViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.MAIN_VC ];
    mainViewController.rootViewController = navigationController;
    [mainViewController setupWithType:2];
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    window.rootViewController = mainViewController;
    [UIView transitionWithView:window
                      duration:0.1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}

-(void)setTextFieldPlaceholderColor:(UITextField*)textField color:(UIColor*) color{
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(textField, ivar);
    placeholderLabel.textColor =color;
}

-(void) showAlertWithButtonTitle:(NSString *) btTitle title:(NSString*)title message:(NSString *) message  handler:(void (^ __nullable)(UIAlertAction *action))handler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:btTitle
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)setTextFieldPlaceholderColor:(UITextField*)textField{
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(textField, ivar);
    placeholderLabel.textColor = [UIColor colorWithRed:114/255.0f green:114/255.0f blue:114/255.0f alpha:1.0f]; // #727272
}


-(void) roundViewWithBorder:(UIView *) view{
    [view.layer setBorderWidth:1];
    [view.layer setCornerRadius:5];
    [view setClipsToBounds:YES];
    [view.layer setBorderColor:[UIColor colorNamed:@"color_border"].CGColor];
    
}

-(void) mapRegion:(MKCoordinateRegion ) region mapView:(MKMapView *)mapView{
    @try {
        [mapView setRegion:[mapView regionThatFits:region] animated:NO];
    } @catch (NSException *exception) {
        if( region.center.longitude > -89 && region.center.longitude < 89 && region.center.longitude > -179 && region.center.longitude < 179 ){
        [mapView setRegion:[mapView regionThatFits:region] animated:NO];
        }
    } @finally {
    }
}

-(void) stopOldLocationUpdate{
     
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if([vc isKindOfClass:[HomeViewController class]]){
            HomeViewController *homeVc=(HomeViewController *) vc;
            [homeVc stopLocationUpdate];
        } else if([vc isKindOfClass:[UHomeViewController class]]){
            UHomeViewController *homeVc=(UHomeViewController *) vc;
            [homeVc stopLocationUpdate];
        }
        else if([vc isKindOfClass:[BeginTripViewController class]]){
            BeginTripViewController *homeVc=(BeginTripViewController *) vc;
            [homeVc stopLocationUpdate];
        }
    }
}
-(void)setUpMDCBaseTextField:(MDCBaseTextField *)textField{
    textField.font=FONTS_THEME_REGULAR(18);
    [textField setNormalLabelColor:[UIColor colorNamed:@"app_edit_label_color"] forState:MDCTextControlStateNormal];
    [textField setFloatingLabelColor:[UIColor colorNamed:@"app_edit_label_color"] forState:(MDCTextControlStateNormal)];
    textField.textColor=[UIColor colorNamed:@"color_app_label"];
}


-(void)openMailComposer{
    if([ConstantModel getConstantsObject].enable_chat){
        
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_11_s4_a1_contact_us"] message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction
                          actionWithTitle:[LanguageHelper getStringWithKey:@"k_11_s4_email_us"]
                                    style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * _Nonnull action) {
            [self openMailComposerOpen];
            
        }]];
        [alert addAction:[UIAlertAction
                          actionWithTitle:[LanguageHelper getStringWithKey:@"k_11_s4_chat_us"]
                                    style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * _Nonnull action) {
            AboutUsViewController *viewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
            viewController.isCustomUrl=YES;
            viewController.customTitle=[LanguageHelper getStringWithKey:@"k_11_s4_chat_us"];
            viewController.customUrl=isEmpty([SettingsModel getSettignsObject].enable_chat);
            [self .navigationController pushViewController:viewController animated:YES];
        }]];
        [alert addAction:[UIAlertAction
                          actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"]
                                    style:UIAlertActionStyleCancel
                          handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }else{
        [self openMailComposerOpen];
    }
}
-(void)openMailComposerOpen{

    
    
if([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
    mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
    ConstantModel *  constantModel =[ConstantModel getConstantsObject];;
    NSString * supportEmail = isEmpty(constantModel.support_email);
    NSMutableArray  *arrayEmails=[[NSMutableArray alloc]  init];
    [arrayEmails addObject:supportEmail];
    [mailCont setToRecipients:arrayEmails];
    /*
     [mailCont setSubject:@""];
     NSMutableString *body = [NSMutableString string];
     NSString *url = [NSString stringWithFormat:@"http://maps.google.com?q=%f,%f",[APP_DELEGATE currLoc].latitude,[APP_DELEGATE currLoc].longitude];
     [body appendString:[NSString stringWithFormat:@"Please help, I am in danger and need assistance.Follow my location,<a href=\"%@\">Click Here</a> \n ",url]];
     [mailCont setMessageBody:body isHTML:YES];
     */
    [self presentViewController:mailCont animated:YES completion:nil];
}else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlegmail://"]]){
    NSString * supportEmail = isEmpty([ConstantModel getConstantsObject].support_email);
    NSString *to = supportEmail;
    NSString *subject = [LanguageHelper getStringWithKey:@"k_9_s5_support_subject"];
    NSString *gmailURLString = [NSString stringWithFormat:@"googlegmail:///co?to=%@&subject=%@",
                                [to stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
                                [subject stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSURL *gmailURL = [NSURL URLWithString:gmailURLString];
    
    // Open the URL
    [[UIApplication sharedApplication] openURL:gmailURL options:@{} completionHandler:^(BOOL success) {
        if (!success) {
            NSLog(@"Failed to open Gmail app");
        }
    }];
}
else
{
    [UtilityClass swa:@"Whoops!" m:[LanguageHelper getStringWithKey:@"k_65_s4_config_mail"] cbt:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] obt:nil vc:self];
}
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
if(error!= nil)
{
    [self showAlert:@"Whoops!" message:[NSString stringWithFormat:@" ERROR %@",error]];
    return;
}
[controller dismissViewControllerAnimated:YES completion:nil];
}

-(void) showPleaseWaitLoader{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
}

-(void) hidePleaseWaitLoader{
    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
}

-(void) showLoadingLoader{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
}

-(void) hideLoadingLoader{
    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
}

-(BOOL)isRTL{
    return [UIView appearance].semanticContentAttribute==UISemanticContentAttributeForceRightToLeft;
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    if (@available(iOS 13.0, *)) {
        if([[ConstantModel getConstantsObject] getCValueFK:ckey_etld]){
            NSString * uiOri=defaults_object(@"app_mode");
            if(uiOri&&[uiOri isEqualToString:@"light"]){
                return UIStatusBarStyleDarkContent;
            }else  if(uiOri&&[uiOri isEqualToString:@"dark"]){
                return UIStatusBarStyleLightContent;
            }else  if(uiOri&&[uiOri isEqualToString:@"auto"]){
                NSDate *date = [NSDate date];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
                NSInteger hour = [components hour];
                if(hour<=DAY_START_HURS){
                    return  UIStatusBarStyleLightContent;
                }else if(hour>DAY_START_HURS&&hour<DAY_END_HURS){
                    return  UIStatusBarStyleLightContent;
                }else{
                    return  UIStatusBarStyleLightContent;
                }
            }else{
                return UIStatusBarStyleDarkContent;
            }
        }else{
            return UIStatusBarStyleDarkContent;
        }
    } else {
        // Fallback on earlier versions
    }
    return UIStatusBarStyleDefault;
}

-(BOOL)isDarkMode{
    if (@available(iOS 13, *)) {
        if([[ConstantModel getConstantsObject] getCValueFK:ckey_etld]){
            NSString * uiOri=defaults_object(@"app_mode");
            if(uiOri&&[uiOri isEqualToString:@"light"]){
                return NO;
            }else  if(uiOri&&[uiOri isEqualToString:@"dark"]){
                return YES;
            }else  if(uiOri&&[uiOri isEqualToString:@"auto"]){
                NSDate *date = [NSDate date];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
                NSInteger hour = [components hour];
                if(hour<=DAY_START_HURS){
                    return YES;
                }else if(hour>DAY_START_HURS&&hour<DAY_END_HURS){
                    return NO;
                }else{
                    return YES;
                }
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    }
    return NO;
}

-(void)applyGrayTintOnImageView:(UIImageView*)imageview{
    UIImage *img = [imageview.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    imageview.tintColor = [UIColor colorNamed:@"color_gray_tint"];
    imageview.image = img;
}
-(void)applyTintOnButton:(UIButton*)button iconName:(NSString *)iconName{
    UIImage *img = [[UIImage imageNamed:iconName] imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    button.tintColor = [UIColor colorNamed:@"color_gray_tint"];
    [button setImage:img forState:(UIControlStateNormal)];
}

@end

