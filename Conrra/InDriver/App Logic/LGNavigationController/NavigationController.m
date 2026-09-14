//
//  NavigationController.m
//  LGSideMenuControllerDemo
//

#import "NavigationController.h"
#import "UIViewController+LGSideMenuController.h"
#import "WebCallConstants.h"
#import "ConstantModel.h"
@implementation NavigationController

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
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

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.sideMenuController.isRightViewVisible ? UIStatusBarAnimationSlide : UIStatusBarAnimationFade;
}

@end
