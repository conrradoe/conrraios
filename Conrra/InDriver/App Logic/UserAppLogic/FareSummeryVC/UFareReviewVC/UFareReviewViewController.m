//
//  FareReviewViewController.m
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 29/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "UFareReviewViewController.h"
#import <Conrra-Swift.h>
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import <MapKit/MapKit.h>
#import "CustomPointAnnotation.h"
#import "ConstantModel.h"
#import "CategoryModel.h"
#import "UIImageView+WebCache.h"
#import "Utilities.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "RoundShapeBg.h"
#import "TripModel+Helper.h"
@interface UFareReviewViewController ()<MKMapViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation UFareReviewViewController{
    NSMutableArray *arrAnotation;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    arrAnotation=[[NSMutableArray alloc]  init];
    [self setThemeConstants];
    [self setUIFiels];
   
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.imgDriver.layer setCornerRadius: self.imgDriver.frame.size.width / 2 ];
    RoundShapeBg * roundShapBg= [[RoundShapeBg alloc] init];
    roundShapBg.pading=20;
    roundShapBg.txtWidth=120;
    int bottom=self.viewBottomDivider.frame.origin.y-10;
    int height=self.viewContainer.frame.size.height;
    [roundShapBg makeRound:self.viewContainer tripModel:self.cur_trip heightView:height bottomTop:height-bottom];
}


-(void) setUIFiels{
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_5_s8_fare_review"];
    self.lblPicupLocation.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    self.lblDropLocation.text = [LanguageHelper getStringWithKey:@"k_r24_s9_drp_loc"];
    
    self.lblTripIdText.text = [LanguageHelper getStringWithKey:@"k_8_s11_trip_id"];
    self.lblDriverIdText.text = [LanguageHelper getStringWithKey:@"k_9_s11_driver_id"];
    self.lblWaitTimeText.text = [LanguageHelper getStringWithKey:@"k_3_s11_wait_time"];
    self.lblPromoText.text = [LanguageHelper getStringWithKey:@"k_4_s11_promo"];
    self.lblCashbackText.text = [LanguageHelper getStringWithKey:@"k_s3_promo_amt"];
    self.lblDistanceText.text = [LanguageHelper getStringWithKey:@"k_3_s8_distance"];
    self.lblTaxText.text = [LanguageHelper getStringWithKey:@"k_6_s11_taxes"];
    self.lblRideCostText.text =[LanguageHelper getStringWithKey:@"k_7_s11_ride_cost"];
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUIFiels];
    NSString * language = [[[NSLocale preferredLanguages] firstObject] substringToIndex:2];
    if ([language isEqualToString:@"ar"]) {
        self.lblTripIdValue.textAlignment =NSTextAlignmentLeft;
        self.lblDriverIdValue.textAlignment =NSTextAlignmentLeft;
    }
    
    CityModel * cModel=[CityModel getCityByCityId:self.cur_trip.city_id];
    NSString *dis;
    NSString *tripDis;
    
    dis =cModel.city_dist_unit;
    tripDis = self.cur_trip.trip_distance;
    
    self.lblTripIdValue.text =[NSString stringWithFormat:@"%@",_cur_trip.trip_Id];
    self.lblDriverIdValue.text=[NSString stringWithFormat:@"%@",_cur_trip.driver.driverId];
    
    _lblDropLocation.text =_cur_trip.dropLocationApp;
    _lblPickupLocation.text =_cur_trip.pickupLocationApp;
    
    
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-125, 300) forText:   self.lblPickupLocation.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    
    self.lblPicupLocation.text=self.cur_trip.pickupTitleWithPickUpTime;
    self.lblDroplocationText.text=self.cur_trip.dropTitleWithDropTime;
   
    
    CGFloat pickPickTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-100, 300) forText:  self.lblPicupLocation.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat pickDropTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-100, 300) forText:  self.lblDropLocation.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    
    [self.viewVerticalLine setConstraintConstant:pickHeight/2.0+10+pickPickTimeHeight+pickDropTimeHeight/2.0 forAttribute:NSLayoutAttributeHeight];
    
    _starRatingLbl.text = [NSString stringWithFormat:@"%.1f",_cur_trip.driver.rating];
    [self.viewStarRating setValue:_cur_trip.driver.rating];

    
    self.lbCarCategoryName.text= isEmpty(self.cur_trip.cat_name);
//    self.lbCarCategoryName.text= [NSString stringWithFormat:@"%@ (%@ #%@)",self.cur_trip.cat_name,[LanguageHelper getStringWithKey:@"k_8_s11_trip" defaultValue:@"Trip"],self.cur_trip.trip_Id];
    CityModel * cityModel=[CityModel getCityByCityId:self.cur_trip.city_id ];
    
    // Waittime
    self.lblWaitTimeValue.text=[NSString stringWithFormat:@"%d%@",self.cur_trip.wait_duration,[LanguageHelper getStringWithKey:self.cur_trip.wait_duration<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
    //Promo
//    self.lblPromoValue.text=[Utilities formatAmountAndCurrency:[_cur_trip.trip_promo_amt floatValue] currency:cityModel.city_cur];
    if([self.cur_trip.trip_promo_amt floatValue]>0){
        self.lblPromoText.hidden=NO;
        self.lblPromoValue.hidden=NO;
        self.lblCashbackText.hidden=NO;
        self.lblCashbackValue.hidden=NO;
        self.lblPromoValue.text =[self.cur_trip.trip_promo_code uppercaseString] ;
        self.lblCashbackValue.text =[Utilities formatAmountAndCurrency:[self.cur_trip.trip_promo_amt floatValue] currency:cityModel.city_cur] ;
    }else{
        self.lblPromoText.hidden=YES;
        self.lblPromoValue.hidden=YES;
        self.lblCashbackText.hidden=YES;
        self.lblCashbackValue.hidden=YES;
    }
    //Distance
    self.lblDistanceValue.text =[NSString stringWithFormat:@"%@ %@",tripDis,dis];
    // Tax
    self.lblTaxValue.text =[Utilities formatAmountAndCurrency:[_cur_trip.tax_amount_r floatValue] currency:cityModel.city_cur] ;
    //RideCost
    float total =[_cur_trip.trip_fare floatValue];
    self.lblRideCostValue.text=[Utilities formatAmountAndCurrency:total<=0.0?0.0:total currency:cityModel.city_cur];
    
    self.lblTotalFare.text =[Utilities formatAmountAndCurrency:[self.cur_trip.trip_fare floatValue] currency:cityModel.city_cur];
   
   
    _lblDriverName.text=[NSString stringWithFormat:@"%@ %@", _cur_trip.driver.d_fname,_cur_trip.driver.d_lname];
    
    NSString *profile= _cur_trip.driver.d_profile_image_path;
    [self.imgDriver.layer setCornerRadius: self.imgDriver.frame.size.width / 2 ];
    
    if (profile.length>0) {
        [_imgDriver sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }else
    {
        [_imgDriver  setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    
    [self initMapView];
    if(([self.cur_trip.trip_promo_amt floatValue]>0)){
        [self.viewCostDetails setConstraintConstant:120 forAttribute:NSLayoutAttributeHeight];
    }
    self.scrollView.delegate=self;
    ConstantModel * constantModel=[ConstantModel getConstantsObject];
    if([constantModel getCValueFK:ckey_e1])  {
        self.viewNewFare.hidden=NO;
        self.viewCostDetails.hidden=YES;
    }else{
        self.viewNewFare.hidden=YES;
        self.viewCostDetails.hidden=NO;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    sender.contentOffset=CGPointMake(0, sender.contentOffset.y);
}
 



-(void)setThemeConstants{
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
    [_lbCarCategoryName setFont:FONTS_THEME_REGULAR(16)];
    [_lblDriverName setFont:FONTS_THEME_REGULAR(16)];
}


-(void)initMapView{
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;
    [self.mapView removeAnnotations:arrAnotation];
    CustomPointAnnotation * pickUp=[[CustomPointAnnotation alloc]  initWithType:PIN_START];
    CLLocation * pick=[[CLLocation alloc]  initWithLatitude:[self.cur_trip.trip_pick_lat doubleValue] longitude:[self.cur_trip.trip_pick_long doubleValue]];
    pickUp.coordinate =pick.coordinate;
    [self.mapView addAnnotation:pickUp];
    CustomPointAnnotation * dropAno=[[CustomPointAnnotation alloc]  initWithType:PIN_DROP];
    CLLocation * drop=[[CLLocation alloc]  initWithLatitude:[self.cur_trip.trip_drop_lat doubleValue] longitude:[self.cur_trip.trip_drop_long doubleValue]];
    dropAno.coordinate=drop.coordinate;
    [self.mapView addAnnotation:dropAno];
    
    [arrAnotation addObject:pickUp];
    [arrAnotation addObject:dropAno];
    
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for (id <MKAnnotation> annotation in arrAnotation) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 2.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 2.1; // Add a little extra space on the sides
    [self mapRegion:region mapView:self.mapView];
    
    [self.mapView setUserInteractionEnabled:NO];
}



-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation{
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation){
        static NSString *defaultPinID = @"com.user.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        if([annotation isKindOfClass:[CustomPointAnnotation class]])
        { CustomPointAnnotation  *mAnno=(CustomPointAnnotation *) annotation;
            if([mAnno.type isEqualToString:PIN_START])
            {
                pinView.image = [UIImage imageNamed:@"PIN"];
            }else{
                pinView.image = [UIImage imageNamed:@"pin-red"];
            }
        }
        else{
            pinView.image = [UIImage imageNamed:@"car3"];    //as suggested by Squatch
        }
    }
    else {
        [self.mapView.userLocation setTitle:@"I am here"];
    }
    pinView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    return pinView;
}




- (IBAction)onBackButtonTap:(id)sender {
    [self.navigationController  popViewControllerAnimated:YES];
}



- (IBAction)onCloseButtonTap:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController ];
}



- (IBAction)onFareDetailsButTap:(id)sender {
    FareDetailsViewController *vc = (FareDetailsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.FARE_DETAIL_VC];
    vc.trip=self.cur_trip;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
