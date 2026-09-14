//
//  UIViewController+Location.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 24/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "UIViewController+Location.h"
#import "LanguageHelper.h"


@implementation UIViewController (Location)

-(BOOL)checkLocationServiceEnabled
{
    if([CLLocationManager locationServicesEnabled])
    {
        return YES;
    }else{
        return NO;
    }
    return NO;
}






-(void)locatonGetFailedScreen:(CLLocationManager *)manager isBackHidden:(BOOL) isBackHidden{
    if([CLLocationManager locationServicesEnabled]){
        int authorizationStatus=[CLLocationManager authorizationStatus];
        if(authorizationStatus==kCLAuthorizationStatusDenied||authorizationStatus==kCLAuthorizationStatusNotDetermined||
           authorizationStatus==kCLAuthorizationStatusRestricted){
            [self openAlert:manager isBackHidden:isBackHidden];
        }else if (@available(iOS 14.0, *)) {
            if(manager.accuracyAuthorization != CLAccuracyAuthorizationFullAccuracy){
                [self openAlert:manager isBackHidden:isBackHidden];
            }
        } else {
            // Fallback on earlier versions
        }
    }else{
        [self openAlert:manager isBackHidden:isBackHidden] ;
    }
}


-(BOOL)isCheckLocationFailedScreen{
    if([CLLocationManager locationServicesEnabled]){
        int authorizationStatus=[CLLocationManager authorizationStatus];
        if(authorizationStatus==kCLAuthorizationStatusDenied||authorizationStatus==kCLAuthorizationStatusNotDetermined||
           authorizationStatus==kCLAuthorizationStatusRestricted){
            return YES;
        }
    }else{
        return YES;
    }
    return NO;
}

-(void) openAlert:(CLLocationManager *)manager isBackHidden:(BOOL) isBackHidden{
    BOOL isExist=NO;
    UIViewController * vCExists =nil;
    for (UIViewController * viewController in self.navigationController.viewControllers) {
        if([viewController isKindOfClass: [HandleAlertViewController class]])
        {
            isExist=YES;
            vCExists=viewController;
            break;
        }
        
    }
    if(!isExist)
    {
        HandleAlertViewController*coolViewCtrlObj=[[HandleAlertViewController alloc] initWithNibName:@"HandleAlertViewController" bundle:nil];
        coolViewCtrlObj.locationManager=manager;
        if(isBackHidden){
            coolViewCtrlObj.btnBack.hidden=YES;
        }
        [self.navigationController pushViewController:coolViewCtrlObj  animated:NO];
    }else{
        NSMutableArray *arrVc=[[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers ];
        if(vCExists)
        {
            [arrVc removeObject:vCExists];
            [arrVc addObject:vCExists];
            [self.navigationController setViewControllers:arrVc];
        }
    }
}

@end

