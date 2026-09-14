//
//  URouteInputViewController.h
//  Conrra
//
//  Screen 2 — "Ingresa tu Ruta"
//  Shown when user taps "¿A dónde vas?" on the home screen.
//  Allows editing pickup (pre-filled from GPS) and searching for a destination.
//

#import <UIKit/UIKit.h>
#import "GoogleDirectionSource.h"
#import "CategoryModel.h"

@class URouteInputViewController;

@protocol URouteInputDelegate <NSObject>

/// Called when the user selects a destination from suggestions.
/// The VC will pop itself before calling this. Handle geocoding + route in UHomeViewController.
- (void)routeInputVC:(URouteInputViewController *)vc didSelectDestination:(NSDictionary *)dictLocation;

@optional
/// Called when the user selects a new pickup location from suggestions.
/// The VC stays open after this.
- (void)routeInputVC:(URouteInputViewController *)vc didSelectPickup:(NSDictionary *)dictLocation;

@end

@interface URouteInputViewController : UIViewController

@property (weak,   nonatomic) id<URouteInputDelegate>  delegate;
@property (strong, nonatomic) GoogleDirectionSource    *direction;
@property (strong, nonatomic) NSArray                  *categories;       // arrayCagetgory
@property (strong, nonatomic) CategoryModel            *selectedCategory;

@end
