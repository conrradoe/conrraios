//
//  HandlingHelper.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "HandlingHelper.h"
#import "MainViewController.h"
#import "AFNetworkReachabilityManager.h"
@implementation HandlingHelper
{
    NetworkLocationAlertView * _networkLocationAlertView;
//    LocationAlertView * _locationAlertView;
}


+ (HandlingHelper *)sharedObject {
    static HandlingHelper *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClass = [[self alloc] init];
    });
    return sharedClass;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                    selector:@selector(appDidEnterForeground)
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
    return self;
}

-(void)startMonitoring
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability++++++++++: %@", AFStringFromNetworkReachabilityStatus(status));
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            {
                [self handleNotReachable];
                 [[AFNetworkReachabilityManager sharedManager] startMonitoring];
                
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                [self handleReachableConnected ];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                [self handleReachableConnected ];
            }
                break;
            default:
            {
                [self handleReachableConnected ];
            }
                break;
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
-(void) handleReachableConnected
{
    [self->_networkLocationAlertView removeFromSuperview];
    self->_networkLocationAlertView=nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"network_connected" object:nil];
//    [self checkisLocationServiceEnabled ];
}

-(void) handleNotReachable
{
    if(_networkLocationAlertView==nil)
    {
       
        _networkLocationAlertView=[[[NSBundle mainBundle] loadNibNamed:@"NetworkLocationAlertView" owner:self options:nil] firstObject];
        CGRect rect=[UIScreen mainScreen].bounds;
        _networkLocationAlertView.frame=CGRectMake(0, 0, rect.size.width, rect.size.height);
        [[[UIApplication sharedApplication] keyWindow] addSubview:_networkLocationAlertView];
    }
}

-(void) showAlertLocationByForce
{
    HandleAlertViewController*coolViewCtrlObj=[[HandleAlertViewController alloc] initWithNibName:@"HandleAlertViewController" bundle:nil];
    
    if( [[[[[UIApplication sharedApplication]delegate] window] rootViewController] isKindOfClass:[MainViewController class]])
    {
        MainViewController *rootController = (MainViewController *)  [[[[UIApplication sharedApplication]delegate] window] rootViewController];
        UINavigationController *navigationController = (UINavigationController *)rootController.rootViewController;
        [navigationController pushViewController:coolViewCtrlObj animated:YES];
    }
//     if(_locationAlertView==nil)
//      {
//
//          _locationAlertView=[[[NSBundle mainBundle] loadNibNamed:@"LocationAlertView" owner:self options:nil] firstObject];
//          CGRect rect=[UIScreen mainScreen].bounds;
//          _locationAlertView.frame=CGRectMake(0, 0, rect.size.width, rect.size.height);
//          [[[UIApplication sharedApplication] keyWindow] addSubview:_locationAlertView];
//      }
}


//-(void) checkisLocationServiceEnabled
//{
//    if ([CLLocationManager locationServicesEnabled]){
//        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
//            [self showAlertLocationByForce];
//        }
//    }else{
//            [self showAlertLocationByForce];
//    }
//}

-(void)appDidEnterForeground{
//    [self checkisLocationServiceEnabled];
}
@end
