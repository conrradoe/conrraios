//
//  FareAmmountViewController.m
//  TaxiDriver
//
//  Created by  Appicial on 29/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "FareAmmountViewController.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "AppDelegate.h"
#import "UpdateUserCurrentLocation.h"
#import "CategoryModel.h"
#import "Utilities.h"
#import "HomeViewController.h"
#import "ConrraViajesCerrados.h"
#import "StarRatingView.h"
#import "NSString+URLEncoding.h"
#import "FareReviewViewController.h"
#define kLabelAllowance 50.0f
#define kStarViewHeight 35.0f
#define kStarViewWidth 180.0f
#define kLeftPadding 5.0f
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "TripTransactionManager.h"
#import "TripModel+Helper.h"
#import "ConrraChatDeSoporte.h"
#import "CityModel.h"
@interface FareAmmountViewController ()<TripTransactionManagerDelegate>
{
    double driverComm;
    BOOL isPaid,isCollectCashCalled;
    NSTimer * timerGetTripDetail;
    BOOL isViewDisAppearCalled,updatePaymentAmount;
    StarRatingView* starViewNoLabel;
    StarRatingView* starViewNoLabelDone;
    UIAlertController * actionOkButton;
    int ratingGiven;
    
}
@property (strong, nonatomic) ConstantModel *constantModel;

@end

@implementation FareAmmountViewController{
    TripTransactionManager * tripTransactionManager;
    /// Para no encadenar dos cierres: la pregunta puede contestarse dos veces si el conductor
    /// toca rapido, y dos navegaciones seguidas dejan la pila rara.
    BOOL yaSeCerroElViaje;

    UIScrollView      *_ndReceiptScroll;
    UIImageView       *_ndPassengerImg;
    UILabel           *_ndPassengerNameLbl;
    UILabel           *_ndPassengerRatingLbl;
    UILabel           *_ndPickupNameLbl;
    UILabel           *_ndPickupAddrLbl;
    UILabel           *_ndDropNameLbl;
    UILabel           *_ndDropAddrLbl;
    UILabel           *_ndDateTimeLbl;
    UILabel           *_ndTripIdLbl;
    UILabel           *_ndDriverIdLbl;
    UILabel           *_ndTaxLbl;
    UILabel           *_ndRideCostLbl;
    UILabel           *_ndTotalLbl;
    UIView            *_ndRatingView;
    HCSStarRatingView *_ndStarRating;
    UITextView        *_ndFeedbackView;
    UIView            *_ndTicketView;
    CGFloat            _ndNotchY;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _btnPaymentReceived.hidden=YES;
    tripTransactionManager = [[TripTransactionManager alloc] initWithTrip:self.curr_trip];
    tripTransactionManager.delegate = self;
    ratingGiven= 0;
    [self.btnFarereview setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
    [self.btnEndTheRide setConstraintConstant:43 forAttribute:(NSLayoutAttributeHeight)];
    [self.btnOffline setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
    self.constantModel=[ConstantModel getConstantsObject];
    defaults_remove(DRIVER_STATUS_TEMP);
    [self setUIFiels];
    [self.viewStarContainer.layer setBorderColor:[UIColor colorNamed:@"color_app_label"].CGColor];
    [self.viewStarContainer.layer setBorderWidth:1];
    [self setThemeConstants];
    self.txtviewFeedback.placeholder = [LanguageHelper getStringWithKey:@"k_21_s8_feedback"];
    float TripFare = [_curr_trip.trip_fare doubleValue];
    CityModel *cityModel= [CityModel getCityByDriverCityId];
    _lblFareAmt.text = [self formatAmountDual:TripFare currency:cityModel.city_cur];
    [self setPickDropAddress];



    if(cityModel) {
        driverComm = TripFare - TripFare*cityModel.city_comm/100;
    }else{
        driverComm = TripFare - TripFare*0/100;
    }
    _lblDriverCommision.text = [self formatAmountDual:driverComm currency:cityModel.city_cur];
    
    if([self.curr_trip isTripSingleRide])
    {
        [self.viewRating setHidden:YES];
    }else
    {
        [self.viewRating setHidden:NO];
    }
    ratingGiven=self.curr_trip.user_rating;
    [self getTripDetails:NO];
    [self updateRatingDone];
    [self showDistanceAndDuration];
    [self setDataPromoCode ];
    self.txtviewFeedback.clipsToBounds=YES;
    [self.txtviewFeedback.layer setCornerRadius:5];
    [self.txtviewFeedback.layer setBorderWidth:1];
    [self.txtviewFeedback.layer setBorderColor:[UIColor grayColor].CGColor];
    ConstantModel *_currType =[ConstantModel getConstantsObject];
    if([_currType getCValueFK:ckey_e1]){

    }else
    {
        [self.btnFareDetails hideByWidth:YES];
    }
    [self setupNewDesign];
}

-(void)setUIFiels{
    
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_1_s8_fare_summary"];
    self.lblAmtPayable.text = [LanguageHelper getStringWithKey:@"k_2_s8_amount_payable"];
    // self.txtEmail.placeholder=[LanguageHelper getStringWithKey:@"k_6_s3_email_address"];
    self.lblDropLoacation.text = [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    self.lblPicupLocation.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    
    
    self.lblDistance.text = [LanguageHelper getStringWithKey:@"k_3_s8_distance"];
    self.lblDuration.text = [LanguageHelper getStringWithKey:@"k_4_s8_duration"];
    //    self.lblDistance.text = [LanguageHelper getStringWithKey:@"k_3_s8_distance"];
    self.lbPromocode.text=@"";
    //    self.lbPromocode.text = [LanguageHelper getStringWithKey:@"k_16_s8_promo_code_applied"];
    self.lblComment.text = [LanguageHelper getStringWithKey:@"k_7_s8_comment"];
    self.lblRateRide.text = [LanguageHelper getStringWithKey:@"k_20_s8_plz_rate_rider"];
    
    
    [self.btnFarereview setTitle: [LanguageHelper getStringWithKey:@"k_5_s8_fare_review"]   forState:UIControlStateNormal];
    [self.btnOffline setTitle: [LanguageHelper getStringWithKey:@"k_9_s8_go_offline"]   forState:UIControlStateNormal];
    [self.btnPaymentReceived setTitle:[LanguageHelper getStringWithKey:@"k_8_s8_pago_recibido" defaultValue:@"Pago recibido"] forState:UIControlStateNormal];
    [self.btnHome setTitle: [LanguageHelper getStringWithKey:@"k_r30_s9_home"]   forState:UIControlStateNormal];
    [self.btnSkip setTitle: [LanguageHelper getStringWithKey:@"k_22_s8_skip"]   forState:UIControlStateNormal];
    [self.btnDone setTitle: [LanguageHelper getStringWithKey:@"k_23_s8_done"]   forState:UIControlStateNormal];
    [self.btnEndTheRide setTitle: [LanguageHelper getStringWithKey:@"k_19_s8_rcvd_cash_btn"]   forState:UIControlStateNormal];
    
}







-(void) showDistanceAndDuration{
    NSString *dis;
    NSString *tripDis;
    CityModel * citModel=[CityModel getCityByCityId:self.curr_trip.city_id];
    dis =citModel.city_dist_unit;
    tripDis = self.curr_trip.trip_distance;
    if(tripDis.length==0) {
        tripDis=@"0.00";
    }
    self.lbDistanceVal.text =[NSString stringWithFormat:@"%@ %@",tripDis,dis];
    
    NSString *time = [self getHoursAndMinutesForAll];
    [self.lbDurationVal setText:time];
}


-(NSString *)getHoursAndMinutesForAll{
    if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL]){
        return [Utilities getHoursAndMinutesMin:self.curr_trip.trip_total_time];
    }
    if(self.curr_trip.trip_total_time>0){
        return [Utilities getHoursAndMinutesMin:self.curr_trip.trip_total_time];
    }
    NSDate *date1 = [Utilities GetGMTDatetoLocalTZ1:self.curr_trip.trip_pickup_time];
    NSDate *date2 = [Utilities GetGMTDatetoLocalTZ1:self.curr_trip.trip_drop_time];
    if(date2==nil){
        date2=[NSDate date];
    }
    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
    return [Utilities getHoursAndMinutesSeconds:secondsBetween];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUIFiels];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotification:) name:AppNotificationName.DRIVER_RECEIVEDATFARE_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification/*UIApplicationWillEnterForegroundNotification*/
                                               object:nil];
    
    if (isViewDisAppearCalled) {
        [self getTripDetails:NO];
    }
    
    isViewDisAppearCalled=NO;
    
}
-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isViewDisAppearCalled=YES;
    [self inavalidateTimerDetails];
    //    [actionOkButton ]
    [actionOkButton dismissViewControllerAnimated:NO completion:^{
        
    }];
}

-(void)inavalidateTimerDetails{
    
    if(timerGetTripDetail)
    {
        [timerGetTripDetail  invalidate];
        timerGetTripDetail=nil;
    }
}

-(void)appDidEnterForeground{
    if (self.navigationController.topViewController == self) {
        
        
        
        
        
        [self getTripDetails:NO];
        
        isViewDisAppearCalled=NO;
    }
}
-(void)setPickDropAddress{
    _lblDropUpAddress.text = _curr_trip.dropLocationApp;
    _lblPickupAddress.text = _curr_trip.pickupLocationApp;
    
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-98, 300) forText:   self.lblPickupAddress.text  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    [self.viewVerticalLine setConstraintConstant:pickHeight+26 forAttribute:NSLayoutAttributeHeight];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Rating

- (IBAction)onBtUserRatignButtonTap:(id)sender {
    if (self.viewStarContainer.isHidden) {
        [self.viewStarBgOverLay setHidden:NO];
        
        CGFloat userRating = ratingGiven ? ratingGiven : 5.0;
        
        starViewNoLabel = [[StarRatingView alloc]initWithFrame:CGRectMake(self.ratingBar.frame.size.width/2 - kStarViewWidth/2, 0, kStarViewWidth, kStarViewHeight) andRating:userRating*20 withLabel:NO animated:YES];
        [starViewNoLabel setUserInteractionEnabled:YES];
        [self.ratingBar addSubview:starViewNoLabel];
        [self.viewStarContainer setHidden:NO];
    }
}




-(void ) updateRatingDone
{
    [starViewNoLabelDone removeFromSuperview];
    starViewNoLabelDone=[[StarRatingView alloc]initWithFrame:CGRectMake(0,0 , self.viewRatingDone.frame.size.width, self.viewRatingDone.frame.size.height) andRating:ratingGiven*20 withLabel:NO animated:YES];
    [starViewNoLabelDone setUserInteractionEnabled:YES];
    [self.viewRatingDone addSubview:starViewNoLabelDone];
}
// rating view ButtonActions
- (IBAction)onRatingSkipButtonTap:(id)sender {
    [self.viewStarContainer setHidden:YES];
    [self.viewStarBgOverLay setHidden:YES];
}



- (IBAction)onRatingDoneButtonTap:(id)sender {
    
    int rating1 = starViewNoLabel.rating/20;
    ratingGiven = rating1;
    [self.curr_trip.user  updateDriverRating:rating1 completionBlock:^(id results, NSError *error) {
        [self updateFeedbackInTrip:rating1];
        [self.viewStarContainer setHidden:YES];
        [self.viewStarBgOverLay setHidden:YES];
        [self updateRatingDone];
    } isShowLoader:YES];
    
}

-(void)updateFeedbackInTrip:(float) rating {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        @"user_rating"         :[NSString stringWithFormat:@"%.2f",rating],
        TRIP_ID               : _curr_trip.trip_Id,
    }];
    
    
    if (self.txtviewFeedback.text.length>0) {
        [dict setObject:[self.txtviewFeedback.text urlEncodeUsingEncoding] forKey:@"user_feedback"];
    }
    self.curr_trip.user_rating=rating;
    [GIC mkwu:TRIP_UPDATE
            d:dict
          isa:NO
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            // success
            self.curr_trip.user_rating =  rating;
        }
        
        
    }];
    
}
-(void)setThemeConstants{
    
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
    [_lblHireMeCard setFont:FONTS_THEME_REGULAR(18)];
    [_lblDriverAmountTitle setFont:FONTS_THEME_REGULAR(16)];
    [_lblDriverCommision setFont:FONTS_THEME_REGULAR(24)];
    [_lblAmountCollectedTitle setFont:FONTS_THEME_REGULAR(16)];
    [_lblFareAmt setFont:FONTS_THEME_REGULAR(24)];
    [_lblPromoAmount setFont:FONTS_THEME_REGULAR(13)];
    //[_btnHome.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    // [_btnOffline.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    // [_btnFarereview.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    //[_btnPaymentReceived.titleLabel setFont:FONTS_THEME_REGULAR(18)];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"FareReviewViewController"]) {
        
        FareReviewViewController *farerev =(FareReviewViewController *)[segue destinationViewController];
        farerev.cur_trip =_curr_trip;
    }
}


-(void)getNotification:(NSNotification *) notificationData  {
    NSDictionary * dict=  notificationData.userInfo;
    NSMutableDictionary *dicAps=[dict valueForKey:@"aps"];
    NSString *status=[dicAps objectForKey:@"trip_status"];
    //    NSString *trip_id=[dicAps objectForKey:@"trip_id"];
    if ( [status isEqualToString:CASH_PAY] || [status isEqualToString:PAYPAL_PAY] ||[status isEqualToString:CARD]) {
        if (timerGetTripDetail && timerGetTripDetail.isValid) {
            [self inavalidateTimerDetails];
        }
        if (!isPaid) {
            [self getTripDetails:YES];
        }
    }
}


/// Returns a formatted string showing the amount in local currency and, if a
/// currency_conversion rate is configured, also the USD equivalent.
/// e.g.  "Bs. 350.00  ($10.00 USD)"
-(NSString *)formatAmountDual:(double)amount currency:(NSString *)currency {
    NSString *localStr = [Utilities formatAmountAndCurrency:amount currency:currency];
    ConstantModel *constants = [ConstantModel getConstantsObject];
    NSString *rateStr = constants.currency_conversion;
    if (rateStr.length > 0) {
        float rate = [rateStr floatValue];
        if (rate > 0) {
            NSString *upperCur = [currency uppercaseString];
            if (![upperCur isEqualToString:@"USD"] && ![upperCur isEqualToString:@"$"]) {
                double usdAmount = amount / rate;
                return [NSString stringWithFormat:@"%@  ($%.2f USD)", localStr, usdAmount];
            }
        }
    }
    return localStr;
}

-(void)showPromoAndTripFareOnUi{
    CityModel *cityModel= [CityModel getCityByDriverCityId];
    if ([self.curr_trip.trip_promo_amt doubleValue] >0) {
        double amt = [self.curr_trip.trip_fare doubleValue];
        if (amt<=0) {
            amt=0;
        }
        self.lblFareAmt.text = [self formatAmountDual:amt currency:cityModel.city_cur];
        [self.lblPromoAmount setText:[NSString stringWithFormat:@"%@ %@",[LanguageHelper getStringWithKey:@"k_16_s8_promo_code_applied"],[Utilities formatAmountAndCurrency:[self.curr_trip.trip_promo_amt doubleValue] currency:cityModel.city_cur]]];
        self.lblPromoAmount.hidden =NO;
    }else{
        self.lblPromoAmount.hidden =YES;
        double amt = [self.curr_trip.trip_fare doubleValue];
        self.lblFareAmt.text = [self formatAmountDual:amt currency:cityModel.city_cur];
    }
}



-(void)getTripDetails:(BOOL) Showloader{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"trip_id" :_curr_trip.trip_Id,
    }];
    if (Showloader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:TRIP_GETTRIP
            d:dict
          isa:NO
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            self.curr_trip = [[TripModel alloc] initItemWithDict:[[results objectForKey:P_RESPONSE]objectAtIndex:0]];
            [self setDataPromoCode ];
            [self setPickDropAddress];
            [self showDistanceAndDuration];
            [self showPromoAndTripFareOnUi];
            [self ndUpdateReceiptUI];
            if([self.curr_trip isTripSingleRide]){
                [self.viewRating setHidden:YES];
            }else{
                [self.viewRating setHidden:NO];
            }
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            /*
             El viaje cuenta como cobrado tambien con paid_cancel.

             Android mira las DOS (handleTripResponse: `Paid` o `paid_cancel`) y aqui solo se
             miraba Paid. paid_cancel es lo que queda cuando el conductor declara que el
             pasajero no pago: el viaje esta cerrado y no hay nada mas que cobrar, pero iOS lo
             trataba como pendiente y seguia ofreciendo cobrar.
             */
            BOOL viajeCerrado = [self.curr_trip.trip_pay_status isEqualToString:TS_PAID] ||
                                [self.curr_trip.trip_pay_status caseInsensitiveCompare:TS_RIDER_CANCEL_CANCEL] == NSOrderedSame;
            if (viajeCerrado) {
                self->isPaid =YES;
                if(  !self->isCollectCashCalled){
                    self->isCollectCashCalled =YES;
                    /*
                     El mensaje, segun como se pago.

                     Esta rama ya existia con sus tres casos... y los tres ponian EXACTAMENTE
                     el mismo texto, el generico de viaje completado. Alguien la dejo montada
                     y sin rellenar, asi que al conductor de un viaje pagado con billetera no
                     se le decia en ninguna parte que el dinero ya estaba en su saldo. Se
                     quedaba mirando la pantalla esperando un efectivo que no venia.

                     Android si lo dice (showWalletCreditNoticeIfNeeded) y con el importe
                     delante, que es lo unico que zanja la duda.
                     */
                    NSString *messgae=[LanguageHelper getStringWithKey:@"k_17_s8_promo_comp_success"];
                    NSString *importe = [self importeCobradoConMoneda];
                    if([self.curr_trip.trip_pay_mode isEqualToString:HIRE_ME_WALLET_PAY]){
                        messgae = importe.length > 0
                            ? [NSString stringWithFormat:@"Se acreditaron %@ a tu billetera por este viaje.", importe]
                            : @"El pago de este viaje se acreditó a tu billetera.";
                    }else if([self.curr_trip.trip_pay_mode isEqualToString:CARD]){
                        messgae = importe.length > 0
                            ? [NSString stringWithFormat:@"El pago de %@ se procesó con tarjeta.", importe]
                            : @"El pago de este viaje se procesó con tarjeta.";
                    }
                    self.curr_trip.driver.d_is_available=@"1";
                    [self clearData];
                    if([self.presentedViewController isKindOfClass:[UIAlertController class]]){
                        [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
                            self->actionOkButton = [self showAlertWithOk:@"" message:messgae handler:^(UIAlertAction * _Nonnull action) {
                                NSString *driverStatus = TS_WAITING;
                                defaults_set_object(DRIVER_STATUS, driverStatus);
                                [self.btnHome setHidden:NO];
                                [self unhideViews];
                            }];
                        }];
                    }else{
                        self->actionOkButton = [self showAlertWithOk:@"" message:messgae handler:^(UIAlertAction * _Nonnull action) {
                            NSString *driverStatus = TS_WAITING;
                            defaults_set_object(DRIVER_STATUS, driverStatus);
                            [self.btnHome setHidden:NO];
                            [self unhideViews];
                        }];
                    }
                }
            }
            else{
                if(!self->isViewDisAppearCalled) {
                    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                    [self inavalidateTimerDetails];
                    self->timerGetTripDetail=[NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector: @selector(timerFired:) userInfo: @(NO) repeats: NO];
                }
            }
        }
        else{
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            [self inavalidateTimerDetails];
            self->timerGetTripDetail=[NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector: @selector(timerFired:) userInfo: @(NO) repeats: NO];
        }
    }];
}





-(void)timerFired:(NSTimer *)sender {
    
    [self getTripDetails:[sender.userInfo boolValue]];
}


-(void) setDataPromoCode
{
    CityModel *cityModel= [CityModel getCityByDriverCityId];
    if([self.curr_trip.trip_promo_amt floatValue]>0)    {
        //        self.lbPromocode.text=[NSString stringWithFormat:@"%@ (%@) : %@",[LanguageHelper getStringWithKey:@"k_16_s8_promo_code_applied"],[self.curr_trip.trip_promo_code uppercaseString],[Utilities formatAmountAndCurrency:[self.curr_trip.trip_promo_amt doubleValue] currency:cityModel.city_cur]];
        self.lbPromocode.text =@"";
    }else{
        self.lbPromocode.text=@"";
    }
    //    self.lbPromocode.text=@""; // for Bargain GO App
}

/**
 El importe cobrado, con su moneda, o cadena vacia si no se sabe.

 Android lee trip_pay_amount, que es lo que el pasajero pago de verdad. Aqui se usa trip_fare
 porque TripModel de iOS no trae el otro campo: es el mismo numero salvo cuando hubo
 promocion. Si algun dia hace falta la distincion, se añade la propiedad y se cambia esta
 linea, no las tres de arriba.
 */
-(NSString *)importeCobradoConMoneda {
    NSString *crudo = isEmpty(self.curr_trip.trip_fare);
    if (crudo.length == 0) {
        return @"";
    }
    CityModel *ciudad = [CityModel getCityByCityId:self.curr_trip.city_id];
    NSString *conMoneda = [Utilities formatAmountAndCurrency:[crudo floatValue]
                                                    currency:ciudad.city_cur];
    return conMoneda.length > 0 ? conMoneda : crudo;
}

-(void)onCashPaymentCompleted{
    [self.btnHome setHidden:NO];
    [self unhideViews];
}
-(void)onCashPaymentError{
    
}









-(void)unhideViews {
    
    _btnHome.hidden=NO;
    _btnOffline.hidden=NO;
    self.topMarginEndTheRide.constant = 0;
    [self.btnOffline setConstraintConstant:43 forAttribute:(NSLayoutAttributeHeight)];
    [self.btnFarereview setConstraintConstant:43 forAttribute:(NSLayoutAttributeHeight)];
    [self.btnEndTheRide setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
    _btnFarereview.hidden=NO;
    _btnPaymentReceived.hidden=YES;
    
    [self clearData];
    [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"1"];
}

-(void)clearData{
    if([self.curr_trip.driver.d_is_available intValue]>0){
        defaults_set_object(DRIVER_STATUS, TS_WAITING);
        defaults_remove(DRIVER_STATUS_TEMP);
        defaults_remove(TRIP_ID);
        defaults_remove(@"wait_time_start");
        defaults_remove(@"cal_wait_time");
        NSMutableDictionary *dictDriver = [[[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT] mutableCopy];
        [dictDriver setObject:@"1" forKey:P_DRIVER_AVAILAILITY];
        defaults_set_object(P_USER_DICT, dictDriver);
    }
}

- (IBAction)ButtonOffline:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:[LanguageHelper getStringWithKey:@"k_29_s8_offline_alert_message"]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        //Handle your yes please button action here
        
        [self updateDriverStatus];
        
    }];
    
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
    }];
    
    [alertController addAction:actionYes];
    [alertController addAction:actionNo];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)ButtonFarereviewPressed:(id)sender {
    
    //    [self performSegueWithIdentifier:@"FareReviewViewController" sender:nil];
    FareReviewViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"Farereview"];
    details.cur_trip =self.curr_trip;
    details.view.backgroundColor=[UIColor clearColor];
    [self addChildViewController:details];
    [details.view setFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:details.view];
    [details didMoveToParentViewController:self];
}

/**
 Cierra el viaje y devuelve al conductor a su pantalla.

 LA SALIDA NO PUEDE DEPENDER DE UNA LLAMADA. Antes la navegacion estaba DENTRO del
 `if(error==nil)` de updateDriverAvailablity: si esa llamada fallaba -- red mala, servidor
 lento, la cuenta sin verificar, cualquier cosa -- el conductor tocaba y no pasaba nada. Se
 quedaba encerrado en el recibo, con los tres botones (la X, Aceptar y Omitir) llevando todos
 al mismo sitio y ninguno funcionando. Su unica esperanza era que el pasajero pagara y
 calificara, que no depende de el.

 Ahora se sale SIEMPRE. La disponibilidad se manda igual, pero no manda sobre la navegacion:
 si falla, el conductor ya esta en su pantalla y desde ahi puede volver a ponerse en linea,
 que es una accion que tiene delante y entiende. Quedarse atrapado en un recibo no.

 El estado local se limpia tambien siempre: si no, la app arrancaria creyendo que sigue en un
 viaje que ya termino.
 */
- (IBAction)ButtonHome:(id)sender {
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"1" completionBlock:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if (error != nil) {
            NSLog(@"[Recibo] no se pudo poner al conductor disponible, pero se sale igual: %@",
                  error.localizedDescription);
        }
        {
            defaults_set_object(DRIVER_STATUS, TS_WAITING);
            defaults_remove(DRIVER_STATUS_TEMP);
            defaults_remove(TRIP_ID);
            defaults_remove(@"wait_time_start");
            defaults_remove(@"cal_wait_time");
            [self stopOldLocationUpdate];
            //            if([[[NSUserDefaults standardUserDefaults] objectForKey:P_IS_SINGLE_MODE] boolValue])    {
            //                HomeViewController * vcHome1=(HomeViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC];
            //                HomeViewSingleModeController * vcHome=(HomeViewSingleModeController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_SINGLE_VC];
            //                [self.navigationController setViewControllers:@[vcHome1,vcHome] animated:YES];
            //            }else
            //            {
            HomeViewController * vcHome=(HomeViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC];
            vcHome.isRequiredToResfrehDriverProfile = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@(NO)  forKey:P_IS_SINGLE_MODE];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.navigationController setViewControllers:@[vcHome] animated:YES];
            
            //}
        }
    }];
}


-(void)updateDriverStatus{
    
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:@"0" completionBlock:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if(error==nil){
            defaults_set_object(DRIVER_STATUS, TS_WAITING);
            defaults_remove(DRIVER_STATUS_TEMP);
            defaults_remove(TRIP_ID);
            defaults_remove(@"wait_time_start");
            defaults_remove(@"cal_wait_time");
            [self stopOldLocationUpdate];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"change_switch1" object:nil];
            //            if([[[NSUserDefaults standardUserDefaults] objectForKey:P_IS_SINGLE_MODE] boolValue])
            //            {
            //                HomeViewController * vcHome1=(HomeViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC];
            //                HomeViewSingleModeController * vcHome=(HomeViewSingleModeController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_SINGLE_VC];
            //
            //                [self.navigationController setViewControllers:@[vcHome1,vcHome] animated:YES];
            //            }else
            //            {
            HomeViewController * vcHome=(HomeViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC];
            vcHome.isRequiredToResfrehDriverProfile = YES;
            [[NSUserDefaults standardUserDefaults] setObject:@(NO)  forKey:P_IS_SINGLE_MODE];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.navigationController setViewControllers:@[vcHome] animated:YES];
            
            //            }
        }
    }];
    
    
}


- (IBAction)onEndTheRide:(id)sender {
    /*
     "¿Recibiste el Pago del Pasajero?", no "¿recibiste el efectivo?".

     Esta pregunta sale con cualquier modo de pago, tambien cuando el viaje se cobro por
     billetera o tarjeta. Preguntar por el EFECTIVO en esos casos desconcierta: el conductor
     no recibio ningun billete y no sabe que contestar, y si dice que no se va derecho a
     soporte por un pago que nunca iba a ser en mano. Preguntando por el PAGO, la respuesta
     es la misma decision en los tres casos: llego o no llego.
     */
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:[LanguageHelper getStringWithKey:@"k_19_s8_pregunta_pago" defaultValue:@"¿Recibiste el Pago del Pasajero?"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        // Se registra el cobro y se cierra. El registro no decide la salida: si falla, el
        // viaje se cierra igual y el dinero se reclama por soporte, que es lo que hay. Dejar
        // al conductor en el recibo esperando a que una llamada salga bien no arregla nada.
        [self->tripTransactionManager payWithCashDetectComssion];
        [self cerrarElViajeYVolver];
    }];

    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
        // Se abre soporte y, al cerrarse esa hoja, se cierra el viaje igual. Decir que no te
        // pagaron no puede costarte quedarte encerrado: el viaje termino de todas formas.
        [self abrirSoportePorPagoNoRecibidoYLuegoCerrar:YES];
    }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)ButtonPaymentReceived:(id)sender {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:[LanguageHelper getStringWithKey:@"k_19_s8_pregunta_pago" defaultValue:@"¿Recibiste el Pago del Pasajero?"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
        if (![self.curr_trip.trip_pay_status isEqualToString:TS_PAID]) {
            [self markTripAsRiderCancelForPayment];
        }
        [self cerrarElViajeYVolver];
    }];

    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
        [self abrirSoportePorPagoNoRecibidoYLuegoCerrar:YES];
    }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
/**
 El conductor dice que NO recibio el efectivo.

 Los dos dialogos que le preguntan si cobro tenian el "No" VACIO: el conductor decia que no
 le habian pagado y no pasaba nada de nada. Cerraba el aviso y se quedaba igual, sin cobrar
 y sin a quien decirselo. Es el peor momento posible para un boton que no hace nada.

 La hoja no se monta aqui: es la misma que abren "Contactanos" y "Chatea con Nosotros" desde
 los menus laterales, con otro motivo. Tener tres copias de lo mismo es garantia de que el
 dia que alguien arregle una, las otras dos se queden atras. Ver ConrraChatDeSoporte.

 Se le pasan el viaje y el importe para que el mensaje los lleve escritos: soporte no puede
 buscar nada con un "no me pagaron" a secas.
 */
/**
 Soporte por pago no recibido y, si se pide, cierre del viaje al salir de esa hoja.

 @param cerrarDespues YES cuando esto viene de la pregunta del pago: el viaje termina igual
 */
-(void)abrirSoportePorPagoNoRecibidoYLuegoCerrar:(BOOL)cerrarDespues {
    NSString *viajeId = isEmpty(self.curr_trip.trip_Id);
    NSString *monto = @"";
    NSString *crudo = isEmpty(self.curr_trip.trip_fare);
    if (crudo.length > 0) {
        CityModel *ciudad = [CityModel getCityByCityId:self.curr_trip.city_id];
        NSString *conMoneda = [Utilities formatAmountAndCurrency:[crudo floatValue]
                                                        currency:ciudad.city_cur];
        monto = conMoneda.length > 0 ? conMoneda : crudo;
    }
    __weak typeof(self) yo = self;
    [ConrraChatDeSoporte abrirEn:self
                          motivo:ConrraMotivoPagoNoRecibido
                           viaje:viajeId
                           monto:monto
                        alCerrar:cerrarDespues ? ^{ [yo cerrarElViajeYVolver]; } : nil];
}

/**
 Cierra el viaje y devuelve al conductor a su mapa. Pase lo que pase.

 Aqui NO se comprueba nada ni se espera a ninguna respuesta. El viaje ya termino: lo que
 quede pendiente -- registrar el cobro, marcar el estado, volver a estar disponible -- se
 intenta por su cuenta y, si falla, se reintenta desde el mapa o se reclama por soporte.
 Ninguna de esas cosas justifica tener al conductor mirando un recibio del que no puede salir.
 */
-(void)cerrarElViajeYVolver {
    if (yaSeCerroElViaje) {
        return;
    }
    yaSeCerroElViaje = YES;
    [self inavalidateTimerDetails];

    /*
     Se apunta el viaje como terminado ANTES de navegar.

     El mapa sondea por driver_id, sin id de viaje, y el servidor le sigue devolviendo este
     viaje mientras no este cobrado. Sin esta marca, al llegar al mapa el sondeo lo ve en
     "completed" y vuelve a mandar al conductor aqui. Ese era el bucle.
     */
    [ConrraViajesCerrados cerrar:isEmpty(self.curr_trip.trip_Id)];

    /*
     La navegacion NO pasa por ButtonHome a proposito.

     ButtonHome navega dentro del bloque de respuesta de updateDriverAvailablity. Con la
     respuesta lenta o colgada -- que es justo lo que pasa en mala cobertura, y en mala
     cobertura es cuando el conductor mas necesita cerrar y seguir -- ese bloque tarda o no
     llega nunca, y el conductor se queda mirando el recibo. Aqui se sale primero y se avisa
     al servidor despues.
     */
    [[UpdateUserCurrentLocation sharedInstance] updateDriverAvailablity:@"1"
                                                        completionBlock:^(id results, NSError *error) {
        if (error != nil) {
            NSLog(@"[Recibo] no se pudo poner al conductor disponible: %@", error.localizedDescription);
        }
    }];

    defaults_set_object(DRIVER_STATUS, TS_WAITING);
    defaults_remove(DRIVER_STATUS_TEMP);
    defaults_remove(TRIP_ID);
    defaults_remove(@"wait_time_start");
    defaults_remove(@"cal_wait_time");
    [self stopOldLocationUpdate];
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:P_IS_SINGLE_MODE];
    [[NSUserDefaults standardUserDefaults] synchronize];

    dispatch_async(dispatch_get_main_queue(), ^{
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        HomeViewController *vcHome =
            (HomeViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.HOME_VC];
        vcHome.isRequiredToResfrehDriverProfile = YES;
        [self.navigationController setViewControllers:@[vcHome] animated:YES];
    });
}

-(void)abrirSoportePorPagoNoRecibido {
    NSString *viajeId = isEmpty(self.curr_trip.trip_Id);

    NSString *monto = @"";
    NSString *crudo = isEmpty(self.curr_trip.trip_fare);
    if (crudo.length > 0) {
        CityModel *ciudad = [CityModel getCityByCityId:self.curr_trip.city_id];
        NSString *conMoneda = [Utilities formatAmountAndCurrency:[crudo floatValue]
                                                        currency:ciudad.city_cur];
        monto = conMoneda.length > 0 ? conMoneda : crudo;
    }

    [ConrraChatDeSoporte abrirEn:self
                          motivo:ConrraMotivoPagoNoRecibido
                           viaje:viajeId
                           monto:monto];
}


-(void)markTripAsRiderCancelForPayment
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
    [dict setObject:self.curr_trip.trip_Id forKey:@"trip_id"];
    [dict setObject:TS_RIDER_CANCEL_CANCEL forKey:TRIP_STATUS];
    [self.curr_trip updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
        if([[results objectForKey:P_STATUS]isEqualToString:@"OK"])
        {
            //            AppDelegate * appDelegate=APP_DELEGATE;
            //            appDelegate.trip_status=TS_PAID;
            NSString *driverStatus = TS_WAITING;
            defaults_set_object(DRIVER_STATUS, driverStatus);
            [self.btnHome setHidden:NO];
            [self unhideViews];
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
    } isShowLoader:YES isSendNotification:NO];
}






- (IBAction)onFareDetailsButTap:(id)sender {
    FareDetailsViewController *vc = (FareDetailsViewController*)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.FARE_DETAIL_VC];
    vc.trip=self.curr_trip;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)setupNewDesign {
    for (UIView *v in self.view.subviews) { v.hidden = YES; }
    self.view.backgroundColor = UIColor.whiteColor;

    UIColor *yellow   = [UIColor colorNamed:@"app_theame"]
                        ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    UIColor *dark     = [UIColor colorNamed:@"color_app_label"] ?: [UIColor colorWithWhite:0.12 alpha:1];
    UIColor *gray     = [UIColor colorWithWhite:0.5 alpha:1];
    UIColor *ticketBg = [UIColor colorWithWhite:0.96 alpha:1];
    CGFloat  w        = self.view.bounds.size.width;
    CGFloat  pad      = 20;
    CGFloat  tickW    = w - pad * 2;

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scroll.alwaysBounceVertical = YES;
    scroll.showsVerticalScrollIndicator = NO;
    _ndReceiptScroll = scroll;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    CGFloat headerH = 60;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, headerH)];
    headerView.backgroundColor = UIColor.whiteColor;
    [content addSubview:headerView];

    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(pad, 0, w - pad*2, headerH)];
    titleLbl.text = @"Recibo";
    titleLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = dark;
    [headerView addSubview:titleLbl];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(w - pad - 40, (headerH - 40)/2.0, 40, 40);
    closeBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    closeBtn.layer.cornerRadius = 20;
    closeBtn.tintColor = dark;
    if (@available(iOS 13, *)) {
        [closeBtn setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    } else {
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:dark forState:UIControlStateNormal];
    }
    [closeBtn addTarget:self action:@selector(ndFareCloseTapped) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeBtn];

    UIView *hSep = [[UIView alloc] initWithFrame:CGRectMake(0, headerH - 1, w, 1)];
    hSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [headerView addSubview:hSep];

    CGFloat y = headerH + 28;

    CGFloat avatarSz = 80;
    _ndPassengerImg = [[UIImageView alloc] initWithFrame:CGRectMake((w - avatarSz)/2, y, avatarSz, avatarSz)];
    _ndPassengerImg.layer.cornerRadius = avatarSz / 2;
    _ndPassengerImg.clipsToBounds = YES;
    _ndPassengerImg.contentMode = UIViewContentModeScaleAspectFill;
    _ndPassengerImg.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [content addSubview:_ndPassengerImg];
    y += avatarSz + 12;

    _ndPassengerNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(pad, y, w - pad*2, 24)];
    _ndPassengerNameLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    _ndPassengerNameLbl.textColor = dark;
    _ndPassengerNameLbl.textAlignment = NSTextAlignmentCenter;
    [content addSubview:_ndPassengerNameLbl];
    y += 28;

    _ndPassengerRatingLbl = [[UILabel alloc] initWithFrame:CGRectMake(pad, y, w - pad*2, 20)];
    _ndPassengerRatingLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:14] ?: [UIFont systemFontOfSize:14];
    _ndPassengerRatingLbl.textColor = gray;
    _ndPassengerRatingLbl.textAlignment = NSTextAlignmentCenter;
    [content addSubview:_ndPassengerRatingLbl];
    y += 28;

    CGFloat tpad  = 16;
    CGFloat iconW = 22;
    CGFloat lblX  = tpad + iconW + 10;
    CGFloat lblW  = tickW - lblX - tpad;
    CGFloat ty    = tpad;

    UIImageView *pickIcon = [[UIImageView alloc] initWithFrame:CGRectMake(tpad, ty, iconW, iconW)];
    pickIcon.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *pickImg = [UIImage imageNamed:@"ic_trip_pickup"];
    if (!pickImg && @available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
        pickImg = [[UIImage systemImageNamed:@"mappin.circle.fill" withConfiguration:cfg]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        pickIcon.tintColor = [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1];
    }
    pickIcon.image = pickImg;

    _ndPickupNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(lblX, ty, lblW, 18)];
    _ndPickupNameLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    _ndPickupNameLbl.textColor = dark;
    _ndPickupNameLbl.numberOfLines = 1;
    ty += 20;

    _ndPickupAddrLbl = [[UILabel alloc] initWithFrame:CGRectMake(lblX, ty, lblW, 28)];
    _ndPickupAddrLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:11] ?: [UIFont systemFontOfSize:11];
    _ndPickupAddrLbl.textColor = gray;
    _ndPickupAddrLbl.numberOfLines = 2;
    ty += 30;

    CGFloat dashTop = tpad + iconW + 3;
    CGFloat dashBot = ty + 2 - 3;
    UIView *dashLineView = [[UIView alloc] initWithFrame:CGRectMake(tpad + iconW/2 - 1, dashTop, 2, dashBot - dashTop)];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2, 8), NO, 0);
    [[UIColor colorWithWhite:0.72 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, 2, 4));
    UIImage *dashImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dashLineView.backgroundColor = [UIColor colorWithPatternImage:dashImg];

    UIImageView *destIcon = [[UIImageView alloc] initWithFrame:CGRectMake(tpad, ty, iconW, iconW)];
    destIcon.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *destImg = [UIImage imageNamed:@"ic_trip_drop"];
    if (!destImg && @available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg2 = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
        destImg = [[UIImage systemImageNamed:@"flag.circle.fill" withConfiguration:cfg2]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        destIcon.tintColor = [UIColor colorWithRed:0.1 green:0.65 blue:0.3 alpha:1];
    }
    destIcon.image = destImg;

    _ndDropNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(lblX, ty, lblW, 18)];
    _ndDropNameLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    _ndDropNameLbl.textColor = dark;
    _ndDropNameLbl.numberOfLines = 1;
    ty += 20;

    _ndDropAddrLbl = [[UILabel alloc] initWithFrame:CGRectMake(lblX, ty, lblW, 28)];
    _ndDropAddrLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:11] ?: [UIFont systemFontOfSize:11];
    _ndDropAddrLbl.textColor = gray;
    _ndDropAddrLbl.numberOfLines = 2;
    ty += 28 + tpad;

    CGFloat notchDivY = ty;
    UIView *notchDivider = [[UIView alloc] initWithFrame:CGRectMake(tpad, notchDivY, tickW - tpad*2, 1)];
    notchDivider.backgroundColor = [UIColor colorWithWhite:0.82 alpha:1];
    ty += 1 + 14;

    _ndDateTimeLbl = [self ndFareMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *dateKey = [self ndFareMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"Fecha / Hora:"];
    ty += 28;

    _ndTripIdLbl = [self ndFareMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *tripIdKey = [self ndFareMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"ID del Traslado:"];
    ty += 28;

    _ndDriverIdLbl = [self ndFareMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *driverIdKey = [self ndFareMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"ID del Conductor:"];
    ty += 28 + 6;

    UIView *fareSep = [[UIView alloc] initWithFrame:CGRectMake(tpad, ty, tickW - tpad*2, 1)];
    fareSep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    ty += 1 + 14;

    _ndTaxLbl = [self ndFareMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *taxKey = [self ndFareMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"Impuestos:"];
    ty += 28;

    _ndRideCostLbl = [self ndFareMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *fareKey = [self ndFareMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"Traslado:"];
    ty += 28;

    UILabel *totalKey = [[UILabel alloc] initWithFrame:CGRectMake(tpad, ty, tickW*0.5, 22)];
    totalKey.text = @"Total:";
    totalKey.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    totalKey.textColor = dark;

    _ndTotalLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, ty, tickW - tpad, 22)];
    _ndTotalLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    _ndTotalLbl.textColor = dark;
    _ndTotalLbl.textAlignment = NSTextAlignmentRight;
    ty += 22 + tpad;

    UIView *ticket = [[UIView alloc] initWithFrame:CGRectMake(pad, y, tickW, ty)];
    ticket.backgroundColor = ticketBg;
    _ndTicketView = ticket;
    _ndNotchY = notchDivY;
    [content addSubview:ticket];

    [ticket addSubview:pickIcon];
    [ticket addSubview:_ndPickupNameLbl];
    [ticket addSubview:_ndPickupAddrLbl];
    [ticket addSubview:dashLineView];
    [ticket addSubview:destIcon];
    [ticket addSubview:_ndDropNameLbl];
    [ticket addSubview:_ndDropAddrLbl];
    [ticket addSubview:notchDivider];
    [ticket addSubview:dateKey];
    [ticket addSubview:_ndDateTimeLbl];
    [ticket addSubview:tripIdKey];
    [ticket addSubview:_ndTripIdLbl];
    [ticket addSubview:driverIdKey];
    [ticket addSubview:_ndDriverIdLbl];
    [ticket addSubview:fareSep];
    [ticket addSubview:taxKey];
    [ticket addSubview:_ndTaxLbl];
    [ticket addSubview:fareKey];
    [ticket addSubview:_ndRideCostLbl];
    [ticket addSubview:totalKey];
    [ticket addSubview:_ndTotalLbl];

    [self ndFareApplyTicketMask];

    y += ty + 32;

    /*
     "Terminar viaje", no "Aceptar".

     Es el boton que cierra el ciclo, como el de Android. "Aceptar" no dice que hace -- parece
     un simple enterado -- y el conductor que quiere volver a trabajar no sabe donde tocar.

     Sigue llevando a la hoja de calificacion, que es opcional y tiene su "Omitir". Debajo va
     una salida directa para el que no quiera pasar ni por ahi.
     */
    UIButton *aceptarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aceptarBtn.frame = CGRectMake(pad, y, tickW, 56);
    aceptarBtn.backgroundColor = yellow;
    aceptarBtn.layer.cornerRadius = 16;
    aceptarBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    [aceptarBtn setTitle:[LanguageHelper getStringWithKey:@"k_s10_terminar_viaje" defaultValue:@"Terminar viaje"]
                forState:UIControlStateNormal];
    [aceptarBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [aceptarBtn addTarget:self action:@selector(ndFareAceptarTapped) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:aceptarBtn];
    y += 56 + 12;

    /*
     La salida sin calificar, siempre visible.

     El conductor puede tener al siguiente pasajero esperando. Obligarle a pasar por la hoja de
     calificacion para volver al mapa es tiempo que pierde, y si algo falla en esa hoja se
     queda encerrado otra vez. Este boton va directo.
     */
    UIButton *salirBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    salirBtn.frame = CGRectMake(pad, y, tickW, 44);
    salirBtn.backgroundColor = [UIColor clearColor];
    salirBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    [salirBtn setTitle:[LanguageHelper getStringWithKey:@"k_s10_volver_al_mapa" defaultValue:@"Volver al mapa sin calificar"]
              forState:UIControlStateNormal];
    [salirBtn setTitleColor:[UIColor colorWithWhite:0.45 alpha:1] forState:UIControlStateNormal];
    [salirBtn addTarget:self action:@selector(ndFareSkipRatingTapped) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:salirBtn];
    y += 44 + 40;

    content.frame = CGRectMake(0, 0, w, y);
    scroll.contentSize = CGSizeMake(w, y);

    CGFloat h      = self.view.bounds.size.height;
    CGFloat sheetH = h * 0.72;

    _ndRatingView = [[UIView alloc] initWithFrame:self.view.bounds];
    _ndRatingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    _ndRatingView.hidden = YES;
    [self.view addSubview:_ndRatingView];

    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, h, w, sheetH)];
    sheet.backgroundColor = UIColor.whiteColor;
    sheet.layer.cornerRadius = 24;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.layer.masksToBounds = YES;
    sheet.tag = 9910;
    [_ndRatingView addSubview:sheet];

    CGFloat hdr2 = 56;
    UILabel *sheetTitle = [[UILabel alloc] initWithFrame:CGRectMake(pad, 0, w - pad*2 - 48, hdr2)];
    sheetTitle.text = [LanguageHelper getStringWithKey:@"k_s10_rate_passenger" defaultValue:@"Califica al pasajero"];
    sheetTitle.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    sheetTitle.textColor = dark;
    sheetTitle.textAlignment = NSTextAlignmentCenter;
    [sheet addSubview:sheetTitle];

    UIButton *ratingCloseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    ratingCloseBtn.frame = CGRectMake(w - 48, 0, 48, hdr2);
    [ratingCloseBtn setTitle:@"✕" forState:UIControlStateNormal];
    ratingCloseBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [ratingCloseBtn setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
    [ratingCloseBtn addTarget:self action:@selector(ndFareSkipRatingTapped) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:ratingCloseBtn];

    CGFloat sy = hdr2 + 12;

    CGFloat avatarSz2 = 80;
    UIImageView *rPassengerImg = [[UIImageView alloc] initWithFrame:CGRectMake((w - avatarSz2)/2, sy, avatarSz2, avatarSz2)];
    rPassengerImg.layer.cornerRadius = avatarSz2 / 2;
    rPassengerImg.clipsToBounds = YES;
    rPassengerImg.contentMode = UIViewContentModeScaleAspectFill;
    rPassengerImg.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    rPassengerImg.tag = 9911;
    [sheet addSubview:rPassengerImg];
    sy += avatarSz2 + 12;

    UILabel *rName = [[UILabel alloc] initWithFrame:CGRectMake(pad, sy, w - pad*2, 26)];
    rName.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    rName.textAlignment = NSTextAlignmentCenter;
    rName.textColor = dark;
    rName.tag = 9912;
    [sheet addSubview:rName];
    sy += 30;

    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(pad, sy, w - pad*2, 1)];
    sep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [sheet addSubview:sep];
    sy += 20;

    _ndStarRating = [[HCSStarRatingView alloc] initWithFrame:CGRectMake((w - 260)/2, sy, 260, 52)];
    _ndStarRating.value = 0;
    _ndStarRating.allowsHalfStars = NO;
    _ndStarRating.accurateHalfStars = NO;
    _ndStarRating.tintColor = yellow;
    NSBundle *bundle = [NSBundle mainBundle];
    UIImage *starFilled = [UIImage imageNamed:@"ic_star" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *starEmpty  = [UIImage imageNamed:@"ic_star_empty" inBundle:bundle compatibleWithTraitCollection:nil];
    if (starFilled) {
        _ndStarRating.filledStarImage = starFilled;
        if (starEmpty) {
            _ndStarRating.emptyStarImage = starEmpty;
        } else {
            UIGraphicsBeginImageContextWithOptions(starFilled.size, NO, starFilled.scale);
            [starFilled drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:0.28];
            UIImage *generated = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            _ndStarRating.emptyStarImage = generated;
        }
    }
    [sheet addSubview:_ndStarRating];
    sy += 64;

    UIColor *cardBg = [UIColor colorWithWhite:0.96 alpha:1];
    _ndFeedbackView = [[UITextView alloc] initWithFrame:CGRectMake(pad, sy, w - pad*2, 90)];
    _ndFeedbackView.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    _ndFeedbackView.textColor = dark;
    _ndFeedbackView.backgroundColor = cardBg;
    _ndFeedbackView.layer.cornerRadius = 12;
    _ndFeedbackView.textContainerInset = UIEdgeInsetsMake(14, 14, 14, 14);
    [sheet addSubview:_ndFeedbackView];

    UILabel *phLbl = [[UILabel alloc] initWithFrame:CGRectMake(pad + 18, sy + 16, w - pad*2 - 36, 22)];
    phLbl.text = @"Deja un comentario...";
    phLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    phLbl.textColor = [UIColor colorWithWhite:0.68 alpha:1];
    phLbl.tag = 9913;
    [sheet addSubview:phLbl];
    sy += 106;

    CGFloat btnGap = 12;
    CGFloat btnW   = (w - pad*2 - btnGap) / 2;
    UIColor *lightYellow = [UIColor colorWithRed:0.99 green:0.95 blue:0.76 alpha:1];

    UIButton *omitirBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    omitirBtn.frame = CGRectMake(pad, sy, btnW, 56);
    omitirBtn.backgroundColor = lightYellow;
    omitirBtn.layer.cornerRadius = 16;
    omitirBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    [omitirBtn setTitle:@"Omitir" forState:UIControlStateNormal];
    [omitirBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [omitirBtn addTarget:self action:@selector(ndFareSkipRatingTapped) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:omitirBtn];

    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(pad + btnW + btnGap, sy, btnW, 56);
    submitBtn.backgroundColor = yellow;
    submitBtn.layer.cornerRadius = 16;
    submitBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    [submitBtn setTitle:[LanguageHelper getStringWithKey:@"k_s10_rate" defaultValue:@"Calificar"] forState:UIControlStateNormal];
    [submitBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(ndFareSubmitRatingTapped) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:submitBtn];

    [self ndUpdateReceiptUI];
}

-(void)ndFareApplyTicketMask {
    if (!_ndTicketView) return;
    CGRect bounds = _ndTicketView.bounds;
    if (CGRectIsEmpty(bounds)) return;

    CGFloat radius = 14.0;
    CGFloat notchR = 12.0;
    CGFloat localY = _ndNotchY;

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];

    UIBezierPath *leftNotch = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, localY)
                                                             radius:notchR
                                                         startAngle:-M_PI_2
                                                           endAngle:M_PI_2
                                                          clockwise:YES];
    [path appendPath:leftNotch];

    UIBezierPath *rightNotch = [UIBezierPath bezierPathWithArcCenter:CGPointMake(bounds.size.width, localY)
                                                              radius:notchR
                                                          startAngle:M_PI_2
                                                            endAngle:-M_PI_2
                                                           clockwise:YES];
    [path appendPath:rightNotch];

    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = bounds;
    mask.path = path.CGPath;
    mask.fillRule = kCAFillRuleEvenOdd;
    _ndTicketView.layer.mask = mask;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self ndFareApplyTicketMask];
}

-(UILabel *)ndFareMakeKeyLabelAt:(CGRect)frame gray:(UIColor *)gray text:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    lbl.text = text;
    lbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    lbl.textColor = gray;
    return lbl;
}

-(UILabel *)ndFareMakeValueLabelAt:(CGRect)frame dark:(UIColor *)dark {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y, frame.size.width - 16, frame.size.height)];
    lbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    lbl.textColor = dark;
    lbl.textAlignment = NSTextAlignmentRight;
    return lbl;
}

-(void)ndUpdateReceiptUI {
    if (!_ndReceiptScroll) return;
    CityModel *city = [CityModel getCityByDriverCityId];
    NSString *cur   = city ? city.city_cur : @"$";
    UIColor *yellow = [UIColor colorNamed:@"app_theame"]
                      ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    UIColor *gray   = [UIColor colorWithWhite:0.5 alpha:1];

    // Passenger name
    NSString *name = [[NSString stringWithFormat:@"%@ %@",
                       self.curr_trip.user.u_fname ?: @"",
                       self.curr_trip.user.u_lname ?: @""]
                      stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    _ndPassengerNameLbl.text = name.length > 0 ? name : [LanguageHelper getStringWithKey:@"k_s3_passenger_name" defaultValue:@"Pasajero"];

    // Passenger photo
    NSString *photoPath = self.curr_trip.user.u_profile_image_path;
    if (photoPath.length > 0) {
        NSURL *photoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, photoPath]];
        [_ndPassengerImg sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    } else {
        _ndPassengerImg.image = [UIImage imageNamed:@"Profile Icon Crop Image"];
    }

    // Passenger rating — yellow star + "4.6 (125)"
    NSMutableAttributedString *ratingStr = [[NSMutableAttributedString alloc] init];
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:13 weight:UIImageSymbolWeightMedium];
        UIImage *base = [UIImage systemImageNamed:@"star.fill" withConfiguration:cfg];
        UIGraphicsBeginImageContextWithOptions(base.size, NO, 0);
        [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(ctx, kCGBlendModeSourceIn);
        [yellow setFill];
        CGContextFillRect(ctx, CGRectMake(0, 0, base.size.width, base.size.height));
        UIImage *yellowStar = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSTextAttachment *att = [[NSTextAttachment alloc] init];
        att.image = yellowStar;
        att.bounds = CGRectMake(0, -1, 13, 13);
        [ratingStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
        [ratingStr appendAttributedString:[[NSAttributedString alloc] initWithString:
            [NSString stringWithFormat:@" %.1f (%d)", self.curr_trip.user.rating, (int)self.curr_trip.user.rating_count]
            attributes:@{ NSFontAttributeName: _ndPassengerRatingLbl.font,
                          NSForegroundColorAttributeName: gray }]];
    } else {
        ratingStr = [[NSMutableAttributedString alloc] initWithString:
            [NSString stringWithFormat:@"★ %.1f (%d)", self.curr_trip.user.rating, (int)self.curr_trip.user.rating_count]];
    }
    _ndPassengerRatingLbl.attributedText = ratingStr;

    // Sync passenger info to rating sheet
    UIImageView *rImg = (UIImageView *)[_ndRatingView viewWithTag:9911];
    UILabel *rNameLbl = (UILabel *)[_ndRatingView viewWithTag:9912];
    rNameLbl.text = _ndPassengerNameLbl.text;
    if (photoPath.length > 0) {
        NSURL *u = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, photoPath]];
        [rImg sd_setImageWithURL:u placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    } else {
        rImg.image = _ndPassengerImg.image;
    }

    // Addresses — split into name (before first comma) + rest
    NSString *fullPickup = self.curr_trip.pickupLocationApp ?: self.curr_trip.trip_pick_loc ?: @"";
    NSArray *pickParts = [fullPickup componentsSeparatedByString:@","];
    _ndPickupNameLbl.text = pickParts.count > 0
        ? [pickParts[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] : fullPickup;
    _ndPickupAddrLbl.text = pickParts.count > 1
        ? [[[pickParts subarrayWithRange:NSMakeRange(1, pickParts.count - 1)] componentsJoinedByString:@","]
           stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] : @"";

    NSString *fullDrop = self.curr_trip.dropLocationApp ?: self.curr_trip.trip_drop_loc ?: @"";
    NSArray *dropParts = [fullDrop componentsSeparatedByString:@","];
    _ndDropNameLbl.text = dropParts.count > 0
        ? [dropParts[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] : fullDrop;
    _ndDropAddrLbl.text = dropParts.count > 1
        ? [[[dropParts subarrayWithRange:NSMakeRange(1, dropParts.count - 1)] componentsJoinedByString:@","]
           stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] : @"";

    // Date/Time
    NSDateFormatter *parser = [[NSDateFormatter alloc] init];
    parser.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *tripDate = [parser dateFromString:self.curr_trip.trip_pickup_time];
    if (tripDate) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [NSLocale localeWithLocaleIdentifier:@"es_ES"];
        fmt.dateFormat = @"d MMM yyyy - HH:mm";
        _ndDateTimeLbl.text = [fmt stringFromDate:tripDate];
    } else {
        _ndDateTimeLbl.text = self.curr_trip.trip_pickup_time ?: @"";
    }

    // IDs
    _ndTripIdLbl.text   = self.curr_trip.trip_Id ?: @"";
    _ndDriverIdLbl.text = self.curr_trip.driver.car_registration_no ?: self.curr_trip.driver.driverId ?: @"";

    // Fare breakdown
    float tax   = [self.curr_trip.tax_amount_r floatValue];
    float total = [self.curr_trip.trip_fare floatValue];
    float ride  = total - tax;
    _ndTaxLbl.text      = [Utilities formatAmountAndCurrency:tax   currency:cur];
    _ndRideCostLbl.text = [Utilities formatAmountAndCurrency:ride  currency:cur];
    // Show total in local currency AND USD equivalent
    _ndTotalLbl.text    = [self formatAmountDual:total currency:cur];
}

// Screen 1 → X close
-(void)ndFareCloseTapped {
    [self cerrarElViajeYVolver];
}

// Screen 1 → Aceptar → show rating sheet
-(void)ndFareAceptarTapped {
    _ndRatingView.hidden = NO;
    UIView *sheet = [_ndRatingView viewWithTag:9910];
    CGFloat h = self.view.bounds.size.height;
    sheet.frame = CGRectMake(0, h, sheet.frame.size.width, sheet.frame.size.height);
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.5 options:0 animations:^{
        sheet.frame = CGRectMake(0, h - sheet.frame.size.height, sheet.frame.size.width, sheet.frame.size.height);
    } completion:nil];
}

// Screen 2 → Calificar
-(void)ndFareSubmitRatingTapped {
    float rating = _ndStarRating.value;
    ratingGiven = (int)rating;
    NSString *feedback = _ndFeedbackView.text;
    /*
     Red de seguridad: si la calificacion tarda mas de tres segundos, se cierra igual.

     updateDriverRating llama a su bloque siempre... cuando la llamada VUELVE. Si se queda
     colgada, no vuelve nunca y el conductor se queda con la hoja de estrellas puesta. La
     calificacion es lo menos importante de este momento; salir, lo mas.
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self cerrarElViajeYVolver];
    });
    [self.curr_trip.user updateDriverRating:ratingGiven completionBlock:^(id results, NSError *error) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"user_rating": [NSString stringWithFormat:@"%.2f", (float)self->ratingGiven],
            TRIP_ID: self.curr_trip.trip_Id ?: @"",
        }];
        if (feedback.length > 0) {
            [dict setObject:[feedback urlEncodeUsingEncoding] forKey:@"user_feedback"];
        }
        [GIC mkwu:TRIP_UPDATE d:dict isa:NO cb:^(id r, NSError *e) {}];
        [self cerrarElViajeYVolver];
    } isShowLoader:NO];
}

// Screen 2 → Omitir / close
-(void)ndFareSkipRatingTapped {
    [self cerrarElViajeYVolver];
}

@end
