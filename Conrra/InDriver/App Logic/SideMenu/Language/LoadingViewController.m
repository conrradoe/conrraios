//
//  LoadingViewController.m

//
//  Created by Grepix - Baij on 28/01/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "LoadingViewController.h"
#import "LanguageHelper.h"
#import "MainViewController.h"
#import "ConstantModel.h"
#import "CityModel.h"
#import "MultipleCallHandler.h"
#import "UIHelper.h"
#import "ConstantModel.h" 
#import "SettingsModel.h"
#import "UIImage+GIF.h"
@import Stripe;

@interface LoadingViewController ()<GIFDisplayHelperDeleage>

@end

@implementation LoadingViewController{
    BOOL isCalled;
    MultipleCallHandler *_multipleCallHandler;
    BOOL isSplashAnimationCompleted;
    BOOL isDataAnimationCompleted;
//    GIFDisplayHelper *dd;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[HandlingHelper sharedObject] startMonitoring];
    NSDictionary * dictVersion=[Utilities appBuildVersionAndOsInfo];
    [self.lblVersion setText:[NSString stringWithFormat:@"Version %@",isEmpty([dictVersion objectForKey:@"app_ver"])]];
    isSplashAnimationCompleted = YES;
//    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"splash_screen" ofType: @"gif"];
//    NSData *gifData = [NSData dataWithContentsOfFile: filePath];
//    EncodePolylineHelperSwift * en = [[EncodePolylineHelperSwift alloc] init];
//    NSArray *images= [en getFinaleWithImageData:gifData];
//    dd = [[GIFDisplayHelper alloc]  initWithImageView:self.imageBottom frames:images delegate:self];
//    [dd startAnimatingGIF];
}


//-(void)animationDone{
//    NSTimeInterval delayInSeconds = .6;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        self->isSplashAnimationCompleted = YES;
//        [self openSingin];
//    });
//}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadLanguageRefresh) name:@"network_connected" object:nil];
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) loadLanguageRefresh{
    [self loadAppRequireData:NO];
}



-(void) showAlertForRetryToLoadData{
    [self showAlertWithButtonTitle:[LanguageHelper getStringWithKey:@"k_18_s4_retry" defaultValue:@"Retry"] title:[LanguageHelper getStringWithKey:@"k_33_s7_alert" defaultValue:@"Alert !"] message:[LanguageHelper getStringWithKey:@"k_18_s4_api_retry_msg" defaultValue:@"Failed to load data due to slow network connection . Please check connection and Retry"] handler:^(UIAlertAction * _Nonnull action) {
        [self loadAppRequireData:YES];
    }];
}



-(void) loadAppRequireData:(BOOL) isShowLoader{
    if(isCalled){
        return;
    }
    isCalled=YES;
    _multipleCallHandler=[[MultipleCallHandler alloc] init ];
    // load get profile
    if(isShowLoader){
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    }
    [_multipleCallHandler addTaskWithCompleteBlock:^BOOL(taskCompleteBlock  _Nonnull blockAfterCompleteTask) {
        [[LanguageHelper sharedInstance] getLanguageFromServerWithCompletionBlock:^(id  _Nonnull results, NSError * _Nonnull error) {
            blockAfterCompleteTask(results, error,@"Language");
        }];
        return true;
    }];
   
    [self loadProfileIfLogin:_multipleCallHandler];
    [self loadAllInOne:_multipleCallHandler];
    [self loadCP:_multipleCallHandler];
    
    __weak typeof(self) tmpSelf = self;
    [_multipleCallHandler addAllTaskCompletedBlock:^(int completed, int failed, int total, NSArray *arrayFailure) {
        self->isCalled=NO;
        if(isShowLoader){
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
        }
        if(completed==total){
            [tmpSelf openSingin ];
        }else{
            BOOL isGetPrfileFailed=NO;
            BOOL is404=NO;
            for (NSDictionary * dict in arrayFailure) {
                NSString *type=[dict objectForKey:@"type"];
                if([type isEqualToString:@"GetProfile"]){
                    isGetPrfileFailed=YES;
                }else if([type isEqualToString:@"Language"]){
                    NSError * error= [dict objectForKey:@"error"];
                   is404=[tmpSelf checkErrorFor404:error];
                }
            }
            if(isGetPrfileFailed){
                [tmpSelf openSingin ];
            }else if(is404){
                [tmpSelf showAlertForUpdateApp];
            }else{
                [tmpSelf showAlertForRetryToLoadData];
            }
        }
    }];
    [_multipleCallHandler start];
}





-(void)loadProfileIfLogin:(MultipleCallHandler *)multipleCallHandler{
    NSString *apiKey =[[NSUserDefaults standardUserDefaults]objectForKey:P_API_KEY];
    if (apiKey.length==0) {
        return;
    }
    BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
    [multipleCallHandler addTaskWithCompleteBlock:^BOOL(taskCompleteBlock  _Nonnull blockAfterCompleteTask) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
            P_API_KEY :apiKey,
        }];
        [GIC mkwerwu:is_user_login?GET_USER_PROFILE :GET_DRIVER_PROFILE
                                        d:dict
                  cb:^(id results, NSError *error) {
            if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
                NSDictionary * userDict;
                if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class ]]){
                    userDict=[results objectForKey:P_RESPONSE];
                    defaults_set_object(P_USER_DICT, userDict);
                    if(is_user_login){
                        defaults_set_object(P_USER_DICT_LOGGED, [results objectForKey:P_RESPONSE]);
                    }
                }else {
                    if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class ]]) {
                        NSArray *arra=[results objectForKey:P_RESPONSE];
                        if(arra.count>0) {
                           userDict = [arra objectAtIndex:0];
                        }else {
                            defaults_remove(P_USER_DICT);
                            defaults_remove(P_API_KEY);
                            return ;
                        }
                    }else{
                        defaults_remove(P_USER_DICT);
                        defaults_remove(P_API_KEY);
                        return ;
                    }
                }
                defaults_set_object(P_API_KEY, [userDict objectForKey:P_API_KEY]);
                defaults_set_object(P_USER_DICT, userDict);
                if(is_user_login){
                    defaults_set_object(P_USER_DICT_LOGGED, userDict);
                }
                [self updateDeviceToken];
            }
            else{
                if(results!=nil){
                    if([[results objectForKey:@"code"] intValue]>=400){
                        defaults_remove(P_USER_DICT);
                        defaults_remove(P_API_KEY);
                    }
                }else{
                    NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
                    if(data){
                        NSError * jsonError=nil;
                        id json= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                        if([json isKindOfClass:[NSDictionary class]]){
                            if([[json objectForKey:@"code"] intValue]>=400){
                                defaults_remove(P_USER_DICT);
                                defaults_remove(P_API_KEY);
                            }
                        }
                    }
                }
            }
            blockAfterCompleteTask(results, error,@"GetProfile");
        }];
        return true;
    }];
}


-(void) loadCP:(MultipleCallHandler *)multipleCallHandler{
    [_multipleCallHandler addTaskWithCompleteBlock:^BOOL(taskCompleteBlock  _Nonnull blockAfterCompleteTask) {
        [GIC mkcwcb:^(id  _Nonnull results, NSError * _Nonnull error) {
            if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]){
                NSObject * response=[results objectForKey:P_RESPONSE];
                if([response isKindOfClass:[NSDictionary class]]){
                    defaults_set_object(@"constants_p", (NSDictionary *)response);
                    [[ConstantModel getConstantsObject] manageCP];
                }else if([response isKindOfClass:[NSArray class]]){
                    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                    for (NSDictionary *dict in (NSArray *)response) {
                        if([[dict objectForKey:@"bundleId"] isEqualToString:bundleIdentifier]){
                            defaults_set_object(@"constants_p", dict);
                            defaults_set_object(@"constants_p_backup", dict);
                            [[ConstantModel getConstantsObject] manageCP];
                            break;
                        }
                    }
                }
            }
            blockAfterCompleteTask(@{@"status":@"OK"}, nil,@"gp");
        }];
        return true;
    }];
}




-(void) loadAllInOne:(MultipleCallHandler *)multipleCallHandler{
    [_multipleCallHandler addTaskWithCompleteBlock:^BOOL(taskCompleteBlock  _Nonnull blockAfterCompleteTask) {
        NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
        if([ConstantModel getConstantsObject]){
//            [dict setObject:[NSString stringWithFormat:@"%d",[ConstantModel getConstantsObject].common_api_ver] forKey:@"ver"];
        }
        [GIC mkwerwu:API_GET_ALL_IN_ONE d:dict
                             cb:^(id results, NSError *error) {
            if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]){
                NSDictionary * dictReponse=[results objectForKey:P_RESPONSE];
                if([dictReponse isKindOfClass:[NSDictionary class]]){
                    //Constant
                    NSArray *constantData=[dictReponse objectForKey:@"Constant"];
                    if([constantData isKindOfClass:[NSArray class]]){
                        defaults_set_object(@"constantResponse", constantData);
                        ConstantModel *constantTaxiModel = [ConstantModel getConstantsObject];
                        [constantTaxiModel refreshObject];
                        defaults_set_object(@"google_key_server", isEmpty(constantTaxiModel.gKey));
                        if(constantTaxiModel.stripe_p_key.length>0){
                            STPAPIClient.sharedClient.publishableKey=constantTaxiModel.stripe_p_key;
                        }
                        //[GMSServices provideAPIKey:[APP_DELEGATE getGoogleKey]];
                    }
                    // Settings
                    NSArray *settingData=[dictReponse objectForKey:@"Setting"];
                    if([settingData isKindOfClass:[NSArray class]]){
                        defaults_set_object(@"settingResponse", settingData);
                        [[SettingsModel getSettignsObject] refreshObject];
                    }
                    
                    // City
                    NSArray *cityData=[dictReponse objectForKey:@"City"];
                    if([cityData isKindOfClass:[NSArray class]]){
                        defaults_set_object(@"city_repsponse", cityData);
                        NSMutableArray *arrayCities=[CityModel  parseCities:cityData];
                        AppDelegate * appdelegate=APP_DELEGATE;
                        appdelegate.arrayCities=arrayCities;
                    }
                    // Language
                    NSArray *languageData=[dictReponse objectForKey:@"Language"];
                    [[LanguageHelper sharedInstance] setLanguageListData:languageData];
                }else{
                    NSMutableArray *arrayCities=[CityModel  parseCities:defaults_object(@"city_repsponse")];
                    AppDelegate * appdelegate=APP_DELEGATE;
                    appdelegate.arrayCities=arrayCities;
                    NSArray *languageData=defaults_object(@"language_dict_list");
                    [[LanguageHelper sharedInstance] setLanguageListData:languageData];
                    ConstantModel *constantTaxiModel = [ConstantModel getConstantsObject];
                    defaults_set_object(@"google_key_server", isEmpty(constantTaxiModel.gKey));
                    if(constantTaxiModel.stripe_p_key.length>0){
                        STPAPIClient.sharedClient.publishableKey=constantTaxiModel.stripe_p_key;
                    }
                    //[GMSServices provideAPIKey:[APP_DELEGATE getGoogleKey]];
                }
            }else{
                ConstantModel *constantTaxiModel = [ConstantModel getConstantsObject];
                if(constantTaxiModel){
                    [constantTaxiModel refreshObject];
                    defaults_set_object(@"google_key_server", isEmpty(constantTaxiModel.gKey));
                    if(constantTaxiModel.stripe_p_key.length>0){
                        STPAPIClient.sharedClient.publishableKey=constantTaxiModel.stripe_p_key;
                    }
                    //[GMSServices provideAPIKey:[APP_DELEGATE getGoogleKey]];
                }
            }
            blockAfterCompleteTask(results, error,@"AllInOne");
        }];
        return true;
    }];
}





/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



-(void) openSingin{
    isDataAnimationCompleted=YES;
    if(isSplashAnimationCompleted==NO){
        return;
    }
    
    
    NSDictionary * dict=defaults_object(P_USER_DICT);
    if(dict)  {
        NSDictionary *dictDriver=defaults_object(P_USER_DICT);
        if([[dictDriver objectForKey:P_DRIVER_AVAILAILITY] boolValue]==NO){
            defaults_set_object(is_availability_on, @"0");
        }else{
            defaults_set_object(is_availability_on, @"1");
        }

        [self navigateHome];
    }else{
        UIViewController *vc=[StoryBoardUtiles viewContollerWithIdentifier:@"HelperViewControllerNav" name:StoryBoardUtiles.STORYBOARD_SIGNUP];
        [[APP_DELEGATE window] setRootViewController:vc];
        [[APP_DELEGATE window] makeKeyAndVisible];
        [APP_DELEGATE setNavigationController:vc];
        [[LanguageHelper sharedInstance] configureLanguage];
    }
}


-(void)navigateHome{
    [self loadUserHomeViewController];
    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
}





-(void)updateDeviceToken{
    NSDictionary * dictUser=defaults_object(P_USER_DICT_LOGGED);
    NSString * deviceToken=[[NSUserDefaults standardUserDefaults] objectForKey:P_DEVICE_TOKEN];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID   :[NSString stringWithFormat:@"%d",[[dictUser objectForKey:P_USER_ID]intValue]],
    }];
    if (deviceToken) {
        [dict addEntriesFromDictionary:@{
            P_DEVICE_TOKEN :deviceToken,
            P_DEVICE_TYPE   :IOS,
        }];
    }
//    [dict setObject:@"1" forKey:@"is_test"];
    [dict addEntriesFromDictionary:[Utilities appBuildVersionAndOsInfo]];
    [GIC mkwu:UPDATE_USER_PROFILE d:dict   isa:NO  cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
            if(is_user_login){
                defaults_set_object(P_USER_DICT, [results objectForKey:P_RESPONSE]);
            }
            defaults_set_object(P_USER_DICT_LOGGED, [results objectForKey:P_RESPONSE]);
        }
    }];
}

-(BOOL) checkErrorFor404:(NSError *) error{
    NSHTTPURLResponse *dataErrorResponse=[error.userInfo objectForKey:AppKeysName.ERROR_RESPONSE];
    long statusCode=(long)dataErrorResponse.statusCode;
    if(statusCode==404){
        return YES;
    }
    return NO;
}

-(void) showAlertForUpdateApp{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[UIHelper appNameForDisplay]
                                                          message:@"New Version available please update"
                                                   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Update Now"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                      
                                                         [self openPlayStore];
                                                     }];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void) openPlayStore{

    NSString *appUrl=@"https://apps.apple.com/us/app/n-driver-bid-your-price/id1583724412";

    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:appUrl];
    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"Opened url");
        }
    }];
}

@end

