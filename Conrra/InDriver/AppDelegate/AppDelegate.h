//
//  AppDelegate.h
//  Store_project
//
//  Created by  Appicial on 06/02/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import "DataBase.h"

@class LGSideMenuController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>{
    Reachability *internetReachable;
    Reachability *hostReachable;
}
@property (strong, nonatomic) NSMutableArray *arrayCities;
@property (strong, nonatomic) NSMutableDictionary *dictForSendHideAlert;
@property(nonatomic) BOOL connectionStatus;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) CLLocation *currLoc;
@property (nonatomic) float driver_angle;
@property (nonatomic) int notificationCount;

@property (nonatomic) BOOL isFromInactive;
@property (nonatomic) UINavigationController * navigationController;

@property (nonatomic) NSDictionary* userInfoAppLaunch;
/** When driver home is shown, this is the MainViewController (LGSideMenuController). Used so driver HomeViewController can open the side menu reliably. */
@property (weak, nonatomic) LGSideMenuController *driverSideMenuController;
/** Set YES while switching from rider to driver so 401 from rider menu does not trigger logout. */
- (BOOL)switchingToDriverMode;
- (void)setSwitchingToDriverMode:(BOOL)switchingToDriverMode;
//-(void)handleChatNotification:(NSString *) tripId message:(NSString *) message;
-(void ) handleCashNotification:(NSString *) tripId message:(NSString *) message;
-(NSString * ) getGoogleKey;
-(void) stopRequestSound;
-(id) getSockethelperSwift;
- (void)onDriverSwitchButtonTap:(id)sender ;
-(void) handleNotificationIfHasData;
/** Switch to rider home (UMainViewController + UHomeViewController). Use after review or when returning to rider app. */
- (void)loadUserHomeViewController;

//-(void) connectToSocket;
//-(void)disconnectToSocket;
@end

