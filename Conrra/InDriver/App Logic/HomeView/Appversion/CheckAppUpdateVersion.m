//
//  CheckAppUpdateVersion.m
//  Beehub
//
//  Created by Grepix - Baij on 06/09/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "CheckAppUpdateVersion.h"
#import "SettingsModel.h"

@implementation CheckAppUpdateVersion

{
    UIAlertController *alertController;
    BOOL isShowAlert;
    ConstantModel * _constantModel;
}

//- (instancetype)initWithViewController:(UIViewController *) viewController
//{
//    self = [super init];
//    if (self) {
//        self.viewController=viewController;
//    }
//    return self;
//}

-(void) checkAndShowAlert
{
    ConstantModel  *currType= [ConstantModel getConstantsObject];
    if(currType)
    {
        
        [self checkAndShowAlertWith:currType];
    }
}
-(void) checkAndShowAlertWith:(ConstantModel *)constantModel
{
    _constantModel=constantModel;
    if(isShowAlert)
    {
        return;
    }
    if(constantModel.self.ios_app_ver)
    {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        if(![majorVersion isEqualToString:constantModel.self.ios_app_ver])
        {
            //             constantModel.ios_driver_app_ver=@"1.0.11";
            NSArray *splitVersionApp = [majorVersion componentsSeparatedByString:@"."];
            NSString * stringVersionApp=@"";
            for (NSString * stringDi in splitVersionApp) {
                stringVersionApp=[NSString stringWithFormat:@"%@%@",stringVersionApp,stringDi];
            }
            NSArray *splitVersionServer = [constantModel.self.ios_app_ver componentsSeparatedByString:@"."];
            NSString * stringVersionServer=@"";
            for (NSString * stringDi in splitVersionServer) {
                stringVersionServer=[NSString stringWithFormat:@"%@%@",stringVersionServer,stringDi];
            }
            if([stringVersionApp intValue]<[stringVersionServer intValue])
            {
                BOOL isMajorUpdate=NO;
                if(splitVersionServer.count>2) {
                    int majorVersionServer=[[splitVersionServer objectAtIndex:1] intValue];
                    int majorVersionApp=0;
                    int majorVersionServerFirst2 =0;
                    int majorVersionAppFirst2=0;
                    if(splitVersionApp.count>2) {
                        majorVersionApp= [[splitVersionApp objectAtIndex:1] intValue];
                         majorVersionServerFirst2=[[NSString stringWithFormat:@"%@%@",[splitVersionServer objectAtIndex:0],[splitVersionServer objectAtIndex:1]] intValue];
                         majorVersionAppFirst2=[[NSString stringWithFormat:@"%@%@",[splitVersionApp objectAtIndex:0],[splitVersionApp objectAtIndex:1]] intValue];
                    }
                    
                    if(majorVersionAppFirst2<majorVersionServerFirst2){
                        isMajorUpdate=YES;
                    }else{
                        if(majorVersionApp<majorVersionServer)   {
                            isMajorUpdate=YES;
                        }
                    }
                }
                isShowAlert=YES;
                NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
                alertController = [UIAlertController alertControllerWithTitle:appName
                                                                      message:[LanguageHelper getStringWithKey:@"k_76_s4_new_ver"]
                                                               preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_94_s4_upt_now"]
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                    self->isShowAlert=NO;
                    [self openPlayStore];
                }];
                UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r23_s4_later"]
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                    self->isShowAlert=NO;
                }];
                [alertController addAction:actionOk];
                if(!isMajorUpdate)
                {
                    [alertController addAction:actionCancel];
                }
                [self.delegate openAlertViewController:alertController  ];
            }
        }
    } else
    {
        if(alertController!=nil)
        {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            isShowAlert=NO;
            alertController=nil;
        }
    }
}

-(void) openPlayStore
{
    SettingsModel *settings=[SettingsModel getSettignsObject];
    if(settings.ios_driver_app_ver)
    {
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:settings.ios_driver_app_ver];
        [application openURL:URL options:@{} completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Opened url");
            }
        }];}
}
@end
