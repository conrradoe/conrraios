//
//  BaseViewController.h

//
//  Created by Grepix on 27/11/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <MapKit/MapKit.h>
#import <Conrra-Swift.h>
#import "MaterialTextControls+FilledTextFields.h"
#import "CheckAppUpdateVersion.h"
NS_ASSUME_NONNULL_BEGIN


@interface BaseViewController : UIViewController


-(void) showWarningWithMessgae:(NSString *) message;
-(void) showAlertWithMessgae:(NSString *) message;
-(void) showAlert:(NSString *) title message:(NSString *) message;
-(void) loadHomeViewController;
-(void) loadUserHomeViewController;
-(void) loadHomeViewController:(BOOL) isFromLoading;
-(UIAlertController *) showAlertWithOk:(NSString *) title message:(NSString *) message  handler:(void (^ __nullable)(UIAlertAction *action))handler;
-(void) showAlertWithButtonTitle:(NSString *) btTitle title:(NSString*)title message:(NSString *) message  handler:(void (^ __nullable)(UIAlertAction *action))handler;

-(void) loadInitailViewController:(NSArray *) viewControllers;
-(void)setTextFieldPlaceholderColor:(UITextField*)textField;
-(void)setTextFieldPlaceholderColor:(UITextField*)textField color:(UIColor*) color;
-(void) roundViewWithBorder:(UIView *) view;
-(void)checkAndShowAlertWith;
-(void) mapRegion:(MKCoordinateRegion ) region mapView:(MKMapView *)mapView;
-(void)stopOldLocationUpdate;
-(void)setUpMDCBaseTextField:(MDCBaseTextField *)textField;
-(void)openMailComposer;
-(void) showPleaseWaitLoader;
-(void) hidePleaseWaitLoader;
-(void) showLoadingLoader;
-(void) hideLoadingLoader;
-(BOOL)isRTL;
-(void)applyGrayTintOnImageView:(UIImageView*)imageview;
-(void)applyTintOnButton:(UIButton*)button iconName:(NSString *)iconName;
-(BOOL)isDarkMode;
@end

NS_ASSUME_NONNULL_END

