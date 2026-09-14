//
//  ;
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 29/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "UFareSummeryViewController.h"
#import "LanguageHelper.h"
#import <Conrra-Swift.h>
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "AppDelegate.h"
#import "UFareReviewViewController.h"
#import "PromoCodeModel.h"
#import "CityModel.h"
#import "UHomeViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIViewController+Extension.h"
#import "NSString+URLEncoding.h"
#import "StarRatingView.h"  
#import "Utilities.h"
#import "UAddMoneyWalletVC.h"
#define kLabelAllowance 50.0f
#define kStarViewHeight 35.0f
#define kStarViewWidth 180.0f
#define kLeftPadding 5.0f
#import "TripModel+Helper.h"
#import "UserProfile.h"
#import "UIImageView+WebCache.h"
//#import <Razorpay/Razorpay-Swift.h>

@interface UFareSummeryViewController ()<UITextViewDelegate, /*RazorpayPaymentCompletionProtocol,*/ /*STPAddCardViewControllerDelegate, STPPaymentCardTextFieldDelegate,*/
/* stripe STPPaymentOptionsViewControllerDelegate, STPPaymentContextDelegate ,stripe */UAddMoneyWalletVCDelegate>
{
    double driverComm;
    PromoCodeModel *promoCode ;
    BOOL isSkipCalled;
    BOOL isRatingDoneCalled;
    StarRatingView* starViewNoLabel;
    NSTimer *tripCheckTimer;
    BOOL isCalledCashOnHand,isCalledPayWithCard;
    int apiCounter,apiCounterPromo;
    BOOL isPromoApplied;
    NSString *promoAmt;
    float chrageByCardChargedByCard;
    int     ratingGiven;

}
@property (weak, nonatomic) IBOutlet UIImageView *imgCartBack;

@property (strong, nonatomic) UIScrollView      *ndReceiptScroll;
@property (strong, nonatomic) UIImageView       *ndDriverImg;
@property (strong, nonatomic) UILabel           *ndDriverNameLbl;
@property (strong, nonatomic) UILabel           *ndDriverRatingLbl;
@property (strong, nonatomic) UILabel           *ndPickupNameLbl;
@property (strong, nonatomic) UILabel           *ndPickupAddrLbl;
@property (strong, nonatomic) UILabel           *ndDropNameLbl;
@property (strong, nonatomic) UILabel           *ndDropAddrLbl;
@property (strong, nonatomic) UILabel           *ndDateTimeLbl;
@property (strong, nonatomic) UILabel           *ndTripIdLbl;
@property (strong, nonatomic) UILabel           *ndDriverIdLbl;
@property (strong, nonatomic) UILabel           *ndTaxLbl;
@property (strong, nonatomic) UILabel           *ndRideCostLbl;
@property (strong, nonatomic) UILabel           *ndTotalLbl;
@property (strong, nonatomic) UILabel           *ndPagoMovilLbl;
@property (strong, nonatomic) UIView            *ndRatingView;
@property (strong, nonatomic) HCSStarRatingView *ndStarRating;
@property (strong, nonatomic) UITextView        *ndFeedbackView;
@property (strong, nonatomic) UIView            *ndTicketView;
@property (assign, nonatomic) CGFloat            ndNotchY;
@end

@implementation UFareSummeryViewController
{
//    RazorpayCheckout * razorpay;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    ConstantModel * con=[ConstantModel getConstantsObject];
//    razorpay = [RazorpayCheckout initWithKey:isEmpty(con.razor_key_id) andDelegate:self];
    
    [self setUIFiels];
    [self.viewStarContainer.layer setBorderColor:[UIColor colorNamed:@"color_app_label"].CGColor];
    [self.viewStarContainer.layer setBorderWidth:1];
    apiCounterPromo =0;
    [self.viewStarContainer setClipsToBounds:YES];
    [self.viewStarContainer.layer  setCornerRadius:2];
    [self.viewStartBgOveryLay  setHidden:YES];
//    AppDelegate * appDelegate=APP_DELEGATE;
//    appDelegate.trip_status=TS_END;
    apiCounter =0;
    [self.viewEnterPromoCode setHidden:YES];
    self.txtPromoCode.layer.cornerRadius=2;
    self.txtPromoCode.clipsToBounds=YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotification:) name:AppNotificationName.USER_ACCEPT_NOTIFICATION object:nil];
    
    ratingGiven=self.curr_trip.trip_rating;
    [self.viewStarRating setValue:ratingGiven];
    [self getTripDetails];
    [self setActualPickUpAndDropLocation];
    [self.btOffline setHidden:YES];
    [self.btFareReview setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
    [self.btFareReview setHidden:YES];
    self.txtviewFeedback.delegate = self;
    [UtilityClass setCornerRadius: self.txtviewFeedback radius:5.0f border:NO];
    [self.txtviewFeedback.layer setBorderWidth:1];
    [self.txtviewFeedback.layer setBorderColor:[UIColor grayColor].CGColor];
    [_lbAmountToPay setFont:FONTS_THEME_REGULAR(24)];
    [self showDistanceAndDuration];
    ConstantModel * constantModel=[ConstantModel getConstantsObject];
    if([constantModel getCValueFK:ckey_e1])
    {
    }else{
        [self.btnFareDetails hideByWidth:YES];
    }
    [self setupNewDesign];
}



-(void) setUIFiels{
    self.txtviewFeedback.placeholder = [LanguageHelper getStringWithKey:@"k_21_s8_feedback"];
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_1_s8_fare_summary"];
    self.lblAmountPayableTitle.text = [LanguageHelper getStringWithKey:@"k_2_s8_amount_payable"];
    self.lblPicupLocation.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    self.lblDropLocation.text = [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    self.txtPromoCode.placeholder=[LanguageHelper getStringWithKey:@"k_r49_s3_enter_valid_promo_code"];
    self.lblComment.text = [LanguageHelper getStringWithKey:@"k_7_s8_comment"];
    self.lblDriverRating.text = [LanguageHelper getStringWithKey:@"k_r32_s9_rate_driver"];
    
    self.lblDistanceText.text = [LanguageHelper getStringWithKey:@"k_3_s8_distance"];
    self.lblDurationText.text = [LanguageHelper getStringWithKey:@"k_4_s8_duration"];
    
    [self.btnApply setTitle: [LanguageHelper getStringWithKey:@"k_r45_s3_apply"]   forState:UIControlStateNormal];
    [self.btFareReview setTitle: [LanguageHelper getStringWithKey:@"k_5_s8_fare_review"]   forState:UIControlStateNormal];
    [self.btSubmit setTitle: [LanguageHelper getStringWithKey:@"k_r9_s9_pay_now"]   forState:UIControlStateNormal];
    [self.btnOffline setTitle: [LanguageHelper getStringWithKey:@"k_r30_s9_home"]   forState:UIControlStateNormal];
    [self.btnSkip setTitle: [LanguageHelper getStringWithKey:@"k_22_s8_skip"]   forState:UIControlStateNormal];
    [self.btnDone setTitle: [LanguageHelper getStringWithKey:@"k_23_s8_done"]   forState:UIControlStateNormal];
    
    [self.btnPromoCode setTitle: [LanguageHelper getStringWithKey:@"k_r7_s9_hve_promo_code"]   forState:UIControlStateNormal];
}
-(void) setActualPickUpAndDropLocation
{
    self.dropAddressLbl.text =self.curr_trip.dropLocationApp;
    self.pickUpAddressLbl.text =self.curr_trip.pickupLocationApp;
    
    
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-108, 300) forText:  self.pickUpAddressLbl.text withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    [self.viewVerticalLine setConstraintConstant:pickHeight+26 forAttribute:NSLayoutAttributeHeight];
}


-(void) showDistanceAndDuration
{
    CityModel *cityModel=[CityModel getCityByCityId:self.curr_trip.city_id];
    NSString *dis;
    NSString *tripDis;
    //    if (isDistanceUnitKm(cityModel.city_dist_unit)/*[[constantModel.constant_distance capitalizedString] isEqualToString:@"Km"]*/) {
    dis =cityModel.city_dist_unit;
    tripDis = self.curr_trip.trip_distance;
    //    }
    //    else{
    //        dis =cityModel.city_dist_unit;
    //        float miles = [self.curr_trip.trip_distance floatValue]*0.621371192;
    //        tripDis = [Utilities formatDistance:
    //                   miles];
    //
    //    }
    if(tripDis.length==0)
    {
        tripDis=@"0.00";
    }
    self.lbDistacneVal.text =[NSString stringWithFormat:@"%@ %@",tripDis,dis];
    NSString *time = [self getHoursAndMinutesForAll];
    [self.lbDurationVal setText:time];
    
    if([self.curr_trip.trip_promo_amt floatValue]>0){
        CityModel * cityModel=[CityModel getCityByCityId:self.curr_trip.city_id];
        self.lbPromocode.text=[NSString stringWithFormat:@"%@ (%@) : %@",[LanguageHelper getStringWithKey:@"k_r15_s9_promo_cde_applied"],[self.curr_trip.trip_promo_code uppercaseString],[Utilities formatAmountAndCurrency:[self.curr_trip.trip_promo_amt doubleValue] currency:cityModel.city_cur]];
    }else{
        self.lbPromocode.text=@"";
    }
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUIFiels];
}



 

-(void)getTripDetails{
    apiCounter =apiCounter+1;
    if (self.curr_trip.trip_Id == 0) {
        self.curr_trip =[[TripModel alloc]init];
//        self.curr_trip.trip_Id = [self.tripId intValue];
    }
    [self.curr_trip refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
        self->ratingGiven=self.curr_trip.trip_rating;
        if ([[[results objectForKey:P_STATUS]  uppercaseString] isEqualToString:@"OK"]) {
            
            [self setDataonUI];
            NSString *tripFare = self.curr_trip.trip_fare;
            self->isPromoApplied = self.curr_trip.isPromoCodeUsed;
            self->promoAmt = self.curr_trip.trip_promo_amt;
            CityModel *  cityModel= [CityModel getCityByCityId:self.curr_trip.city_id];
            float driverCommission=0;
            if(cityModel)  {
                driverCommission=cityModel.city_comm;
            }
//            else   {
//                driverCommission=self.constantModel.connstant_appicial_commission;
//            }
            [self setActualPickUpAndDropLocation];
            self->driverComm = [self.curr_trip.trip_fare doubleValue]- [tripFare doubleValue]*driverCommission/100;
            [self getPaymentStatus];
        }
        else{
            if (self->apiCounter<5) {
                [self getTripDetails];
            }
        }
    } isShowLoader:YES];
}




-(void)setThemeConstants{
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
    [_lblHireMeCard setFont:FONTS_THEME_REGULAR(18)];
    [_lblAmountPayableTitle setFont:FONTS_THEME_REGULAR(16)];
    [_lbTripFareAmount setFont:FONTS_THEME_REGULAR(30)];
    [_lbPromocodeAmount setFont:FONTS_THEME_REGULAR(13)];
    [_btnDone.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_btnOffline.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_btnFareReview.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_btnOffline.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_btnDone.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_btnSkip.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_btnApply.titleLabel setFont:FONTS_THEME_REGULAR(14)];
    [_btnSubmit.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_btnRatingSkip.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_btnratingDone.titleLabel setFont:FONTS_THEME_REGULAR(16)];
    [_lblRateDriver setFont:FONTS_THEME_REGULAR(16)];
    [_txtPromoCode setFont:FONTS_THEME_REGULAR(17)];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


-(void)getNotification:(NSNotification *) notification {    NSDictionary * dict=  notification.userInfo;
    NSMutableDictionary *dicAps=[dict valueForKey:@"aps"];
    NSString *status=[dicAps objectForKey:@"trip_status"];
    NSString *trip_id=[dicAps objectForKey:@"trip_id"];
    
    if([status isEqualToString:TS_PAID] || [status isEqualToString:TS_END])
    {
        
        [self.curr_trip refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
            
            if ([self.curr_trip.trip_pay_status isEqualToString:TS_PAID] && !self->isCalledCashOnHand) {
//                AppDelegate * appDelegate=APP_DELEGATE;
//                appDelegate.trip_status=PAID;
                [self setDataonUI];
                [self showDistanceAndDuration];
            }
            
        } isShowLoader:NO];
        return;
    }
    
    if ( [status isEqualToString:CASH_PAY] || [status isEqualToString:PAYPAL_PAY]) {
        
        if (![self.curr_trip isPaid]) {
            
            [self.curr_trip refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
                [self setDataonUI];
                
            } isShowLoader:NO];
        }
    }
}





-(void)updateFeedbackInTrip:(float ) rating {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        TRIP_ID               : [NSString stringWithFormat:@"%@",_curr_trip.trip_Id],
        @"trip_rating"               : [NSString stringWithFormat:@"%.1f",rating],
    }];
    
    
    if(self.txtviewFeedback.text.length>0)
    {
        [dict setObject:[self.txtviewFeedback.text urlEncodeUsingEncoding] forKey:TRIP_FEEDBACK];
    }
    self.curr_trip.trip_rating=rating;
    [GIC mkwu:TRIP_UPDATE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"]) {
            // success
        }
        
    }];
}


-(void)unhideViews {
    
    defaults_remove(TRIP_ID);
    defaults_remove(TRIP_STATUS);
}

//- (IBAction)ButtonOffline:(id)sender {
//
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
//                                                                             message:[LanguageHelper getStringWithKey:@"k_3_s4_logout"]
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_21_s4_yes"]
//                                                        style:UIAlertActionStyleDefault
//                                                      handler:^(UIAlertAction * action) {
//        [self updateDriverStatus];
//
//    }];
//
//    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no"]                                                     style:UIAlertActionStyleDefault
//                                                     handler:^(UIAlertAction * action) {
//    }];
//
//    [alertController addAction:actionYes];
//    [alertController addAction:actionNo];
//    [self presentViewController:alertController animated:YES completion:nil];
//}

- (IBAction)ButtonFarereviewPressed:(id)sender {
    [self onFareReviewButtonTap:sender];
}

- (IBAction)ButtonHome:(id)sender {
    defaults_remove(TRIP_ID);
    defaults_remove(TRIP_STATUS);
    [self stopOldLocationUpdate];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate loadUserHomeViewController];
}

-(void)navigateHome{
    defaults_remove(TRIP_ID);
    defaults_remove(TRIP_STATUS);
    [self stopOldLocationUpdate];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate loadUserHomeViewController];
}




-(void)sendNotificationPromoCode{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"message"          :[[LanguageHelper sharedInstance] getStringWithKey:@"trip_noti_msg_promo_code" currentLanguage:self.curr_trip.driver.d_lang]/*[LanguageHelper getStringWithKey:@"trip_noti_msg_promo_code"]*/,
        @"content-available":@"1",
    }];
    
    if ([self.curr_trip.driver.deviceType isEqualToString:IOS]) {
        
        [dict setObject:self.curr_trip.driver.deviceToken forKey:IOS_TOKEN];
    }
    else{
        
        [dict setObject:self.curr_trip.driver.deviceToken forKey:ANDROID_TOKEN];
    }
    
    [dict setObject:[NSString stringWithFormat:@"%@",self.curr_trip.trip_Id] forKey:TRIP_ID];
    [dict setObject:PROMO_PAY_ACCEPT forKey:TRIP_STATUS];
    if ([[dict objectForKey:IOS_TOKEN] length]==0  && [[dict objectForKey:ANDROID_TOKEN] length]==0) {
        return;
    }
    [dict setObject:@"driver" forKey:@"to"];
    [GIC mk:url_notification to:send_driver_notification
                  d:dict
      isa:NO
                    cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
        }
    }];
    
    
}
#pragma  mark - UI update


-(void) setDataonUI
{
    [self showDistanceAndDuration];
    [self updateReceiptUI];
  
    if([self.curr_trip isPaid])
    {
        [self setPayment];
        [self.btSubmit setHidden:YES];
        [self.viewPromoCode setHidden:YES];
        [self.btFareReview setHidden:NO];
        [self.btFareReview setConstraintConstant:46 forAttribute:(NSLayoutAttributeHeight)];
        [self.btOffline setHidden:NO];
        [self.btnOffline setHidden:NO];
       
    }
    else{
        
        [self setPayment];
        
        [self.btFareReview setHidden:YES];
        [self.btFareReview setConstraintConstant:0 forAttribute:(NSLayoutAttributeHeight)];
        [self.btOffline setHidden:YES];
        [self.btSubmit setHidden:NO];
        if(self.curr_trip.isPromoCodeUsed ||  [self.curr_trip.trip_promo_amt floatValue]>0.0)
        {
            [self.viewPromoCode setHidden:YES];
        }
        else{
            [self.viewPromoCode setHidden:NO];
        }
    }
    
    
}


/**
 El importe del viaje, y al lado su equivalente en moneda local.

 ESTABA AL REVES, en dos sentidos a la vez:

   - Los importes del viaje vienen en DOLARES, y la tasa dice cuantos bolivares vale un
     dolar (Controller.getDollarToLocalRate de Android: "el equivalente de moneda local por
     cada dolar, ej. 560"). Habia que MULTIPLICAR. Aqui se dividia, y ademas se etiquetaba
     el importe original como si ya estuviera en moneda local: con tasa 560 y un viaje de
     10 $, esto escribia "($0.02 USD)".

   - Leia la constante `currency_conversion`, y el operador rellena `Bs`. Android da
     "prioridad absoluta a 'bs' para sincronizar rider/driver". Mientras esa fuera la unica
     que se mirara, lo mas probable es que no se enseñara ningun importe en bolivares.

 Ahora usa +[ConstantModel tasaDolarALocal], que prueba la misma lista de candidatos que
 Android, y el formato es el suyo: "Bs 5.600,00".
 */
-(NSString *)formatAmountDual:(double)amount currency:(NSString *)currency {
    NSString *enDolares = [Utilities formatAmountAndCurrency:amount currency:currency];
    float tasa = [ConstantModel tasaDolarALocal];
    if (tasa <= 0) {
        return enDolares;
    }

    NSNumberFormatter *formato = [[NSNumberFormatter alloc] init];
    formato.numberStyle = NSNumberFormatterDecimalStyle;
    formato.minimumFractionDigits = 2;
    formato.maximumFractionDigits = 2;
    NSString *enLocal = [formato stringFromNumber:@(amount * tasa)];

    return [NSString stringWithFormat:@"%@  (Bs %@)", enDolares, enLocal];
}

-(void)setPayment{

    CityModel * cityModel=[CityModel getCityByCityId:self.curr_trip.city_id];
    NSString *currency =cityModel.city_cur;

    if(self.curr_trip.isPromoCodeUsed || [self.curr_trip.trip_promo_amt floatValue]>0.0)
    {
        float amt = [_curr_trip.trip_fare doubleValue];
        if (amt<=0.0) {
            amt =0.0;
        }

        _lbAmountToPay.text = [self formatAmountDual:amt currency:currency];
        [_lbPromocodeAmount setText:[NSString stringWithFormat:@"%@ %@",[LanguageHelper getStringWithKey:@"k_r15_s9_promo_cde_applied"]  ,[Utilities formatAmountAndCurrency:[self.curr_trip.trip_promo_amt doubleValue] currency:currency]]];
        self.viewPromoCode.hidden=YES;
    }
    else{
        [_lbPromocodeAmount setText:@""];
        _lbAmountToPay.text = [self formatAmountDual:[_curr_trip.trip_fare doubleValue] currency:currency];
    }
}

#pragma  mark -Handle Button Actions
// bottom button

- (IBAction)onSubmitButtonTap:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_r38_s9_pay_with"]
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    CityModel *  cityModel= [CityModel getCityByCityId:self.curr_trip.city_id];
    
    BOOL isCard=NO;
    BOOL isCash=NO;
    BOOL isWallet=NO;
    if(cityModel){
        if(cityModel.city_pay_options.length>0){
            NSArray * paymentOption=[cityModel.city_pay_options componentsSeparatedByString:@"|"];
            if(paymentOption.count>0){
                for (NSString *  payOption in paymentOption) {
                    if([payOption isEqualToString:@"cash"]) {
                        isCash=YES;
                    }else if([payOption isEqualToString:@"wallet"]){
                        isWallet=YES;
                    }else if([payOption isEqualToString:@"stripe"]){
                        isCard=YES;
                    }
                }
            }
        }
    }else{
       
    }
    NSDictionary * dictUser=defaults_object(P_USER_DICT);
    if(self.curr_trip.city_id!=[UserProfile shared].cityID){
        isWallet=NO;
    }
     if([self.curr_trip isTripCancelledForPay ])  {
         isCash = NO;
     }
    if(cityModel==nil){
        isCash=YES;
    }
    if(isCash) {
        UIAlertAction *actionPayCash = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r39_s9_cash"]
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
            [self payWithCashDetectComssion];
            
        }];
        [actionPayCash setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertController addAction:actionPayCash];
    }
    if(isWallet) {
        UIAlertAction *actionPayByHireMeWallet= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r39_s9_wallet"]
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
            [self payWithHireMeWallet];
            
        }];
        [actionPayByHireMeWallet setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertController addAction:actionPayByHireMeWallet];
    }
    if(isCard) {
        UIAlertAction *actionCreditCard = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_r39_s9_card"]
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
            [self handleDirectPayment];
            
        }];
        [actionCreditCard setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
        [alertController addAction:actionCreditCard];
    }
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"]
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
    }];
    [actionCancel setValue:[UIColor colorNamed:@"app_theame"] forKey:@"titleTextColor"];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}




-(NSDictionary *)JSONFromFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"currency_rate" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}



-(void) payWithHireMeWallet{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    
    
    NSDictionary * dictCurrency=[self JSONFromFile];
    CityModel *  cityModel= [CityModel getCityByCityId:[UserProfile shared].cityID];
    CityModel *  cityModelTrip= [CityModel getCityByCityId:_curr_trip.city_id];
    float currencyMul=1;
    if(cityModel)
    {
        
        NSString * mul=[dictCurrency objectForKey:[NSString stringWithFormat:@"%@%@",cityModelTrip.city_cur,cityModel.city_cur]];
        if(mul)
        {
            currencyMul=   [mul floatValue];
        }
    }
    
    if ((([_curr_trip.trip_fare floatValue])*currencyMul) <= [[dict1 objectForKey:P_USER_WAlLET_AMOUNT]floatValue]){
        
        float driverCommission=0;
        if(cityModelTrip)
        {
            driverCommission =[_curr_trip.trip_fare doubleValue]*(100-cityModelTrip.city_comm)/100;
        }
//        else
//        {
//            driverCommission =[_curr_trip.trip_fare doubleValue]*(100-_constantModel.connstant_appicial_commission)/100;
//        }
        //         float driverCommission =[_curr_trip.trip_fare doubleValue]*(100-cityModelTrip.city_comm)/100;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"user_id":[dict1 objectForKey:P_USER_ID],
            @"total_amt":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
            @"rider_amt":[Utilities formatAmount:currencyMul*([_curr_trip.trip_fare floatValue])],
            @"pay_amount":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
            @"api_key":[ dict1 objectForKey:P_API_KEY],
            @"trip_id":[NSString stringWithFormat:@"%@",_curr_trip.trip_Id],
            P_DRIVER_ID:[NSString stringWithFormat:@"%@",_curr_trip.trip_Driver_Id],
            @"city_id":[NSString stringWithFormat:@"%d",_curr_trip.city_id],
            //                                                                                    @"pay_status":PAID,
            @"trip_driver_commision":[Utilities formatAmount:driverCommission],
            @"pay_mode":HIRE_ME_WALLET_PAY,
            @"trans_description":@"Trip Payment",
            @"promo_amt":[Utilities formatAmount:[self.curr_trip.trip_promo_amt floatValue]],
            @"commission_amt":[Utilities formatAmount:([[Utilities formatAmount:[_curr_trip.trip_fare floatValue]] floatValue]-driverCommission)]
        }];
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        
        [GIC mkwu:GET_WALLET_ADD_TRIP_TRAN
                      d:dict
          isa:NO
               cb:^(id results, NSError *error) {
            
            if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
                // success
                if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]) {
                    //                       NSDictionary *arrtrip = [results objectForKey:P_RESPONSE];
                    NSMutableDictionary *WalletAmtDict = [[[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT] mutableCopy];
                    float toatalAmt=[[WalletAmtDict  objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
                    [WalletAmtDict setObject:[Utilities formatAmount:(toatalAmt-[self->_curr_trip.trip_fare intValue])] forKey:P_USER_WAlLET_AMOUNT ];
                    [[NSUserDefaults standardUserDefaults] setObject:WalletAmtDict forKey:P_USER_DICT];
                    [[NSUserDefaults standardUserDefaults] setObject:WalletAmtDict forKey:P_USER_DICT_LOGGED];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                [self payWithHireMeWallet: YES];
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            }else {}
            
        }];
    }
    else{
        [self showAddMoneyAlert ];
    }
    
    
}


-(void) showAddMoneyAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_r16_s7_nt_engh_wallet"]
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
    }];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}







-(void)openAddMoneyWalletVC{
    UAddMoneyWalletVC *vc=(UAddMoneyWalletVC *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.WALLET_ADD_MOENY_VC ];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    float remaingAmount=[[dict1 objectForKey:P_USER_WAlLET_AMOUNT] floatValue]-([_curr_trip.trip_fare floatValue]);
    if(remaingAmount<0) {
        remaingAmount=remaingAmount*-1;
    }
    vc.addAmount=[Utilities formatAmount:remaingAmount];
    vc.delegate=self;
    [self.navigationController pushViewController:vc animated:YES];
}




-(void)monyAddSucessfully{
    [self payWithHireMeWallet];
}




-(void)payWithHireMeWallet:(BOOL)isSendNotification{
    //   if (!isCalledCashOnHand && !isCalledPayWithCard) {
    
    //       isCalledCashOnHand =YES;
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
    [dict setObject:[NSString stringWithFormat:@"%@",self.curr_trip.trip_Id] forKey:@"trip_id"];
    [dict setObject:HIRE_ME_WALLET_PAY forKey:@"trip_pay_mode"];
    [dict setObject:TS_PAID forKey:@"trip_pay_status"];
    self.curr_trip.trip_pay_mode=HIRE_ME_WALLET_PAY;
    [dict setObject:[Utilities getStringFromDate:[NSDate date]] forKey:@"trip_pay_date"];
    if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL]){
        if(self.curr_trip.is_cancelled){
            [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
        }else{
            [dict setObject:TS_END forKey:TRIP_STATUS];
        }
    }else{
        if(self.curr_trip.is_cancelled==NO){
            if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]||[self.curr_trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
                [dict setObject:TS_END forKey:TRIP_STATUS];
            }
        }
    }
    [self.curr_trip updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
        if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"])
        {
            self.curr_trip.trip_pay_status=TS_PAID;
//            appDelegate.trip_status=TS_PAID;
            [self setDataonUI];
        }
    } isShowLoader:YES isSendNotification:isSendNotification];
}


-(void) payWithPaypal
{
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:SAVED_TOKEN];
    if (savedToken) {
        [self initializeSDKMerchantWithToken:savedToken];
    } else {
        [self loginWithPayPal];
    }
}
- (void)loginWithPayPal {
    [self setWaitingForServer:YES];
    
    // Replace the url with your own sample server endpoint.
    [self forgetTokens];
    NSURL *url = [NSURL URLWithString:@"http://pph-retail-sdk-sample.herokuapp.com/toPayPal/live"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}
- (void)forgetTokens {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVED_TOKEN];
}

- (void)initializeSDKMerchantWithToken:(NSString *)token {
    
}
- (void)gotoPaymentScreen {
    [self setWaitingForServer:NO];
    
}


- (void)setWaitingForServer:(BOOL)waitingForServer {
    [UtilityClass setLH:waitingForServer wt:[LanguageHelper getStringWithKey:@"k_r16_s3_plz_wait"]];
}



-(void) payWithCashDetectComssion{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    CityModel *  cityModel= [CityModel getCityByCityId:self.curr_trip.city_id];
    float driverCommission=0;
    if(cityModel) {
        driverCommission =[_curr_trip.trip_fare doubleValue]*(100-cityModel.city_comm)/100;
    }
//    else{
//        driverCommission =[_curr_trip.trip_fare doubleValue]*(100-_constantModel.connstant_appicial_commission)/100;
//    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id":[dict1 objectForKey:P_USER_ID],
        @"total_amt":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"rider_amt":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"pay_amount":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"api_key":[ dict1 objectForKey:P_API_KEY],
        @"trip_id":[NSString stringWithFormat:@"%@",_curr_trip.trip_Id],
        P_DRIVER_ID:[NSString stringWithFormat:@"%@",_curr_trip.trip_Driver_Id],
        @"trip_driver_commision":[Utilities formatAmount:driverCommission],
        @"pay_mode":@"Cash",
        @"city_id":[NSString stringWithFormat:@"%d",_curr_trip.city_id],
        @"trans_description":@"Trip Payment",
        @"promo_amt":[Utilities formatAmount:[self.curr_trip.trip_promo_amt floatValue]],
        @"commission_amt":[Utilities formatAmount:([[Utilities formatAmount:[_curr_trip.trip_fare floatValue]] floatValue]-driverCommission)]
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:GET_WALLET_ADD_TRIP_TRAN
                  d:dict
      isa:YES
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            // success
            [self payWithCashOnHand: YES];
        }else {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        }
    }];
}


-(void)payWithCashOnHand:(BOOL)isSendNotification
{
    if (!isCalledCashOnHand && !isCalledPayWithCard) {
        
        isCalledCashOnHand =YES;
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
        [dict setObject:[NSString stringWithFormat:@"%@",self.curr_trip.trip_Id] forKey:@"trip_id"];
        [dict setObject:CASH_PAY forKey:@"trip_pay_mode"];
        [dict setObject:TS_PAID forKey:@"trip_pay_status"];
        if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL]){
            if(self.curr_trip.is_cancelled){
                [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
            }else{
                [dict setObject:TS_END forKey:TRIP_STATUS];
            }
        }else{
            if(self.curr_trip.is_cancelled==NO){
                if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]||[self.curr_trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
                    [dict setObject:TS_END forKey:TRIP_STATUS];
                }
            }
        }
        [dict setObject:[Utilities getStringFromDate:[NSDate date]] forKey:@"trip_pay_date"];
        [self.curr_trip updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
            if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"])  {
//                AppDelegate * appDelegate=APP_DELEGATE;
//                appDelegate.trip_status=PAID;
                self.curr_trip.trip_pay_status=TS_PAID;
                [self setDataonUI];
            }
        } isShowLoader:YES isSendNotification:isSendNotification];
    }
}



- (IBAction)onOfflineButtonTap:(id)sender {
    defaults_remove(TRIP_ID);
    defaults_remove(TRIP_STATUS);
    [self stopOldLocationUpdate];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate loadUserHomeViewController];
}

- (IBAction)onFareReviewButtonTap:(id)sender {
    UFareReviewViewController *details = (UFareReviewViewController *)[StoryBoardUtiles viewContollerInUserWithIdentifier:StoryBoardUtiles.UFAREREVIEW_VC ];
    details.cur_trip =self.curr_trip;
    details.view.backgroundColor=[UIColor clearColor];
    [self addChildViewController:details];
    [details.view setFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:details.view];
    [details didMoveToParentViewController:self];
    //    [self performSegueWithIdentifier:@"FareReviewViewController" sender:nil];
}



// rating view ButtonActions
- (IBAction)onRatingSkipButtonTap:(id)sender {
    isSkipCalled =YES;
    [self.viewStarContainer setHidden:YES];
    [self.viewStartBgOveryLay setHidden:YES];
    
}



- (IBAction)onRatingDoneButtonTap:(id)sender {
    
    int rating1 = starViewNoLabel.rating/20;
    ratingGiven=rating1;
    [self.curr_trip.driver updateDriverRating:rating1 completionBlock:^(id results, NSError *error) {
    
        [self updateFeedbackInTrip:rating1];
        [self.viewStarRating setValue:rating1];
        //        }
        self->isRatingDoneCalled =YES;
        [self.viewStarContainer setHidden:YES];
        [self.viewStartBgOveryLay setHidden:YES];
        
    } isShowLoader:YES];
}

#pragma  mark Promo Code
- (IBAction)onPromoCodeButtonTap:(id)sender {
    self.viewEnterPromoCode.hidden=!self.viewEnterPromoCode.hidden;
}

- (IBAction)onApplyPromoCodeButtonTap:(id)sender {
    [self.view endEditing:YES];
    NSString *trimmedPromo = [self.txtPromoCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(trimmedPromo.length==0) {
        [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r20_s9_plz_enter_valid_code"]];
    }
    else{
        promoCode=[[PromoCodeModel alloc]  initWithPromode:trimmedPromo city_id:self.curr_trip.city_id];
        [promoCode validatePromoCodeWithCompletionBlock:self.curr_trip.driver.category_id baseFare:[self.curr_trip.trip_base_fare floatValue] block:^(id results, NSError *error) {
            if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"])
            {
                float tripFareAfterApllyPromoCode=[self->promoCode calucalateAmtByPromoCode:[self.curr_trip.trip_fare floatValue]];
                //                self.curr_trip.trip_fare=[NSString stringWithFormat:@"%f",([_curr_trip.trip_fare floatValue]-tripFareAfterApllyPromoCode)];
                self.curr_trip.trip_promo_amt=[Utilities formatAmount:tripFareAfterApllyPromoCode];
                self.curr_trip.isPromoCodeUsed=YES;
                self->isPromoApplied =YES;
                self->promoAmt =[Utilities formatAmount:tripFareAfterApllyPromoCode];
                self.curr_trip.trip_promo_code=self.txtPromoCode.text;
                [self updateTripAfterApplyPromocode ];
                [self setDataonUI];
                [self getTripDetails];
            }
            else{
                [self showAlertWithMessgae:[LanguageHelper getStringWithKey:@"k_r20_s9_plz_enter_valid_code"]];
            }
        }];
    }
}




-(void) updateTripAfterApplyPromocode
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
    [dict setObject:[NSString stringWithFormat:@"%@",self.curr_trip.trip_Id] forKey:@"trip_id"];
    
    
    if (self.curr_trip.isPromoCodeUsed==YES) {
        if(promoCode)
        {
            [dict setObject:promoCode.promoId forKey:@"promo_id"];
            [dict setObject:promoCode.promoCode forKey:@"trip_promo_code"];
            [dict setObject:self.curr_trip.trip_promo_amt forKey:@"trip_promo_amt"];
        }
    }
    
    [self.curr_trip updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
        self->apiCounterPromo++;
        if([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"])
        {
            [self sendNotificationPromoCode];
            
            if( self->tripCheckTimer )
            {
                [self->tripCheckTimer invalidate];
                self->tripCheckTimer =nil;
            }
            [self getTripDetails];
        }
        else if (self->apiCounterPromo<4){
            
            [self updateTripAfterApplyPromocode];
        }
    } isShowLoader:YES isSendNotification:NO];
}





#pragma mark - Text View Delegates

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO; // or true, whetever you's like
    }
    
    return textView.text.length + (text.length - range.length) <= 75;   //restrict user to 75 characters
}






-(void)proceedFurtherAfterStripe
{
    
    if (!isCalledPayWithCard && !isCalledCashOnHand) {
        isCalledPayWithCard =YES;
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
        [dict setObject:[NSString stringWithFormat:@"%@",self.curr_trip.trip_Id] forKey:@"trip_id"];
        [dict setObject:PAYPAL_PAY forKey:@"trip_pay_mode"];
        [dict setObject:TS_PAID forKey:@"trip_pay_status"];
        if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL]){
            if(self.curr_trip.is_cancelled){
                [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
            }else{
                [dict setObject:TS_END forKey:TRIP_STATUS];
            }
        }else{
            if(self.curr_trip.is_cancelled==NO){
                if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]||[self.curr_trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
                    [dict setObject:TS_END forKey:TRIP_STATUS];
                }
            }
        }
        // NSDateFormatter * dateFormatter=[[NSDateFormatter alloc] init];
        // [dateFormatter  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dict setObject:[Utilities getStringFromDate:[NSDate date]] forKey:@"trip_pay_date"];
        
        //    if (self.curr_trip.isPromoCodeUsed==YES) {
        //        if(promoCode)
        //        {
        //            [dict setObject:promoCode.promoId forKey:@"promo_id"];
        //            [dict setObject:promoCode.promoCode forKey:@"trip_promo_code"];
        //            [dict setObject:self.curr_trip.trip_promo_amt forKey:@"trip_promo_amt"];
        //        }
        //    }
        [self.curr_trip updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
            if([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"])
            {
                self.curr_trip.trip_pay_status=TS_PAID;
                [self setDataonUI];
            }
        } isShowLoader:YES isSendNotification:YES];
    }
    
}



-(void)getPaymentStatus{
    
    [self.curr_trip refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
        if(error!=nil)
        {
            [self setDataonUI];
        }
        if([self.curr_trip.trip_Status isEqualToString:TS_END] && !self->isCalledCashOnHand && !self->isCalledPayWithCard)
        {
            if ([self.curr_trip.trip_pay_status isEqualToString:TS_PAID ]){
//                AppDelegate * appDelegate=APP_DELEGATE;
//                appDelegate.trip_status=PAID;
                [self setDataonUI];
                if ([self->tripCheckTimer isValid]) {
                    [self->tripCheckTimer invalidate];
                    self->tripCheckTimer=nil;
                }
                return;
            }
            else{
                if( self->tripCheckTimer )
                {
                    [self->tripCheckTimer invalidate];
                    self->tripCheckTimer =nil;
                }
                self->tripCheckTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self
                                                                      selector: @selector(getPaymentStatus) userInfo: nil repeats: NO];
                
            }
            
        }
        
        
    } isShowLoader:NO];
    
    
    
}

- (IBAction)onStarRatingButTap:(id)sender {
    [self.viewStarContainer setHidden:NO];
    [self.viewStartBgOveryLay setHidden:NO];
    if (starViewNoLabel) {
        [starViewNoLabel removeFromSuperview];
        starViewNoLabel = nil;
    }
    
    CGFloat userRating = ratingGiven ? ratingGiven : 5.0;
    
    starViewNoLabel = [[StarRatingView alloc]initWithFrame:CGRectMake(0, 0, kStarViewWidth, kStarViewHeight) andRating:userRating*20 withLabel:NO animated:YES];
    [starViewNoLabel setUserInteractionEnabled:YES];
    [self.ratingBar addSubview:starViewNoLabel];
}


-(void)handleDirectPayment {
    
    //    [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    //
    // Setup add card view controller
    //    STPAddCardViewController *addCardViewController = [[STPAddCardViewController alloc] init];
    //    addCardViewController.delegate = self;
    //
    //    // Present add card view controller
    //    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addCardViewController];
    //    [self presentViewController:navigationController animated:YES completion:nil];
    //
    
//    NSDictionary *dictUser=defaults_object(P_USER_DICT);
//    NSDictionary *options = @{
//        @"amount": [NSString stringWithFormat:@"%d",(int)([self.curr_trip.trip_fare floatValue]*100)],  //This is in currency subunits. 1000 = 1000 paise= INR 10.
//        // all optional other than amount.
//        @"currency": @"INR",  //We support more that 92 international currencies.
//        @"image": @"hireMe_logo",
//        @"name": @"Ugna Rider",
//        @"description": @"Trip",
//        //                                @"order_id": [NSString stringWithFormat:@"trip_%d",self.curr_trip.trip_Id],
//        @"prefill" : @{
//                @"email": [dictUser objectForKey:P_EMAIL],
//                @"contact": [dictUser objectForKey:P_MOBILE]
//        },
//        @"theme": @{
//                @"color": @"#F37254"
//        }
//    };
//    [razorpay open:options];
    PaymentMethodListViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"PaymentMethodListViewController"];
    vc.isFromPaymentJob=YES;
    vc.delegate=self;
    [self.navigationController pushViewController:vc animated:YES];
    
//    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
//    float walletBalance=[[dict1 objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
//    float  totalFareOrignal=[self.curr_trip.trip_fare floatValue];
//    if(walletBalance<totalFareOrignal){
//        PaymentMethodListViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"PaymentMethodListViewController"];
//        vc.isFromPaymentJob=YES;
//        vc.delegate=self;
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        [self payWithHireMeWallet];
//    }
}


- (void)onPaymentSuccess:(nonnull NSString*)payment_id {      //[[[UIAlertView alloc] initWithTitle:@"Payment Successful" message:payment_id delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self payWithCardDetectComssion];
    
}

- (void)onPaymentError:(int)code description:(nonnull NSString *)str {
    [self showAlert:@"Error" message:str];
    
}


-(void) onPaymentMethodSelected:(NSString *)paymentMethodType viewControlllor:(PaymentMethodListViewController *)viewControlllor
{
    
}
-(void) onPaymentIntentSelected:(NSString *)paymentMethod  dict:(NSDictionary *) dict viewControlllor:(PaymentMethodListViewController *)viewControlllor{
    
    NSDictionary * dictUser=defaults_object(P_USER_DICT);
    if(self.curr_trip.city_id==[UserProfile shared].cityID){
        float walletBalance=[[dictUser objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
        float  totalFareOrignal=[self.curr_trip.trip_fare floatValue];
        if(walletBalance<totalFareOrignal){
            NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
            float walletBalance=[[dict1 objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
            float  totalFareOrignal=[self.curr_trip.trip_fare floatValue];
            float  chrageByCard=totalFareOrignal-walletBalance;
            int price =(int)(ceil(chrageByCard*100));
            chrageByCardChargedByCard=chrageByCard;
            [self createStripUserCreatePaymentIntentDone:price paymentMethod:paymentMethod];
        }else{
            [self payWithHireMeWallet];
        }
    }else{
        float  totalFareOrignal=[self.curr_trip.trip_fare floatValue];
        float  chrageByCard=totalFareOrignal;
        int price =(int)(ceil(chrageByCard*100));
        chrageByCardChargedByCard=chrageByCard;
        [self createStripUserCreatePaymentIntentDone:price paymentMethod:paymentMethod];
    }
}

-(void) createStripUserCreatePaymentIntentDone:(int )amount paymentMethod:(NSString *)paymentMethod
{
//    amount=amount+5000;
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    CityModel *cModel=[CityModel getCityByCityId:self.curr_trip.city_id];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty(self.constantModel.stripe_s_key)/*STRIPE_SECRET_KEY*/ password:@"" persistence:NSURLCredentialPersistenceNone];
    NSString * stripeCustomerId = isEmpty([ConstantModel getConstantsObject].is_stripe_live?[dict1 objectForKey:P_STRIPE_CUS_ID]:[dict1 objectForKey:P_STRIPE_DEV_CUS_ID]);
    if([ConstantModel getConstantsObject].is_stripe_live==NO){
        if(stripeCustomerId){
#if TARGET_OS_SIMULATOR
            stripeCustomerId = P_STRIPE_CUS_DEV_CUS_ID;
#else

#endif
        } 
    }
    NSDictionary *parameters = @{@"amount": [NSString stringWithFormat:@"%d",amount],@"currency":isEmpty(cModel.pg_cur)/*@"eur"*/,@"payment_method":paymentMethod,@"statement_descriptor_suffix":[NSString stringWithFormat:@"Trip ID = %@",self.curr_trip.trip_Id],@"off_session":@"true",@"confirm":@"true",@"customer": stripeCustomerId};
    NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"POST" URLString:@"https://api.stripe.com/v1/payment_intents" parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary * error=[responseObject objectForKey:@"error"];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        if(error==nil)
        {
            [self payWithCardDetectComssion:responseObject];
        }else{
            [UtilityClass swa:@"Payment failed!" m: isEmpty([error objectForKey:@"message"]) cbt:@"Ok" obt:nil vc:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        [UtilityClass swa:@"Error" m:error.localizedDescription ?: @"" cbt:@"Ok" obt:nil vc:self];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    }];
    [manager.operationQueue addOperation:operation];
}

-(void) payWithCardDetectComssion:(NSDictionary * ) responseObject {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    float driverCommission=[self getDriverCommissionForTrip:self.curr_trip];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id":[dict1 objectForKey:P_USER_ID],
        @"total_amt":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"rider_amt":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"pay_amount":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"api_key":[ dict1 objectForKey:P_API_KEY],
        @"trip_id":[NSString stringWithFormat:@"%@",_curr_trip.trip_Id],
        P_DRIVER_ID:[NSString stringWithFormat:@"%@",_curr_trip.trip_Driver_Id],
        @"city_id":[NSString stringWithFormat:@"%d",_curr_trip.city_id],
        //                                                                                @"pay_status":PAID,
        @"trip_driver_commision":[Utilities formatAmount:driverCommission],
        @"pay_mode":@"Card",
        @"trans_description":@"Trip Payment",
        @"promo_amt":[Utilities formatAmount:[self.curr_trip.trip_promo_amt floatValue]],
        @"commission_amt":[Utilities formatAmount:([[Utilities formatAmount:[_curr_trip.trip_fare floatValue]] floatValue]-driverCommission)]
    }];
    NSString * urlTrans =GET_WALLET_ADD_TRIP_TRAN;
    if(self.curr_trip.city_id==[UserProfile shared].cityID){
        float walletBalance=[[dict1 objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
        if(walletBalance>0&&walletBalance<[_curr_trip.trip_fare floatValue]){
            float  totalFareOrignal=[self.curr_trip.trip_fare floatValue];
            float  chrageByCard=totalFareOrignal-walletBalance;
            [dict setObject:[Utilities formatAmount:walletBalance] forKey:@"user_wallet_amt"];
            [dict setObject:[Utilities formatAmount:chrageByCard] forKey:@"user_card_amt"];
            urlTrans=GET_WALLET_ADD_TRIP_TRAN_REG;
        }
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:urlTrans  d:dict   cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            // success
            if(self.curr_trip.city_id==[UserProfile shared].cityID){
                float walletBalance=[[dict1 objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
                if(walletBalance<0){
                    float  totalFareOrignal=[self.curr_trip.trip_fare floatValue];
                    float  chrageByCard=self->chrageByCardChargedByCard-totalFareOrignal;
                    if(chrageByCard>0){
                        [self adjuestOutStandingBalance:chrageByCard];
                    }
                }
            }
            [self payWithCardOnHand: YES responseObject:responseObject];
        }else {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            [Utilities handleError:error viewController:self defaultMessage:@""                                                                                               ];
        }
    }];
}



-(void)adjuestOutStandingBalance:(float)adjustOutStandingAmount{
    NSString * desc=@"" ;
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *addMoneyDict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id":[dict1 objectForKey:P_USER_ID],
        @"total_amt":[Utilities formatAmount:adjustOutStandingAmount],
        @"city_id":@([[UserProfile shared] cityID]),
        @"trans_description":desc,
    }];
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    [GIC mkwerwu:GET_WALLET_ADD_TRAN_WITHOUT_TRIP
                                    d:addMoneyDict
              cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        if(error!=nil)
        {
            [Utilities handleError:error viewController:self defaultMessage:@""];
            return;
        }
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            // success
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *WalletAmtDict = [[[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT] mutableCopy];
                float toatalAmt=[[WalletAmtDict  objectForKey:P_USER_WAlLET_AMOUNT] floatValue];
                [WalletAmtDict setObject:[Utilities formatAmount:toatalAmt+adjustOutStandingAmount] forKey:P_USER_WAlLET_AMOUNT ];
                [[NSUserDefaults standardUserDefaults] setObject:WalletAmtDict forKey:P_USER_DICT];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else {
            }
        }
    }];
}


-(void)payWithCardOnHand:(BOOL)isSendNotification responseObject:(NSDictionary * ) responseObject{
    
    if (!isCalledCashOnHand && !isCalledPayWithCard) {
        isCalledCashOnHand =YES;
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
        [dict setObject:[NSString stringWithFormat:@"%@",self.curr_trip.trip_Id] forKey:@"trip_id"];
        [dict setObject:CARD forKey:@"trip_pay_mode"];
        [dict setObject:TS_PAID forKey:@"trip_pay_status"];
        if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL]){
            if(self.curr_trip.is_cancelled){
                [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
            }else{
                [dict setObject:TS_END forKey:TRIP_STATUS];
            }
        }else{
            if(self.curr_trip.is_cancelled==NO){
                if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]||[self.curr_trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
                    [dict setObject:TS_END forKey:TRIP_STATUS];
                }
            }
        }
        
        self.curr_trip.trip_pay_mode=CARD;
        [dict setObject:[Utilities getStringFromDate:[NSDate date]] forKey:@"trip_pay_date"];
        [self.curr_trip updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
            if([[results objectForKey:P_STATUS]isEqualToString:@"OK"]) {
                if(responseObject!=nil){
                    NSArray *array=[[responseObject objectForKey:@"charges"]  objectForKey:@"data"];
                    if([array isKindOfClass:[NSArray class]]&&array.count>0){
                        NSDictionary *dict=[[array  firstObject] objectForKey:@"outcome"];
                        [UtilityClass swa:@"" m: isEmpty([dict objectForKey:@"seller_message"]) cbt:@"Ok" obt:nil vc:self];
                    }
                }
                self.curr_trip.trip_pay_status=TS_PAID;
                [self setDataonUI];
            }
        } isShowLoader:YES isSendNotification:isSendNotification];
    }
}




-(void) payWithCardDetectComssion{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    CityModel *  cityModel= [CityModel getCityByCityId:self.curr_trip.city_id];
    float driverCommission=[self getDriverCommissionForTrip:self.curr_trip];
    //    if(cityModel)
    //    {
    //        driverCommission =[_curr_trip.trip_fare doubleValue]*(100-cityModel.city_comm)/100;
    //    }else
    //    {
    //        driverCommission =[_curr_trip.trip_fare doubleValue]*(100-_constantModel.connstant_appicial_commission)/100;
    //    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"user_id":[dict1 objectForKey:P_USER_ID],
        @"total_amt":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"rider_amt":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"pay_amount":[Utilities formatAmount:[_curr_trip.trip_fare floatValue]],
        @"api_key":[ dict1 objectForKey:P_API_KEY],
        @"trip_id":[NSString stringWithFormat:@"%@",_curr_trip.trip_Id],
        P_DRIVER_ID:[NSString stringWithFormat:@"%@",_curr_trip.trip_Driver_Id],
        @"trip_driver_commision":[Utilities formatAmount:driverCommission],
        @"city_id":[NSString stringWithFormat:@"%d",_curr_trip.city_id],
        @"pay_mode":@"Card",
        @"trans_description":@"Trip Payment",
        @"promo_amt":[Utilities formatAmount:[self.curr_trip.trip_promo_amt floatValue]],
        @"commission_amt":[Utilities formatAmount:([[Utilities formatAmount:[_curr_trip.trip_fare floatValue]] floatValue]-driverCommission)]
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
    [GIC mkwu:GET_WALLET_ADD_TRIP_TRAN
                  d:dict
      isa:YES
           cb:^(id results, NSError *error) {
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
            // success
            
            [self payWithCardOnHand: YES];
        }else {
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
        }
    }];
}

-(void)payWithCardOnHand:(BOOL)isSendNotification
{
    if (!isCalledCashOnHand && !isCalledPayWithCard) {
        isCalledCashOnHand =YES;
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
        [dict setObject:[NSString stringWithFormat:@"%@",self.curr_trip.trip_Id] forKey:@"trip_id"];
        [dict setObject:CARD forKey:@"trip_pay_mode"];
        [dict setObject:TS_PAID forKey:@"trip_pay_status"];
        if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL]){
            if(self.curr_trip.is_cancelled){
                [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
            }else{
                [dict setObject:TS_END forKey:TRIP_STATUS];
            }
        }else{
            if(self.curr_trip.is_cancelled==NO){
                if([self.curr_trip.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]||[self.curr_trip.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
                    [dict setObject:TS_END forKey:TRIP_STATUS];
                }
            }
        }
        self.curr_trip.trip_pay_mode=CARD;
        [dict setObject:[Utilities getStringFromDate:[NSDate date]] forKey:@"trip_pay_date"];
        [self.curr_trip updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
            if([[results objectForKey:P_STATUS]isEqualToString:@"OK"])
            {
                self.curr_trip.trip_pay_status=TS_PAID;
                [self setDataonUI];
            }
        } isShowLoader:YES isSendNotification:isSendNotification];
    }
}




- (IBAction)onFareDetailsButTap:(id)sender {
    FareDetailsViewController *vc = (FareDetailsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.FARE_DETAIL_VC];
    vc.trip=self.curr_trip;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - New Design (2-screen receipt + rating)

-(void)setupNewDesign {
    for (UIView *v in self.view.subviews) { v.hidden = YES; }
    self.view.backgroundColor = UIColor.whiteColor;

    UIColor *yellow   = [UIColor colorNamed:@"app_theame"]
                        ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    UIColor *dark     = [UIColor colorNamed:@"color_app_label"] ?: [UIColor colorWithWhite:0.12 alpha:1];
    UIColor *gray     = [UIColor colorWithWhite:0.5 alpha:1];
    UIColor *ticketBg = [UIColor colorWithWhite:0.96 alpha:1];
    UIColor *cardBg   = ticketBg; // kept for rating sheet
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
    closeBtn.frame = CGRectMake(w - pad - 32, (headerH - 32)/2.0, 32, 32);
    closeBtn.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    closeBtn.layer.cornerRadius = 16;
    closeBtn.tintColor = dark;
    if (@available(iOS 13, *)) {
        [closeBtn setImage:[UIImage systemImageNamed:@"xmark"] forState:UIControlStateNormal];
    } else {
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:dark forState:UIControlStateNormal];
    }
    [closeBtn addTarget:self action:@selector(ndCloseTapped) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeBtn];

    UIView *hSep = [[UIView alloc] initWithFrame:CGRectMake(0, headerH - 1, w, 1)];
    hSep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [headerView addSubview:hSep];

    CGFloat y = headerH + 20;

    CGFloat avatarSz = 60;
    _ndDriverImg = [[UIImageView alloc] initWithFrame:CGRectMake(pad, y, avatarSz, avatarSz)];
    _ndDriverImg.layer.cornerRadius = avatarSz / 2;
    _ndDriverImg.clipsToBounds = YES;
    _ndDriverImg.contentMode = UIViewContentModeScaleAspectFill;
    _ndDriverImg.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [content addSubview:_ndDriverImg];

    CGFloat nameX = pad + avatarSz + 12;
    CGFloat nameW = w - nameX - pad;

    _ndDriverNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(nameX, y + 10, nameW, 20)];
    _ndDriverNameLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    _ndDriverNameLbl.textColor = dark;
    [content addSubview:_ndDriverNameLbl];

    _ndDriverRatingLbl = [[UILabel alloc] initWithFrame:CGRectMake(nameX, y + 10 + 22 + 4, nameW, 20)];
    _ndDriverRatingLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    _ndDriverRatingLbl.textColor = gray;
    [content addSubview:_ndDriverRatingLbl];

    y += avatarSz + 16;

    CGFloat tpad  = 16;
    CGFloat iconW = 22;
    CGFloat lblX  = tpad + iconW + 10;
    CGFloat lblW  = tickW - lblX - tpad;

    // Calculated layout inside ticket:
    CGFloat ty = tpad;

    // Pickup icon at (tpad, ty, iconW, iconW)
    UIImageView *pickIcon = [[UIImageView alloc] initWithFrame:CGRectMake(tpad, ty, iconW, iconW)];
    // (added to ticket below)
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
    ty += 30; // pickAddrLbl height + gap before destIcon

    // Dashed connector
    CGFloat dashTop = tpad + iconW + 3;
    CGFloat dashBot = ty + 2 - 3; // destIcon top - 3
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
    ty += 28 + tpad; // bottom of dropAddr + padding = notch boundary

    // Notch divider line
    CGFloat notchDivY = ty;
    UIView *notchDivider = [[UIView alloc] initWithFrame:CGRectMake(tpad, notchDivY, tickW - tpad*2, 1)];
    notchDivider.backgroundColor = [UIColor colorWithWhite:0.82 alpha:1];
    ty += 1;

    // Details rows
    ty += 14;
    _ndDateTimeLbl = [self ndMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *dateKey = [self ndMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"Fecha / Hora:"];
    ty += 28;

    _ndTripIdLbl = [self ndMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *tripIdKey = [self ndMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"ID del Traslado:"];
    ty += 28;

    _ndDriverIdLbl = [self ndMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *driverIdKey = [self ndMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"ID del Conductor:"];
    ty += 28;

    // Fare separator
    ty += 6;
    UIView *fareSep = [[UIView alloc] initWithFrame:CGRectMake(tpad, ty, tickW - tpad*2, 1)];
    fareSep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    ty += 1 + 14;

    _ndTaxLbl = [self ndMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *taxKey = [self ndMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"Impuestos:"];
    ty += 28;

    _ndRideCostLbl = [self ndMakeValueLabelAt:CGRectMake(0, ty, tickW, 20) dark:dark];
    UILabel *fareKey = [self ndMakeKeyLabelAt:CGRectMake(tpad, ty, tickW*0.5, 20) gray:gray text:@"Traslado:"];
    ty += 28;

    UILabel *totalKey = [[UILabel alloc] initWithFrame:CGRectMake(tpad, ty, tickW*0.5, 22)];
    totalKey.text = @"Total:";
    totalKey.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    totalKey.textColor = dark;

    _ndTotalLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, ty, tickW - tpad, 22)];
    _ndTotalLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    _ndTotalLbl.textColor = dark;
    _ndTotalLbl.textAlignment = NSTextAlignmentRight;
    ty += 22 + 14;

    // Pago movil del conductor.
    //
    // Android esconde la tarjeta cuando el conductor no lo tiene registrado
    // (FareActivity.updateTripData). Aqui se enseña SIEMPRE, con "No registrado" si no hay
    // datos: este recibo se monta con marcos fijos en viewDidLoad y los valores llegan
    // despues, en setDataonUI, asi que esconderla obligaria a recalcular el alto del ticket
    // y a mover el boton. Decirle al pasajero que el conductor no tiene pago movil tampoco
    // es una mala respuesta: es justo lo que necesita saber antes de intentar pagarle.
    UIView *pmSep = [[UIView alloc] initWithFrame:CGRectMake(tpad, ty, tickW - tpad*2, 1)];
    pmSep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    ty += 1 + 12;

    UILabel *pmKey = [self ndMakeKeyLabelAt:CGRectMake(tpad, ty, tickW - tpad*2, 18)
                                       gray:gray
                                       text:@"PAGO MÓVIL DEL CONDUCTOR:"];
    ty += 22;

    _ndPagoMovilLbl = [[UILabel alloc] initWithFrame:CGRectMake(tpad, ty, tickW - tpad*2, 54)];
    _ndPagoMovilLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    _ndPagoMovilLbl.textColor = dark;
    _ndPagoMovilLbl.numberOfLines = 3;
    ty += 54 + tpad;

    // Build ticket view with computed height
    UIView *ticket = [[UIView alloc] initWithFrame:CGRectMake(pad, y, tickW, ty)];
    ticket.backgroundColor = ticketBg;
    _ndTicketView = ticket;
    _ndNotchY = notchDivY;
    [content addSubview:ticket];

    // Add all subviews to ticket
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
    [ticket addSubview:pmSep];
    [ticket addSubview:pmKey];
    [ticket addSubview:_ndPagoMovilLbl];

    // Apply ticket notch mask
    [self ndApplyTicketMask];

    y += ty + 32;

    UIButton *aceptarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aceptarBtn.frame = CGRectMake(pad, y, tickW, 56);
    aceptarBtn.backgroundColor = yellow;
    aceptarBtn.layer.cornerRadius = 16;
    aceptarBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    [aceptarBtn setTitle:@"Aceptar" forState:UIControlStateNormal];
    [aceptarBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [aceptarBtn addTarget:self action:@selector(ndAceptarTapped) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:aceptarBtn];
    y += 56 + 48;

    content.frame = CGRectMake(0, 0, w, y);
    scroll.contentSize = CGSizeMake(w, y);

    CGFloat h = self.view.bounds.size.height;
    CGFloat sheetH = h * 0.70;

    _ndRatingView = [[UIView alloc] initWithFrame:self.view.bounds];
    _ndRatingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    _ndRatingView.hidden = YES;
    [self.view addSubview:_ndRatingView];

    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, h, w, sheetH)];
    sheet.backgroundColor = UIColor.whiteColor;
    sheet.layer.cornerRadius = 24;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.layer.masksToBounds = YES;
    sheet.tag = 9900;
    [_ndRatingView addSubview:sheet];

    CGFloat headerH2 = 56;
    UILabel *sheetTitle = [[UILabel alloc] initWithFrame:CGRectMake(pad, 0, w - pad*2 - 48, headerH2)];
    sheetTitle.text = [LanguageHelper getStringWithKey:@"k_s10_rate_driver" defaultValue:@"Califica al conductor"];
    sheetTitle.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    sheetTitle.textColor = dark;
    sheetTitle.textAlignment = NSTextAlignmentCenter;
    [sheet addSubview:sheetTitle];

    UIButton *ratingCloseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    ratingCloseBtn.frame = CGRectMake(w - 48, 0, 48, headerH2);
    [ratingCloseBtn setTitle:@"✕" forState:UIControlStateNormal];
    ratingCloseBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [ratingCloseBtn setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
    [ratingCloseBtn addTarget:self action:@selector(ndSkipRatingTapped) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:ratingCloseBtn];

    CGFloat sy = headerH2 + 12;

    CGFloat avatarSz2 = 80;
    UIImageView *rDriverImg = [[UIImageView alloc] initWithFrame:CGRectMake((w - avatarSz2)/2, sy, avatarSz2, avatarSz2)];
    rDriverImg.layer.cornerRadius = avatarSz2/2;
    rDriverImg.clipsToBounds = YES;
    rDriverImg.contentMode = UIViewContentModeScaleAspectFill;
    rDriverImg.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    rDriverImg.tag = 9901;
    [sheet addSubview:rDriverImg];
    sy += avatarSz2 + 12;

    UILabel *rName = [[UILabel alloc] initWithFrame:CGRectMake(pad, sy, w - pad*2, 26)];
    rName.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    rName.textAlignment = NSTextAlignmentCenter;
    rName.textColor = dark;
    rName.tag = 9902;
    [sheet addSubview:rName];
    sy += 30;

    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(pad, sy, w - pad*2, 1)];
    sep.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [sheet addSubview:sep];
    sy += 20;

    CGFloat cardW = w - pad * 2;
    _ndStarRating = [[HCSStarRatingView alloc] initWithFrame:CGRectMake((w - 260)/2, sy, 260, 52)];
    _ndStarRating.value = 0;
    _ndStarRating.allowsHalfStars = NO;
    _ndStarRating.accurateHalfStars = NO;
    _ndStarRating.tintColor = yellow;
    NSBundle *bundle = [NSBundle mainBundle];
    UIImage *starFilled = [UIImage imageNamed:@"ic_star" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *starEmpty = [UIImage imageNamed:@"ic_star_empty" inBundle:bundle compatibleWithTraitCollection:nil];
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

    _ndFeedbackView = [[UITextView alloc] initWithFrame:CGRectMake(pad, sy, cardW, 90)];
    _ndFeedbackView.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    _ndFeedbackView.textColor = dark;
    _ndFeedbackView.backgroundColor = cardBg;
    _ndFeedbackView.layer.cornerRadius = 12;
    _ndFeedbackView.textContainerInset = UIEdgeInsetsMake(14, 14, 14, 14);
    _ndFeedbackView.delegate = (id<UITextViewDelegate>)self;
    [sheet addSubview:_ndFeedbackView];

    UILabel *phLbl = [[UILabel alloc] initWithFrame:CGRectMake(pad + 18, sy + 16, cardW - 36, 22)];
    phLbl.text = @"Deja un comentario...";
    phLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    phLbl.textColor = [UIColor colorWithWhite:0.68 alpha:1];
    phLbl.tag = 9903;
    [sheet addSubview:phLbl];
    sy += 106;

    CGFloat btnGap  = 12;
    CGFloat btnW    = (cardW - btnGap) / 2;
    UIColor *lightYellow = [UIColor colorWithRed:0.99 green:0.95 blue:0.76 alpha:1];

    UIButton *propinaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    propinaBtn.frame = CGRectMake(pad, sy, btnW, 56);
    propinaBtn.backgroundColor = lightYellow;
    propinaBtn.layer.cornerRadius = 16;
    propinaBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    [propinaBtn setTitle:@"Dar propina" forState:UIControlStateNormal];
    [propinaBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    // Decia "Dar propina" y llamaba a ndSkipRatingTapped, que cierra la valoracion y se va
    // al inicio: el boton hacia justo lo contrario de lo que anunciaba, y la propina no
    // existia en iOS. Android la tiene en FareActivity.showTipInputDialog / submitTip.
    [propinaBtn addTarget:self action:@selector(ndPropinaTapped) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:propinaBtn];

    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(pad + btnW + btnGap, sy, btnW, 56);
    submitBtn.backgroundColor = yellow;
    submitBtn.layer.cornerRadius = 16;
    submitBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    [submitBtn setTitle:@"Aceptar" forState:UIControlStateNormal];
    [submitBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(ndSubmitRatingTapped) forControlEvents:UIControlEventTouchUpInside];
    [sheet addSubview:submitBtn];
}

-(void)ndApplyTicketMask {
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
    [self ndApplyTicketMask];
}

// Helper: gray key label
-(UILabel *)ndMakeKeyLabelAt:(CGRect)frame gray:(UIColor *)gray text:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    lbl.text = text;
    lbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    lbl.textColor = gray;
    return lbl;
}

// Helper: dark right-aligned value label (frame width 0 = use ticket width via textAlignment right)
-(UILabel *)ndMakeValueLabelAt:(CGRect)frame dark:(UIColor *)dark {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y, frame.size.width - 16, frame.size.height)];
    lbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    lbl.textColor = dark;
    lbl.textAlignment = NSTextAlignmentRight;
    return lbl;
}

// Populate receipt labels from trip data
-(void)updateReceiptUI {
    if (!_ndReceiptScroll) return;
    CityModel *city = [CityModel getCityByCityId:self.curr_trip.city_id];
    NSString *cur = city ? city.city_cur : @"$";
    UIColor *yellow = [UIColor colorNamed:@"app_theame"]
                      ?: [UIColor colorWithRed:235/255.0 green:181/255.0 blue:24/255.0 alpha:1];
    UIColor *gray = [UIColor colorWithWhite:0.5 alpha:1];

    // Driver name
    NSString *name = [NSString stringWithFormat:@"%@ %@",
                      self.curr_trip.driver.d_fname ?: @"",
                      self.curr_trip.driver.d_lname ?: @""];
    _ndDriverNameLbl.text = [[name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet]
                              ?: @"Conductor" length] > 0
        ? [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet]
        : @"Conductor";

    // Star rating — yellow star icon + "4.6 (125)"
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
            [NSString stringWithFormat:@" %.1f (%d)",
             self.curr_trip.driver.rating, (int)self.curr_trip.driver.ratingCount]
            attributes:@{ NSFontAttributeName: _ndDriverRatingLbl.font,
                          NSForegroundColorAttributeName: gray }]];
    } else {
        ratingStr = [[NSMutableAttributedString alloc] initWithString:
            [NSString stringWithFormat:@"★ %.1f (%d)",
             self.curr_trip.driver.rating, (int)self.curr_trip.driver.ratingCount]];
    }
    _ndDriverRatingLbl.attributedText = ratingStr;

    // Driver photo
    NSString *photoPath = self.curr_trip.driver.d_profile_image_path;
    if (photoPath.length > 0) {
        NSURL *photoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, photoPath]];
        [_ndDriverImg sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    } else {
        _ndDriverImg.image = [UIImage imageNamed:@"Profile Icon Crop Image"];
    }

    // Sync to rating screen driver card
    UIImageView *rImg = (UIImageView *)[_ndRatingView viewWithTag:9901];
    UILabel *rName    = (UILabel *)[_ndRatingView viewWithTag:9902];
    rImg.image        = _ndDriverImg.image;
    rName.text        = _ndDriverNameLbl.text;
    if (photoPath.length > 0) {
        NSURL *u = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, photoPath]];
        [rImg sd_setImageWithURL:u placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }

    // Addresses — split into name (before first comma) + secondary (rest)
    NSString *fullPickup = self.curr_trip.pickupLocationApp ?: @"";
    NSArray *pickParts = [fullPickup componentsSeparatedByString:@","];
    _ndPickupNameLbl.text = pickParts.count > 0
        ? [pickParts[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] : fullPickup;
    _ndPickupAddrLbl.text = pickParts.count > 1
        ? [[[pickParts subarrayWithRange:NSMakeRange(1, pickParts.count - 1)]
            componentsJoinedByString:@","]
           stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] : @"";

    NSString *fullDrop = self.curr_trip.dropLocationApp ?: @"";
    NSArray *dropParts = [fullDrop componentsSeparatedByString:@","];
    _ndDropNameLbl.text = dropParts.count > 0
        ? [dropParts[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] : fullDrop;
    _ndDropAddrLbl.text = dropParts.count > 1
        ? [[[dropParts subarrayWithRange:NSMakeRange(1, dropParts.count - 1)]
            componentsJoinedByString:@","]
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
    _ndDriverIdLbl.text = self.curr_trip.driver.driverId ?: @"";

    // Fare breakdown
    float tax   = [self.curr_trip.tax_amount_r floatValue];
    float total = [self.curr_trip.trip_fare floatValue];
    float ride  = total - tax;
    _ndTaxLbl.text      = [Utilities formatAmountAndCurrency:tax   currency:cur];
    _ndRideCostLbl.text = [Utilities formatAmountAndCurrency:ride  currency:cur];
    // Show total in local currency AND USD equivalent
    _ndTotalLbl.text    = [self formatAmountDual:total currency:cur];

    _ndPagoMovilLbl.text = [self ndTextoPagoMovil];
}

// Screen 1 → close
-(void)ndCloseTapped {
    [self navigateHome];
}

// Screen 1 → Aceptar → show rating screen
-(void)ndAceptarTapped {
    _ndRatingView.hidden = NO;
    // Animate sheet up from bottom
    UIView *sheet = [_ndRatingView viewWithTag:9900];
    CGFloat h = self.view.bounds.size.height;
    sheet.frame = CGRectMake(0, h, sheet.frame.size.width, sheet.frame.size.height);
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.5 options:0 animations:^{
        sheet.frame = CGRectMake(0, h - sheet.frame.size.height, sheet.frame.size.width, sheet.frame.size.height);
    } completion:nil];
}

// Screen 2 → Calificar
-(void)ndSubmitRatingTapped {
    float rating = _ndStarRating.value;
    ratingGiven = (int)rating;
    self.txtviewFeedback.text = _ndFeedbackView.text;
    [self.curr_trip.driver updateDriverRating:ratingGiven completionBlock:^(id results, NSError *error) {
        [self updateFeedbackInTrip:self->ratingGiven];
        [self navigateHome];
    } isShowLoader:NO];
}

// Screen 2 → Omitir
/**
 Los datos de pago movil del conductor, listos para leer.

 El backend los guarda como el JSON {bank, phone, cc, idType, idNumber} en d_bank_info. El
 mismo formato que lee RecargaC2PActivity de Android para prerrellenar la transferencia, y
 el mismo que escribe SettingViewController desde el lote 1 de este trabajo: si las dos
 apps no coincidieran aqui, un conductor de iOS seria invisible para un pasajero de Android
 y al reves.
 */
-(NSString *)ndTextoPagoMovil {
    NSString *noRegistrado = [LanguageHelper getStringWithKey:@"k_s10_pm_no_registrado"
                                                 defaultValue:@"No registrado"];
    NSString *guardado = self.curr_trip.driver.d_bank_info;
    if (![guardado isKindOfClass:[NSString class]]) {
        return noRegistrado;
    }
    guardado = [guardado stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![guardado hasPrefix:@"{"]) {
        return noRegistrado;
    }

    NSDictionary *json = [NSJSONSerialization
        JSONObjectWithData:[guardado dataUsingEncoding:NSUTF8StringEncoding]
                   options:0
                     error:nil];
    if (![json isKindOfClass:[NSDictionary class]]) {
        return noRegistrado;
    }

    NSString *banco   = isEmpty([json objectForKey:@"bank"]);
    NSString *tipoDoc = isEmpty([json objectForKey:@"idType"]);
    NSString *numDoc  = isEmpty([json objectForKey:@"idNumber"]);
    NSString *telf    = isEmpty([json objectForKey:@"phone"]);

    NSMutableArray<NSString *> *lineas = [NSMutableArray array];
    if (banco.length > 0) {
        [lineas addObject:[NSString stringWithFormat:@"Banco: %@", banco]];
    }
    if (tipoDoc.length > 0 && numDoc.length > 0) {
        [lineas addObject:[NSString stringWithFormat:@"Cédula: %@-%@", tipoDoc, numDoc]];
    } else if (numDoc.length > 0) {
        [lineas addObject:[NSString stringWithFormat:@"Cédula: %@", numDoc]];
    }
    if (telf.length > 0) {
        [lineas addObject:[NSString stringWithFormat:@"Teléfono: %@", telf]];
    }

    if (lineas.count == 0) {
        return noRegistrado;
    }
    return [lineas componentsJoinedByString:@"\n"];
}


#pragma mark - Propina

/**
 Pide el importe de la propina y lo manda.

 Portado de FareActivity.showTipInputDialog / submitTip de Android. El campo de la base de
 datos es `trip_tip` -- lo dice el comentario de Android, que ya se peleo con esto -- y va
 por el mismo tripapi/updatetrip que la valoracion.

 Despues se avisa al conductor. Ese aviso sale por el rele de conrraservices, no por
 notif.conrra.com: ver la nota de url_notification en Keys.h.
 */
-(void)ndPropinaTapped {
    if (self.curr_trip == nil || self.curr_trip.trip_Id.length == 0) {
        [self showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_s10_sin_viaje"
                                                         defaultValue:@"ID de viaje no encontrado"]];
        return;
    }

    UIAlertController *alerta = [UIAlertController
        alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_s10_dar_propina" defaultValue:@"Dar propina"]
                         message:[LanguageHelper getStringWithKey:@"k_s10_propina_importe"
                                                     defaultValue:@"¿Cuánto quieres dejarle a tu conductor?"]
                  preferredStyle:UIAlertControllerStyleAlert];

    [alerta addTextFieldWithConfigurationHandler:^(UITextField *campo) {
        campo.keyboardType = UIKeyboardTypeDecimalPad;
        campo.placeholder = @"0.00";
    }];

    __weak typeof(self) debil = self;
    [alerta addAction:[UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_22_s4_no" defaultValue:@"Cancelar"]
                  style:UIAlertActionStyleCancel
                handler:nil]];

    [alerta addAction:[UIAlertAction
        actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"Enviar"]
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *accion) {
        NSString *importe = [[[alerta.textFields firstObject].text
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                             stringByReplacingOccurrencesOfString:@"," withString:@"."];
        if (importe.length == 0 || [importe floatValue] <= 0) {
            [debil showWarningWithMessgae:[LanguageHelper getStringWithKey:@"k_s10_propina_vacia"
                                                             defaultValue:@"Por favor, ingresa un monto"]];
            return;
        }
        [debil ndEnviarPropina:importe];
    }]];

    [self presentViewController:alerta animated:YES completion:nil];
}

-(void)ndEnviarPropina:(NSString *)importe {
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];

    NSDictionary *dict = @{
        TRIP_ID     : [NSString stringWithFormat:@"%@", self.curr_trip.trip_Id],
        @"trip_tip" : importe,
    };

    __weak typeof(self) debil = self;
    [GIC mkwu:TRIP_UPDATE d:dict isa:NO cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [debil ndAvisarPropinaAlConductor:importe];
            [debil showAlert:@"" message:[LanguageHelper getStringWithKey:@"k_s10_propina_enviada"
                                                            defaultValue:@"¡Propina enviada!"]];
        } else if (results != nil) {
            [debil showWarningWithMessgae:[results objectForKey:P_MESSAGE]];
        } else {
            [Utilities handleError:error viewController:debil defaultMessage:@""];
        }
    }];
}

-(void)ndAvisarPropinaAlConductor:(NSString *)importe {
    id conductor = self.curr_trip.driver;
    if (conductor == nil) {
        return;
    }
    NSMutableDictionary *dict = [conductor deviceTypeAndToken];
    if (isTokenEmpty(dict)) {
        return;
    }
    NSString *mensaje = [NSString stringWithFormat:
                         [LanguageHelper getStringWithKey:@"k_s10_propina_aviso_conductor"
                                             defaultValue:@"¡El pasajero te ha dejado una propina de %@!"],
                         [Utilities formatAmountAndCurrency:[importe floatValue]
                                                   currency:[self ndMonedaDelViaje]]];
    [dict setObject:mensaje forKey:@"message"];
    [dict setObject:[NSString stringWithFormat:@"%@", self.curr_trip.trip_Id] forKey:TRIP_ID];
    [dict setObject:@"tip_received" forKey:TRIP_STATUS];
    [dict setObject:@"driver" forKey:@"to"];

    [GIC mk:url_notification to:send_driver_notification d:dict isa:NO
           cb:^(id results, NSError *error) {
    }];
}

-(NSString *)ndMonedaDelViaje {
    // La propiedad es city_cur, no currency: es la que ya usa el resto del fichero.
    CityModel *ciudad = [CityModel getCityByCityId:self.curr_trip.city_id];
    return ciudad.city_cur ?: @"";
}


-(void)ndSkipRatingTapped {
    [self navigateHome];
}

@end
