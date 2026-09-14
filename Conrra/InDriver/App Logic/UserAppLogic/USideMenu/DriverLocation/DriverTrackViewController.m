//
//  PickupDetailViewController.m
//  Damrei_Driver
//
//  Created by Grepix - Baij on 25/01/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "DriverTrackViewController.h"
#import "CustomPointAnnotation.h"
#import "CategoryModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIHelper.h"

@interface DriverTrackViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@end

@implementation DriverTrackViewController
{
    NSTimer *getOrderTimer;
    CustomPointAnnotation * userpin;
    BOOL isEndTimer;
    CustomPointAnnotation *driverPin;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMapView];
    isEndTimer=NO;
    [self getOngoingJobs];
    [self.viewTrackingMessage setHidden:YES];
    [self.butBookingDetails setHidden:YES];
    self.lbTitle.text=[LanguageHelper getStringWithKey:@"k_1_s9_lct_drvr"];
}


-(void)initMapView{
    self.mapView.delegate = self;
    CLLocationCoordinate2D coordinate ;
    coordinate = CLLocationCoordinate2DMake(self.driverModel.lat,self.driverModel.lng );
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 600, 600);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    if(userpin==nil) {
        userpin=[[CustomPointAnnotation alloc]  initWithType:@"driver-pin"];
        userpin.coordinate = coordinate;
        [self.mapView addAnnotation:userpin];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self->userpin.coordinate = coordinate;
            
        } completion:^(BOOL finished) {
            CLLocationCoordinate2D   coordinate = CLLocationCoordinate2DMake(self.driverModel.lat,self.driverModel.lng );
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 600, 600);
            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        }];
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    // [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestAlwaysAuthorization];
    [_locationManager allowsBackgroundLocationUpdates];
    [_locationManager setPausesLocationUpdatesAutomatically:NO];
    [_locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode = MKUserTrackingModeNone ;
    self.mapView.mapType =  MKMapTypeStandard;
    self.mapView.showsCompass = YES;
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *loc = locations.lastObject;
    AppDelegate *appdelegate= APP_DELEGATE;
    appdelegate.currLoc=loc;
    NSDictionary * dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude ],@"lng", nil];
    defaults_set_object(@"curr_loc", dict);
    [self setDriverPin:loc];
}

-(void)setDriverPin:(CLLocation *)loc{
    AppDelegate *appdelegate= APP_DELEGATE;
//    CLLocationCoordinate2D  preLocation= appdelegate.currLoc.coordinate;
    appdelegate.currLoc = loc;
    NSDictionary * dict =[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.latitude],@"lat",[NSString stringWithFormat:@"%f",appdelegate.currLoc.coordinate.longitude ],@"lng", nil];
    defaults_set_object(@"curr_loc", dict);
    if(driverPin==nil){
        driverPin = [[CustomPointAnnotation alloc]  initWithType:@"user-pin"];
        driverPin.coordinate = appdelegate.currLoc.coordinate;
        [self.mapView addAnnotation:driverPin];
    }
    else{
        [UIView animateWithDuration:0.3f
                         animations:^{
            self->driverPin.coordinate =  appdelegate.currLoc.coordinate;
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    [self locatonGetFailedScreen];
}



-(void) updatePartnerLocation{
    CLLocationCoordinate2D coordinate ;
     coordinate = CLLocationCoordinate2DMake(self.driverModel.lat,self.driverModel.lng );
    if(userpin==nil) {
        userpin=[[CustomPointAnnotation alloc]  initWithType:@"driver-pin"];
        userpin.coordinate = coordinate;
        [self.mapView addAnnotation:userpin];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self->userpin.coordinate = coordinate;
        }];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onBackButtonTap:(id)sender {
    [_locationManager stopUpdatingHeading];
    [_locationManager stopUpdatingLocation];
    [self.navigationController popViewControllerAnimated:YES];
    isEndTimer=YES;
    [self invalidateGetOrderTimer];
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation) {
        static NSString *defaultPinID = @"com.driver.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        if([annotation isKindOfClass:[CustomPointAnnotation class]]) {
            CustomPointAnnotation  *mAnno=(CustomPointAnnotation *) annotation;
            if([mAnno.type isEqualToString:@"start"]) {
                pinView.image = [UIImage imageNamed:@"PIN"];
            }else if ([mAnno.type isEqualToString:@"driver-pin"]){
                //double rotation = mAnno.degree * 3.14159 / 180;
                
                // [pinView setTransform:CGAffineTransformMakeRotation(-rotation)];
                NSString * imageName=@"car_icon";
                CategoryModel * category=[CategoryModel getCategoryByid:self.driverModel.category_id];
                if(category) {
                    imageName=category.cat_map_icon_path;
                }
                NSURL *url = [NSURL URLWithString:imageName];
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager loadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (image) {
                        pinView.image=[UIHelper imageForMapWithImage:image];
                    }else{
                        pinView.image=[UIHelper imageForMapWithImage:[UIImage imageNamed:@"icon_car_new"]];
                    }
                }];
                pinView.image=nil;
            }
            else if([mAnno.type isEqualToString:@"user-pin"] ){
                pinView.image = [UIImage imageNamed:@"PIN"];
            }
            else{
                pinView.image = [UIImage imageNamed:@"pin-red"];
            }
        }else{
            pinView.image = [UIImage imageNamed:@"pin-red"];
        }
        return pinView;
    }
    else {
        [self.mapView.userLocation setTitle:@"I am here"];
        return nil;
    } 
}


-(void)getOngoingJobs{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"driver_id":[NSString stringWithFormat:@"%@",self.driverModel.driverId]
    }];
    [GIC mkwu:@"driverapi/getdrivers"  d:dict
          isa:NO  cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray *arrtrip = [results objectForKey:P_RESPONSE];
                if ([arrtrip isKindOfClass:[NSArray class]]){
                    if(arrtrip.count>0) {
                        self.driverModel = [[DriverModel alloc] initItemWithDict:[arrtrip objectAtIndex:0]];
                        [self updatePartnerLocation];
                    }
                }
            }
            [self starGetOrderTimer];
        }
        else{
            [self starGetOrderTimer];
        }
    }];
}


-(void) starGetOrderTimer{
    [self invalidateGetOrderTimer];
     if(!isEndTimer) {
         getOrderTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(getOngoingJobs) userInfo:nil repeats:NO];
     }
}


-(void)invalidateGetOrderTimer{
    [getOrderTimer invalidate];
    getOrderTimer =nil;
}

- (IBAction)onBookingDetailsButtonTap:(id)sender {
    
}

@end
