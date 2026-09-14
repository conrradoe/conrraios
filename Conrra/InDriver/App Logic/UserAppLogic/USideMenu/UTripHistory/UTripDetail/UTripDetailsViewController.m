//
//  TripDetailsViewController.m
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 30/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "UTripDetailsViewController.h"
#import <Conrra-Swift.h>
#import <MapKit/MapKit.h>
#import <GIKit/GIKit.h>
#import "CustomPointAnnotation.h"
#import "WebCallConstants.h"
#import "UIImageView+WebCache.h"
#import "CategoryModel.h"
#import "Utilities.h"
#import "UChatViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "RoundShapeBg.h"
#import "StarRatingView.h"
#import "TripModel+Helper.h"
@interface UTripDetailsViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lbCarCategoryName;
@property (weak, nonatomic) IBOutlet UIImageView *imUserImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgCar;
@property (weak, nonatomic) IBOutlet UIImageView *imgChat;

@end

@implementation UTripDetailsViewController
{
    NSMutableArray *arrAnotation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUIFiels];
    arrAnotation=[[NSMutableArray alloc]  init];
    [self initMapView];
    [self.imUserImage setClipsToBounds:YES];
    _constantModel =[ConstantModel getConstantsObject];
    [self.imUserImage.layer setCornerRadius:self.imUserImage.frame.size.width / 2];
   
    if(([self.trip.trip_promo_amt floatValue]>0)){
        [self.costDetailView setConstraintConstant:120 forAttribute:NSLayoutAttributeHeight];
    }

    if(self.trip.trip_customer_details.length==0){
        [self.btnPassengerDetails hideByHeight:YES];
    }else{
    }
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    RoundShapeBg * roundShapBg= [[RoundShapeBg alloc] init];
    roundShapBg.pading=20;
    roundShapBg.txtWidth=120;
    int bottom=self.viewBottomDivider.frame.origin.y-10;
    int height=self.viewContainer.frame.size.height;
    [roundShapBg makeRound:self.viewContainer tripModel:self.trip heightView:height bottomTop:height-bottom];
}
-(void) setUIFiels{
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_r43_s9_ride_detail"];
    self.lblPicupLocation.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    self.lblDropLocation.text = [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    
    
    self.lblWaitTimeText.text = [LanguageHelper getStringWithKey:@"k_3_s11_wait_time"];
    self.lblPromoText.text = [LanguageHelper getStringWithKey:@"k_4_s11_promo"];
    self.lblCashbackText.text = [LanguageHelper getStringWithKey:@"k_s3_promo_amt"];
    self.lblDistanceText.text = [LanguageHelper getStringWithKey:@"k_3_s8_distance"];
    self.lblTaxText.text = [LanguageHelper getStringWithKey:@"k_6_s11_taxes"];
    self.lblRideCostText.text =[LanguageHelper getStringWithKey:@"k_7_s11_ride_cost"];
    
    [self.cnacelTripOutlet setTitle: [LanguageHelper getStringWithKey:@"k_r2_s8_cancel_ride"]   forState:UIControlStateNormal];
    [self.btnChat setTitle: [LanguageHelper getStringWithKey:@"k_r17_s6_chat"]   forState:UIControlStateNormal];
    [self.btnPassengerDetails setTitle: [LanguageHelper getStringWithKey:@"k_s3_passenger_details"]   forState:UIControlStateNormal];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUIFiels];
//    NSString * language = [[[NSLocale preferredLanguages] firstObject] substringToIndex:2];
    NSString *dis;
    NSString *tripDis;
    CityModel * citModel=[CityModel getCityByCityId:self.trip.city_id];
    dis =citModel.city_dist_unit;
    tripDis = _trip.trip_distance;
//    CategoryModel *carCategory=[CategoryModel getCategoryByid:[self.trip.trip_cat_id intValue]];
    
//    _categoryNamelbl.text = isEmpty(self.trip.cat_name);
    self.categoryNamelbl.text= [NSString stringWithFormat:@"%@ (%@ #%@)",self.trip.cat_name,[LanguageHelper getStringWithKey:@"k_8_s11_trip" defaultValue:@"Trip"],self.trip.trip_Id];
    CityModel * cityModel=[CityModel getCityByCityId:self.trip.city_id];
    
    _lblRiderName.text=[NSString stringWithFormat:@"%@ %@", isEmpty(self.trip.driver.d_fname),isEmpty(self.trip.driver.d_lname)];
//    self.lbCarCategoryName.text=isEmpty(self.trip.cat_name);
    NSString *profile= _trip.driver.d_profile_image_path;
    [self.imgRider setClipsToBounds:YES];
    [self.imgRider.layer setCornerRadius:self.imgRider.frame.size.width / 2];
    if (profile.length>0) {
        [self.imgRider sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }else  {
        [self.imgRider  setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    
    [_lblPickup sizeToFit];
    [_lblDrop sizeToFit];
    _lblDate.text =[Utilities GetGMTDatetoLocalTZ:self.trip.trip_created_time:APP_DATE_ONLY];
    self.lblPicupLocation.text=self.trip.pickupTitleWithPickUpTime;
    self.lblDropLocation.text=self.trip.dropTitleWithDropTime;
    
    CGFloat pickPickTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-100, 300) forText:  self.lblPicupLocation.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat pickDropTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-100, 300) forText:  self.lblDropLocation.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    self.lblDrop.text =self.trip.dropLocationApp;
    self.lblPickup.text =self.trip.pickupLocationApp;
 
    
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-125, 300) forText:  self.lblPickup.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    [self.viewVerticalLine setConstraintConstant:pickHeight/2.0+10+pickPickTimeHeight+pickDropTimeHeight/2.0 forAttribute:NSLayoutAttributeHeight];
     
    
    
    // waiting time
    self.lblWaitTimeValue.text=[NSString stringWithFormat:@"%d%@",self.trip.wait_duration,[LanguageHelper getStringWithKey:self.trip.wait_duration<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
    // Fare TotoalCost
    self.lblRideCostValue.text=[Utilities formatAmountAndCurrency:[self.trip.trip_fare floatValue] currency:cityModel.city_cur];
    //Distance
    self.lblDistanceValue.text =[NSString stringWithFormat:@"%@ %@",tripDis,dis];
    // Promo
    if([self.trip.trip_promo_amt floatValue]>0){
        self.lblPromoText.hidden=NO;
        [self.lblPromoText sizeToFit];
        self.lblPromoValue.hidden=NO;
        self.lblCashbackText.hidden=NO;
        self.lblCashbackValue.hidden=NO;
        self.lblPromoValue.text =[self.trip.trip_promo_code uppercaseString] ;
        self.lblCashbackValue.text =[Utilities formatAmountAndCurrency:[self.trip.trip_promo_amt floatValue] currency:cityModel.city_cur] ;
    }else{
        self.lblPromoText.hidden=YES;
        self.lblPromoValue.hidden=YES;
        self.lblCashbackText.hidden=YES;
        self.lblCashbackValue.hidden=YES;
    }
    
    // Tax
    self.lblTaxValue.text = [Utilities formatAmountAndCurrency:[self.trip.tax_amount_r floatValue] currency:cityModel.city_cur];
    //rating
    self.ratingLbl.text = [NSString stringWithFormat:@"%0.1f",_trip.driver.rating];
    
    [self.starRatingView  setValue:_trip.driver.rating];
    
    if ([_isFromUpcomingTripViewDetail isEqualToString:@"YES"]){
        [self.cnacelTripOutlet setHidden:NO];
        self.costDetailView.hidden = YES;
    } else {
        self.costDetailView.hidden = NO;
        [self.cnacelTripOutlet setHidden:YES];
    }
    self.costDetailView.hidden = YES;
    
    ConstantModel * constantModel=[ConstantModel getConstantsObject];
    if([constantModel getCValueFK:ckey_e1]) {
        self.viewnewFare.hidden=NO;
        self.costDetailView.hidden=YES;
    }else{
        self.viewnewFare.hidden=YES;
        self.costDetailView.hidden=NO;
    }
    
   
    if([self.trip isTripCancelled]) {
        if([self.trip isTripCancelledForStatus]){
            [self.lbTripStatus setTextColor:[UIColor redColor]];
        }else{
            [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        }
        [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_r8_s10_cancelled"]];
        [self.lbTripStatus setHidden:NO];
        if([self.trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]||[self.trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]) {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_trip_payment_awaited"]/*@"Payment Awaited"*/];
            [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        }
    }else{
        [self.lbTripStatus setText:isEmpty(self.trip.trip_Status)];
        [self.lbTripStatus setHidden:NO];
        [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        if([self.trip.trip_Status isEqualToString:TS_END]&&[self.trip.trip_pay_status isEqualToString:TS_PAID]) {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_com_18_completed"]];
        }
        else if([self.trip.trip_Status isEqualToString:TS_END]) {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_trip_payment_awaited"]/*@"Payment Awaited"*/];
        }else  if([self.trip.trip_Status isEqualToString:TS_REQUEST]) {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_request"]/*@"Request"*/];
            
        }else  if([self.trip.trip_Status isEqualToString:TS_ASSIGNED]) {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_assigned"]/*@"Request"*/];
            
        }else  {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"p_14_s4_ongoing"]/*@"Ongoing"*/];
        }
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}



-(void)setThemeConstants{
    [_lblDate setFont:FONTS_THEME_REGULAR(16)];
    [_lbCarCategoryName setFont:FONTS_THEME_REGULAR(16)];
    [_lblRiderName setFont:FONTS_THEME_REGULAR(16)];
}



-(void)initMapView{
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;
    [self.mapView removeAnnotations:arrAnotation];
    CustomPointAnnotation * pickUp=[[CustomPointAnnotation alloc]  initWithType:PIN_START];
    CLLocation * pick=[[CLLocation alloc]  initWithLatitude:[_trip.trip_pick_lat doubleValue] longitude:[_trip.trip_pick_long doubleValue]];
    pickUp.coordinate =pick.coordinate;
    [self.mapView addAnnotation:pickUp];
    CustomPointAnnotation * dropAno=[[CustomPointAnnotation alloc]  initWithType:PIN_DROP];
    CLLocation * drop=[[CLLocation alloc]  initWithLatitude:[_trip.trip_drop_lat doubleValue] longitude:[_trip.trip_drop_long doubleValue]];
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
    if(annotation != self.mapView.userLocation)   {
        static NSString *defaultPinID = @"com.user.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        if([annotation isKindOfClass:[CustomPointAnnotation class]])  {
            CustomPointAnnotation  *mAnno=(CustomPointAnnotation *) annotation;
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


- (IBAction)ButtonBackAction:(id)sender {
    [self.tripDetailDelegate onDismissDetailTrip];
}






- (IBAction)btnCancelScheduleTrip:(id)sender {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        TRIP_STATUS :TS_USER_CANCEL,
        TRIP_ID     : [NSString stringWithFormat:@"%@",_trip.trip_Id],
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:TRIP_UPDATE
                  d:dict
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [self showAlertWithOk:@"" message:[LanguageHelper getStringWithKey:@"k_r40_s8_your_trip_cancelled"] handler:^(UIAlertAction * _Nonnull action) {
                
            }];
        }
        self.imgCancel.hidden =NO;
    }];
}






-(void) openChatViewController{
    UChatViewController *vc = (UChatViewController*)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UCHAT_VC];
    vc.tripID=[NSString stringWithFormat:@"%@",self.trip.trip_Id];
    [self.navigationController pushViewController:vc animated:YES];
}



- (IBAction)onChatButtonTap:(id)sender {
    [self openChatViewController];
}



- (IBAction)onPassengerDetails:(id)sender {
    [PassengerDetailsAlertView showPessangeDetails: self.view withData:self.trip.trip_customer_details];
}



- (IBAction)onFareDetailsButTap:(id)sender {
    FareDetailsViewController *vc = (FareDetailsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.FARE_DETAIL_VC];
    vc.trip=self.trip;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
