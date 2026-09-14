//
//  FareReviewViewController.m
//  TaxiDriver
//
//  Created by  Appicial on 29/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "FareReviewViewController.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import <MapKit/MapKit.h>
#import "CustomPointAnnotation.h"
#import "ConstantModel.h"
#import "RoundShapeBg.h"
#import "CategoryModel.h"
#import "UIImageView+WebCache.h"
#import "Utilities.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "TripModel+Helper.h"
@interface FareReviewViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *imgCar;

@end

@implementation FareReviewViewController
{
    NSMutableArray *arrAnotation;
    CategoryModel *carCategory;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUIFiels];
    arrAnotation=[[NSMutableArray alloc]  init];
    [self setThemeConstants];
    ConstantModel *_currType =[ConstantModel getConstantsObject];;
    if([_currType getCValueFK:ckey_e1]){
        self.viewNewFare.hidden=NO;
        self.costDetailView.hidden=YES;
    }else{
        self.viewNewFare.hidden=YES;
        self.costDetailView.hidden=NO;
    }
//    RoundShapeBg * roundShapBg= [[RoundShapeBg alloc] init];
//    roundShapBg.pading=20;
//    roundShapBg.txtWidth=120;
//    [roundShapBg makeRound:self.viewOnScroll tripModel:self.cur_trip heightView:472+15+40 bottomTop:120+15+10];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews]; 
    RoundShapeBg * roundShapBg= [[RoundShapeBg alloc] init];
    roundShapBg.pading=20;
    roundShapBg.txtWidth=120;
    int bottom=self.viewBottomDivider.frame.origin.y-10;
    int height=self.viewContainer.frame.size.height;
    [roundShapBg makeRound:self.viewContainer tripModel:self.cur_trip heightView:height bottomTop:height-bottom];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setUIFiels{
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_5_s8_fare_review"];
    
    self.lblPicUp.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    self.lblDrop.text = [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    
    self.lblTripIdText.text = [LanguageHelper getStringWithKey:@"k_8_s11_trip_id"];
    self.lblDriverIdText.text = [LanguageHelper getStringWithKey:@"k_9_s11_user_id"];
    self.lblWaitTimeText.text = [LanguageHelper getStringWithKey:@"k_3_s11_wait_time"];
    self.lblPromoText.text = [LanguageHelper getStringWithKey:@"k_4_s11_promo"];
    self.lblDistanceText.text = [LanguageHelper getStringWithKey:@"k_3_s8_distance"];
    self.lblTaxText.text = [LanguageHelper getStringWithKey:@"k_6_s11_taxes"];
    self.lblRideCostText.text =[LanguageHelper getStringWithKey:@"k_7_s11_ride_cost"];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUIFiels];
    [self.imgUser setClipsToBounds:YES];
    [self.imgUser.layer setBorderWidth:1];
    [self.imgUser.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.imgUser.layer setCornerRadius:self.imgUser.frame.size.width / 2];
    
    carCategory = [CategoryModel getCategoryByid:self.cur_trip.driver.category_id];
    
    CityModel * cModel=[CityModel getCityByCityId:self.cur_trip.city_id];
    NSString *dis;
    NSString *tripDis;
    dis =cModel.city_dist_unit;
    tripDis = self.cur_trip.trip_distance;
    self.lblTripIdValue.text =_cur_trip.trip_Id;
    self.lblDriverIdValue.text=[NSString stringWithFormat:@"%d",_cur_trip.user.userId];
    _lblDropLocation.text =_cur_trip.dropLocationApp;
    _lblPickupLocation.text =_cur_trip.pickupLocationApp;
    
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-125, 300) forText: _lblPickupLocation.text  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    
    self.lblPicUp.text=self.cur_trip.pickupTitleWithPickUpTime;
    self.lblDrop.text=self.cur_trip.dropTitleWithDropTime;
    
    CGFloat pickPickTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-125, 300) forText:  self.lblPicUp.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat pickDropTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-125, 300) forText:  self.lblDrop.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    
    [self.viewVerticalLine setConstraintConstant:pickHeight+26+pickPickTimeHeight+pickDropTimeHeight-50 forAttribute:NSLayoutAttributeHeight];
   
    _starRating.text = [NSString stringWithFormat:@"%.1f",self.cur_trip.user.rating];
    [self.viewRating setValue:self.cur_trip.user.rating];
    
    // taxes
    self.lblTaxValue.text = [Utilities formatAmountAndCurrency:[self.cur_trip.tax_amount floatValue] currency:cModel.city_cur];
    NSString *imageName;
    self.imgCar.image = [UIImage imageNamed:imageName];
    
    self.lbCarCategoryName.text=carCategory.cat_name;
//    self.lbCarCategoryName.text= [NSString stringWithFormat:@"%@ (%@ #%@)",self.cur_trip.cat_name,[LanguageHelper getStringWithKey:@"k_8_s11_trip" defaultValue:@"Trip"],self.cur_trip.trip_Id];
    self.lblDistanceValue.text =[NSString stringWithFormat:@"%@ %@",tripDis,dis];
    
    float total = [_cur_trip.trip_fare floatValue];
    
    if (total<=0.0) {
        total =0.0;
    }
    
  
    
    _lblTotalFare.text = [Utilities formatAmountAndCurrency:[self.cur_trip.trip_fare floatValue] currency:cModel.city_cur];
  
    self.lblRideCostValue.text=[Utilities formatAmountAndCurrency:total currency:cModel.city_cur];
    
    
    _lblUserName.text=[NSString stringWithFormat:@"%@ %@", _cur_trip.user.u_fname,_cur_trip.user.u_lname];
    NSString *profile= _cur_trip.user.u_profile_image_path;
    
    if (profile.length>0) {
        [_imgUser sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    
    if(self.cur_trip.trip_promo_code.length>0)  {
        self.lblPromoValue.text=[Utilities formatAmountAndCurrency:[self.cur_trip.trip_promo_amt doubleValue] currency:cModel.city_cur];
    }else{
        self.lblPromoValue.text=@"";
        self.lblPromoValue.text=[Utilities formatAmountAndCurrency:[self.cur_trip.trip_promo_amt doubleValue] currency:cModel.city_cur];
    }
    
    self.lblWaitTimeValue.text=[NSString stringWithFormat:@"%d%@",self.cur_trip.wait_duration,[LanguageHelper getStringWithKey:self.cur_trip.wait_duration<=1?@"k_17_s4_min":@"k_17_s4_mins"]];
    
    [self initMapView];
}


-(CGFloat) DegreesToRadians:(CGFloat )degrees
{
    return degrees * M_PI / 180;
};

-(CGFloat) RadiansToDegrees:(CGFloat) radians
{
    return radians * 180 / M_PI;
}


-(void)setThemeConstants{
    [_lbCarCategoryName setFont:FONTS_THEME_REGULAR(16)];
    [_lblUserName setFont:FONTS_THEME_REGULAR(16)];
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


- (IBAction)ButtonBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBackButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController  popViewControllerAnimated:YES];
}
- (IBAction)onCloseButtonTap:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController ];
}

- (IBAction)onFareDetailsButTap:(id)sender {
    FareDetailsViewController *vc = (FareDetailsViewController*)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.FARE_DETAIL_VC];
    vc.trip=self.cur_trip;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
