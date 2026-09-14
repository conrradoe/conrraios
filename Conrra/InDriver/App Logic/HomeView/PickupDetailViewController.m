//
//  PickupDetailViewController.m
//  Damrei_Driver
//
//  Created by Grepix - Baij on 25/01/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "PickupDetailViewController.h"
#import "CustomPointAnnotation.h"
@interface PickupDetailViewController ()<MKMapViewDelegate>

@end

@implementation PickupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMapView];
    [self setUIFiels];
    [self.lbTitle setText:self.isPickup?[LanguageHelper getStringWithKey:@"k_12_s11_picup_datail"]:[LanguageHelper getStringWithKey:@"k_13_s11_drop_off_details"]];
}



-(void) setUIFiels{
    
    
    [self.lbTitle setText:self.isPickup?[LanguageHelper getStringWithKey:@"k_12_s11_picup_datail"]:[LanguageHelper getStringWithKey:@"k_13_s11_drop_off_details"]];
    
    
}
-(void)initMapView
{
    
    self.mapView.delegate = self;
    CLLocationCoordinate2D coordinate ;
    if(self.isPickup)  {
        coordinate = CLLocationCoordinate2DMake([self.tripModel.trip_pick_lat floatValue],[self.tripModel.trip_pick_long floatValue]);
    }
    else  {
        coordinate = CLLocationCoordinate2DMake([self.tripModel.trip_drop_lat floatValue],[self.tripModel.trip_drop_long floatValue]);
    }
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 600, 600);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    CustomPointAnnotation * userpin=[[CustomPointAnnotation alloc]  initWithType:self.isPickup?PIN_START:PIN_USER];
    userpin.coordinate = coordinate;
    [self.mapView addAnnotation:userpin];
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation){
        static NSString *defaultPinID = @"com.driver.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        if([annotation isKindOfClass:[CustomPointAnnotation class]])
        {
            CustomPointAnnotation  *mAnno=(CustomPointAnnotation *) annotation;
            if([mAnno.type isEqualToString:PIN_START])
            {
                
                pinView.image = [UIImage imageNamed:@"PIN"];
            }
            else if([mAnno.type isEqualToString:PIN_USER] ){
                
                pinView.image = [UIImage imageNamed:@"pin-red"];
            }
            else{
                pinView.image = [UIImage imageNamed:@"pin-red"];
            }
        }
    }
    else {
        [self.mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}
@end
