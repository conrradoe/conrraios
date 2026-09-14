//
//  TripDetailsViewController.m
//  TaxiDriver
//
//  Created by  Appicial on 30/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "TripDetailsViewController.h"
#import <MapKit/MapKit.h>
#import <GIKit/GIKit.h>
#import "CustomPointAnnotation.h"
#import "WebCallConstants.h"
#import "UIImageView+WebCache.h"
#import "Utilities.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "CategoryModel.h"
#import "ConstantModel.h"
//#import <GooglePlaces/GooglePlaces.h>
#import "ChatViewController.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import "RoundShapeBg.h"
#import "TripModel+Helper.h"
@interface TripDetailsViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lbCarCategoryName;
@property (weak, nonatomic) IBOutlet UIImageView *imUserImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgChat;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;

@end

@implementation TripDetailsViewController
{
    NSMutableArray *arrAnotation;
//    NSMutableArray *arrCategory;
//    CategoryModel *carCategory;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setThemeConstants];
    [self setUIFiels];
    
    arrAnotation=[[NSMutableArray alloc]  init];
    [self initMapView];
    [self.imUserImage setClipsToBounds:YES];
    [self.imUserImage.layer setBorderColor:[UIColor colorNamed:@"color_app_label"].CGColor];
    [self.imUserImage.layer setCornerRadius:50];
    
//    RoundShapeBg * roundShapBg= [[RoundShapeBg alloc] init];
//    roundShapBg.pading=20;
//    roundShapBg.txtWidth=120;
//    [roundShapBg makeRound:self.viewOnScroll tripModel:self.trip heightView:472+15+40 bottomTop:120+15+10];
  
     if(self.trip.trip_customer_details.length==0){
         [self.btnPassengerDetail hideByHeight:YES];
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
    self.lblWaitTimeText.text = [LanguageHelper getStringWithKey:@"k_3_s11_wait_time"];
    self.lblPromoText.text = [LanguageHelper getStringWithKey:@"k_4_s11_promo"];
    self.lblDistanceText.text = [LanguageHelper getStringWithKey:@"k_3_s8_distance"];
    self.lblTaxText.text = [LanguageHelper getStringWithKey:@"k_6_s11_taxes"];
    self.lblRideCostText.text =[LanguageHelper getStringWithKey:@"k_7_s11_ride_cost"];
    [self.btnPassengerDetail setTitle: [LanguageHelper getStringWithKey:@"k_s3_passenger_details"]   forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUIFiels];
    
    
    [self.imUserImage setClipsToBounds:YES];
    // [self.imUserImage.layer setBorderWidth:1];
    [self.imUserImage.layer setBorderColor:[UIColor colorNamed:@"color_app_label"].CGColor];
    [self.imUserImage.layer setCornerRadius: self.imUserImage.frame.size.width / 2];
    CityModel *cModel=[CityModel getCityByCityId:self.trip.city_id];
    NSString *dis;
    NSString *tripDis;
    dis =cModel.city_dist_unit;
    tripDis = _trip.trip_distance;
    ConstantModel *_currType =[ConstantModel getConstantsObject];;
    if([_currType getCValueFK:ckey_e1]){
        self.viewNewFare.hidden=NO;
        self.viewCostDetail.hidden=YES;
    }else{
        self.viewNewFare.hidden=YES;
        self.viewCostDetail.hidden=NO;
    }
    self.lbCarCategoryName.text= [NSString stringWithFormat:@"%@ (%@ #%@)",self.trip.cat_name,[LanguageHelper getStringWithKey:@"k_8_s11_trip" defaultValue:@"Trip"],self.trip.trip_Id];
    _lblRiderName.text=[NSString stringWithFormat:@"%@ %@", isEmpty(self.trip.user.u_fname), isEmpty(self.trip.user.u_lname)];
    _lblDate.text =[Utilities GetGMTDatetoLocalTZ:self.trip.trip_created_time :APP_DATE_ONLY];
    self.lblDrop.text =self.trip.dropLocationApp;
    self.lblPickup.text =self.trip.pickupLocationApp;
    
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-125, 300) forText: self.lblPickup.text  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    
    self.lblPickupLocatonText.text=self.trip.pickupTitleWithPickUpTime;
    self.lblDdropLocationText.text=self.trip.dropTitleWithDropTime;
   
    
    CGFloat pickPickTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-125, 300) forText:  self.lblPickupLocatonText.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat pickDropTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-125, 300) forText:  self.lblDdropLocationText.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    [self.viewVerticalLine setConstraintConstant:pickHeight/2.0+10+pickPickTimeHeight+pickDropTimeHeight/2.0 forAttribute:NSLayoutAttributeHeight];
    
   
    
    // taxes
    self.lblTaxValue.text =[Utilities formatAmountAndCurrency:[self.trip.tax_amount floatValue] currency:cModel.city_cur];
    // waiting
    self.lblWaitTimeValue.text=[NSString stringWithFormat:@"%d%@",self.trip.wait_duration,[LanguageHelper getStringWithKey:self.trip.wait_duration<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
    float total = [_trip.trip_fare floatValue];
    self.lblRideCostValue.text = [Utilities formatAmountAndCurrency:total<=0.0?0.0:total currency:cModel.city_cur];
    _lblTotalFare.text = [Utilities formatAmountAndCurrency:total<=0.0?0.0:total currency:cModel.city_cur];
    //Promo
    self.lblPromoValue.text=[Utilities formatAmountAndCurrency:[self.trip.trip_promo_amt doubleValue] currency:cModel.city_cur];
    //Distance
    self.lblDistanceValue.text =[NSString stringWithFormat:@"%@ %@",tripDis,dis];
    NSString *profile= _trip.user.u_profile_image_path;
    [self.driverRating  setValue:_trip.user.rating];
    [self.lblUserRating setText:[NSString stringWithFormat:@"%0.1f",_trip.user.rating]];
    if (profile.length>0) {
        [_imUserImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    
   
    
    if([self.trip isTripCancelled]){
        [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_r8_s10_cancelled"]];
        if([self.trip isTripCancelledForStatus]){
            [self.lbTripStatus setTextColor:[UIColor redColor]];
        }else{
            [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        }
        [self.lbTripStatus setHidden:NO];
        if([self.trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]||[self.trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]) {
            if([self.trip.trip_pay_status isEqualToString:TS_PAID]){
                [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_r8_s10_cancelled"]/*@"Payment Awaited"*/];
                [self.lbTripStatus setTextColor:[UIColor redColor]];
            }else{
                [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_trip_payment_awaited"]/*@"Payment Awaited"*/];
                [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
            }
        }
    }else
    {
        [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        [self.lbTripStatus setText:isEmpty(self.trip.trip_Status)];
        [self.lbTripStatus setHidden:NO];
        if([self.trip.trip_Status isEqualToString:TS_END]&&[self.trip.trip_pay_status isEqualToString:TS_PAID]) {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_com_18_completed"]];
        }else if([self.trip.trip_Status isEqualToString:TS_END])  {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_trip_payment_awaited"]/*@"Payment Awaited"*/];
        }else  if([self.trip.trip_Status isEqualToString:TS_REQUEST])
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_request"]/*@"Request"*/];
        }else  if([self.trip.trip_Status isEqualToString:TS_ASSIGNED])
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_assigned"]];
        }else
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"p_14_s4_ongoing"]/*@"Ongoing"*/];
        }
    }
}


-(void)setThemeConstants{
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
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

- (IBAction)ButtonBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
}



-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation)
    {
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
    return pinView;
}



- (IBAction)onCloseButtonTap:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController ];
    if(self.delegate!=nil)
    {
        [self.delegate onCloseTripDetail];
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onChatButtonTap:(id)sender {
    [self openChatViewController];
}

-(void) openChatViewController
{
    ChatViewController *vc = (ChatViewController*)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.CHAT_VC];
    vc.tripID=self.trip.trip_Id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onPassengerDetails:(id)sender {
    
    [PassengerDetailsAlertView showPessangeDetails: self.view withData:self.trip.trip_customer_details];
}

- (IBAction)onFareDetailsButTap:(id)sender {
    FareDetailsViewController *vc = (FareDetailsViewController*)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.FARE_DETAIL_VC];
    vc.trip=self.trip;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
