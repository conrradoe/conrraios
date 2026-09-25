//
//  SingleRequestView.m

//
//  Created by Grepix - Baij on 29/10/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "SingleRequestView.h"
#import "LanguageHelper.h"
#import "WebCallConstants.h"
#import "CityModel.h"
#import "Utilities.h"
#import "CategoryModel.h"
#import "UIHelper.h"
#import "CustomPointAnnotation.h"
#import "GoogleDirectionSource.h"
#import "ConstantModel.h"
#import "DataBase.h"
#import <Conrra-Swift.h>
#import "TripNotificationHelper.h"
#import "ConrraRutaDeRecogida.h"
#import "SentOfferDetailsViewController.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

/// El paso de las tarifas rapidas, igual que QUICK_OFFER_STEP en Android.
static const float kPasoDeOfertaRapida = 0.50f;
@implementation SingleRequestView{
    MKPointAnnotation *driverPin;
    CLLocation * sourcePoint;
    CLLocation * destPoint;
    CustomPointAnnotation * pickUpPin;
    CustomPointAnnotation * dropPin;
    NSArray * arrayAnotations;
    NSDate *animateStartTime;
    // New design ivars
    MKMapView    *_ndMapView;
    UIView       *_ndTagsCard;
    UIImageView  *_ndRiderAvatar;
    UILabel      *_ndRiderNameLbl;
    UILabel      *_ndRiderRatingLbl;
    UILabel      *_ndFareLbl;
    UILabel      *_ndPickupPrimaryLbl;
    UILabel      *_ndPickupSecondaryLbl;
    UILabel      *_ndDropPrimaryLbl;
    UILabel      *_ndDropSecondaryLbl;
    UILabel      *_ndOfferAmountLbl;
    UIButton     *_ndSendOfferBtn;
    /// Las tres tarifas rapidas del card de negociar.
    UIButton     *_ndOfertasRapidas[3];
    UIView       *_ndProgressFillView;
    UIButton     *_ndQuitarBtn;
    /// Los dos rotulos sobre el mapa, como en Android: tvMapPickupBadge y tvMapTripBadge.
    UILabel      *_ndChipRecogida;
    UILabel      *_ndChipViaje;
    /// El sello de verificado sobre la foto del pasajero (ivVerifiedBadge).
    UIImageView  *_ndSelloVerificado;
    /// "Recogida a X km de ti", debajo de la valoracion (tvDistanceToPassenger).
    UILabel      *_ndDistanciaAlPasajero;
    /// El tiempo junto a la direccion A y la distancia junto a la B.
    UILabel      *_ndMinutosRecogida;
    UILabel      *_ndKmDelViaje;
    UIButton     *_ndAceptarBtn;
    BOOL          _ndSetupDone;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [super awakeFromNib];
    // La distancia por carretera llega despues de pintar: cuando llegue, se repinta la cifra.
    // Sin esto la tarjeta se quedaria con la linea recta hasta el siguiente refresco.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ndRefreshUI)
                                                 name:ConrraRutaDeRecogidaActualizada
                                               object:nil];
    [self.viewTripInfo.layer setCornerRadius:15];
    [self.viewTripInfo setClipsToBounds:YES];
    [self.viewTripFare.layer setCornerRadius:15];
    [self.viewTripFare setClipsToBounds:YES];
    self.txtOfferAmt.delegate=self;
    self.viewOfferInput.layer.cornerRadius =5;
    self.viewOfferInput.layer.borderWidth =.0;
    self.viewOfferInput.layer.borderColor =[UIColor colorNamed:@"app_border_color"].CGColor;
    self.viewOfferInput.clipsToBounds=YES;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsBuildings=NO;
    AppDelegate *appdelegate =APP_DELEGATE;
    if([ConstantModel getConstantsObject].max_decimal_allowed > 0){
        self.txtOfferAmt.keyboardType = UIKeyboardTypeDecimalPad;
    }else{
        self.txtOfferAmt.keyboardType = UIKeyboardTypeNumberPad;
    }
    [self.btnMin setTitle:[NSString stringWithFormat:@"-%@",[Utilities formatAmount:[ConstantModel getConstantsObject].offer_step_amount]] forState:(UIControlStateNormal)];
    [self.btnMax setTitle:[NSString stringWithFormat:@"+%@",[Utilities formatAmount:[ConstantModel getConstantsObject].offer_step_amount]] forState:(UIControlStateNormal)];
//    self.btnOffer3.enabled=YES;
//    [self.btnOffer3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    NSDictionary *lastloc = defaults_object(@"curr_loc");
    CLLocation *locTemp = [[CLLocation alloc] initWithLatitude:[[lastloc objectForKey:@"lat"] floatValue] longitude: [[lastloc objectForKey:@"lng"] floatValue]];
    if (lastloc != nil && [Utilities isValidLocation:locTemp.coordinate]) {
        
        CLLocation *OldLocationTemp = [[CLLocation alloc] initWithLatitude:[[lastloc objectForKey:@"lat"] floatValue] longitude: [[lastloc objectForKey:@"lng"] floatValue]];
        NSDateFormatter *df=[[NSDateFormatter  alloc] init];
        [df setDateFormat:SAVE_DATE_FORMAT];
        NSString *dateString=[lastloc objectForKey:@"date"];
        NSDate *timestamp=[df dateFromString:dateString];
        
        NSString *currentTimeStampString=[df stringFromDate:[NSDate date]];
        NSDate *currentTimeStamp=[df dateFromString:currentTimeStampString];
        int diff=[currentTimeStamp timeIntervalSince1970]-[timestamp timeIntervalSince1970];
        
        CLLocation *   ccOldLocation = [[CLLocation alloc] initWithCoordinate:OldLocationTemp.coordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:timestamp];
        
        
//        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[lastloc objectForKey:@"lat"] floatValue], [[lastloc objectForKey:@"lng"] floatValue]);
        appdelegate.currLoc=ccOldLocation;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(appdelegate.currLoc.coordinate, 600, 600);
       
        [self mapRegion:region mapView:self.mapView];
    }
    if(driverPin==nil)
    {
        driverPin = [[MKPointAnnotation alloc] init];
        driverPin.coordinate = appdelegate.currLoc.coordinate;
        [self.mapView addAnnotation:driverPin];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [self.btnAccept setTitle:[LanguageHelper getStringWithKey:@"k_1_s9_accept"] forState:UIControlStateNormal];
//
    if(self.tripOffer){
        [self.btnReject setTitle:[LanguageHelper getStringWithKey:@"k_5_s19_dec"] forState:UIControlStateNormal];
    }else{
        [self.btnReject setTitle:[LanguageHelper getStringWithKey:@"k_1_s9_reject"] forState:UIControlStateNormal];
    }
    
    
    if(self.trip){
        NSMutableAttributedString *attributed =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"]] attributes:@{NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(19)}];
        NSMutableAttributedString *attributedCategory =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",isEmpty(self.trip.cat_name)] attributes:@{NSFontAttributeName:FONTS_THEME_BOLD_NO_SCALE(19)}];
        [attributed appendAttributedString:attributedCategory];
        self.lblRequestTitle.attributedText=attributed;
//        self.lblRequestTitle.text=[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"];
    }else{
        self.lblRequestTitle.text=[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"];
    }
    self.lblOfferText.text=[LanguageHelper getStringWithKey:@"k_2_s14_ofr_u_amt" defaultValue:@"Offer your fare for the trip" ];

//    [self.btnOffer3 setTitle:[LanguageHelper getStringWithKey:@"k_63_s4_vw_snd_ofr" defaultValue:@"Send Offer"] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotification:) name:AppNotificationName.USER_OFFER_NOTIFICATION_UPDATE object:nil];
    [self setupNewDesign];
}


-(void)getNotification:(NSNotification *) notification {    NSDictionary * dict=  notification.userInfo;
    NSMutableDictionary *dicAps=[dict valueForKey:@"aps"];
//    NSString *status=[dicAps objectForKey:@"trip_status"];
//    NSString *trip_id=[dicAps objectForKey:@"trip_id"];
    [self showDataOnUiBeforeLoadData];
    [self.delegate showAlert:@"" message:isEmpty([dicAps objectForKey:@"alert"])];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
       if(proposedNewString.length>0) {
           NSArray *array=[proposedNewString componentsSeparatedByString:@"."];
           if(array.count>2){
               return NO;
           }
           if(array.count==2){
               NSString *string= [array objectAtIndex:1];
               if(string.length>2){
                   return NO;
               }
           }
       }
    if(self.tripOffer){
        if([proposedNewString floatValue]==[self.tripOffer.offer_amt floatValue]){
            self.btnOffer3.enabled=NO;
//            [self.btnOffer3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.btnOffer3 setBackgroundColor:[UIColor grayColor]];
        }else{
            self.btnOffer3.enabled=YES;
//            [self.btnOffer3 setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateNormal];
            [self.btnOffer3 setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
        }
    }else{
        if([proposedNewString floatValue]==[self.trip.trip_fare floatValue]){
            self.btnOffer3.enabled=NO;
//            [self.btnOffer3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.btnOffer3 setBackgroundColor:[UIColor grayColor]];
        }else{
            self.btnOffer3.enabled=YES;
//            [self.btnOffer3 setTitleColor:[UIColor colorNamed:@"app_theame"] forState:UIControlStateNormal];
            [self.btnOffer3 setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
        }
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    CityModel * cityModel=[CityModel getCityByCityId:self.trip.city_id];
    [self updateOfferAmountOnButton:[self.txtOfferAmt.text floatValue] cur:isEmpty(cityModel.city_cur)];
}

- (void)applicationWillEnterForeground {
    int diff=[[NSDate date] timeIntervalSince1970]-[animateStartTime timeIntervalSince1970];
    ConstantModel *constantModel=[ConstantModel getConstantsObject];
    if(diff<constantModel.max_time_span){
        [self.viewProgress.layer removeAllAnimations];
        float part=(1.0/(constantModel.max_time_span*1.0));
        float pro=part*diff;
        [self animateProgress:pro second:constantModel.max_time_span-diff];
    }else{
        [self.delegate view:self  onCloseTripRequest:self.trip];
    }
}


-(void) mapRegion:(MKCoordinateRegion ) region mapView:(MKMapView *)mapView{
    @try {
        [mapView setRegion:[mapView regionThatFits:region] animated:NO];
    } @catch (NSException *exception) {
        if( region.center.longitude > -89 && region.center.longitude < 89 && region.center.longitude > -179 && region.center.longitude < 179 ){
        [mapView setRegion:[mapView regionThatFits:region] animated:YES];
        }
    } @finally {
    }
}

+(SingleRequestView *)showTripRequestAcceptViewWithDelegate:(id<SingleRequestViewDelegate>)delegate parentView:(nonnull UIView *)parentView trip:(TripModel *) trip
{
    SingleRequestView *rootView =(SingleRequestView *) [[[NSBundle mainBundle] loadNibNamed:@"SingleRequestView" owner:nil options:nil] objectAtIndex:0];
    rootView.delegate=delegate;
    rootView.trip=trip;
    rootView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [parentView addSubview:rootView];
    [rootView showDataOnUi];
    return rootView ;
}

+(SingleRequestView *)showTripRequestAcceptViewWithDelegate:(id<SingleRequestViewDelegate>)delegate parentView:(nonnull UIView *)parentView tripIdFromRequest:(TripModel *) trip
{
    SingleRequestView *rootView =(SingleRequestView *) [[[NSBundle mainBundle] loadNibNamed:@"SingleRequestView" owner:nil options:nil] objectAtIndex:0];
    rootView.delegate=delegate;
    rootView.trip=trip;
    rootView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [parentView addSubview:rootView];
    rootView.viewAddress.hidden=YES;
    rootView.viewTripInfo.hidden=YES;
    [rootView.activityLoader startAnimating];
    [rootView getAllPendingTrips:NO isResetTimer:NO];
    [rootView animateProgress];
    return rootView ;
}

+(SingleRequestView *)showSentTripRequestAcceptViewWithDelegate:(id<SingleRequestViewDelegate>)delegate parentView:(nonnull UIView *)parentView tripIdFromRequest:(TripOffer *) tripOffer{
    SingleRequestView *rootView =(SingleRequestView *) [[[NSBundle mainBundle] loadNibNamed:@"SingleRequestView" owner:nil options:nil] objectAtIndex:0];
    rootView.delegate=delegate;
    rootView.trip=tripOffer.trip;
    rootView.tripOffer=tripOffer;
    CGFloat bottomPadding;
    CGFloat topPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        bottomPadding = window.safeAreaInsets.bottom;
        topPadding=window.safeAreaInsets.top;
    }
    rootView.frame=CGRectMake(0, topPadding+44, SCREEN_WIDTH, SCREEN_HEIGHT-(topPadding+44+bottomPadding));
    [parentView addSubview:rootView];
    rootView.viewAddress.hidden=YES;
    rootView.viewTripInfo.hidden=YES;
    [rootView.activityLoader startAnimating];
    [rootView getAllPendingTrips:NO isResetTimer:NO];
//    [rootView animateProgress];
    if(rootView.tripOffer){
        [rootView.btnReject setTitle:[LanguageHelper getStringWithKey:@"k_5_s19_dec"] forState:UIControlStateNormal];
    }else{
        [rootView.btnReject setTitle:[LanguageHelper getStringWithKey:@"k_1_s9_reject"] forState:UIControlStateNormal];
    }
    
    
    if(rootView.trip){
        NSMutableAttributedString *attributed =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"]] attributes:@{NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(19)}];
        NSMutableAttributedString *attributedCategory =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",isEmpty(rootView.trip.cat_name)] attributes:@{NSFontAttributeName:FONTS_THEME_BOLD_NO_SCALE(19)}];
        [attributed appendAttributedString:attributedCategory];
        rootView.lblRequestTitle.attributedText=attributed;
//        self.lblRequestTitle.text=[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"];
    }else{
        rootView.lblRequestTitle.text=[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"];
    }
    return rootView ;
}

+(SingleRequestView *)showTripRequestAcceptViewWithDelegate:(id<SingleRequestViewDelegate>)delegate parentView:(nonnull UIView *)parentView tripId:(NSString *) tripId
{
    SingleRequestView *rootView =(SingleRequestView *) [[[NSBundle mainBundle] loadNibNamed:@"SingleRequestView" owner:nil options:nil] objectAtIndex:0];
    rootView.delegate=delegate;
    rootView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [parentView addSubview:rootView];
    [rootView getForTestTripDetailsDemo:tripId];
    rootView.hidden=YES;
    return rootView ;
}


//data.setObject(paymentIntentId as String, forKey: "payment_intent_id" as NSCopying)
//data.setObject(pay_mode ?? CASH_PAY  as String, forKey: "trip_pay_mode" as NSCopying)

- (IBAction)onAcceptButtonTap:(id)sender {
    if(YES){
        float amount =0;
        if(self.tripOffer&&[self.tripOffer.user_offer_amt floatValue]>0){
            amount = [self.tripOffer.user_offer_amt floatValue];
        }else{
            amount = [self.trip.trip_fare floatValue];
        }
        [self updateOfferForTrip:amount];
        return;
    }
//    [APP_DELEGATE stopRequestSound];
//    float amount =0;
//    if(self.tripOffer&&[self.tripOffer.user_offer_amt floatValue]>0){
//        amount = [self.tripOffer.user_offer_amt floatValue];
//    }else{
//        amount = [self.trip.trip_fare floatValue];
//    }
//    [self.trip createStripUserCreatePaymentIntentDonetrip_fare:amount completionBlock:^(id  _Nullable results, NSError * _Nullable error, NSString * _Nullable message) {
//        if(results){
//            NSString *paymentIntentID= [results objectForKey:@"id"];
//            if(paymentIntentID.length>0){
//                [self acceptOffer:paymentIntentID paymentType:CARD];
//            }else{
//                [self acceptOffer:nil paymentType:CASH_PAY];
//            }
//        }else{
//            [self acceptOffer:nil paymentType:CASH_PAY];
//        }
//    }];
//    return;
    
//    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
//        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
//        TRIP_STATUS         :TS_ACCEPTED,
//        TRIP_ID             :isEmpty(self.trip.trip_Id),
//    }];
//    NSString *acceptTime=[NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
//    [dict  setObject:acceptTime forKey:@"tm_acc"];
//    if([ConstantModel getConstantsObject].otp_start){
//        [dict  setObject:[Utilities getRandomPINString:5] forKey:@"otp"];
//    }
//    if(self.tripOffer&&[self.tripOffer.user_offer_amt floatValue]>0){
//        [dict setObject:self.tripOffer.user_offer_amt forKey:@"trip_pay_amount"];
//    }
//    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
//    [GIC mkwu:trip_accept    d:dict    isa:NO   cb:^(id results, NSError *error) {
//        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
//        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
////        [self removeFromSuperview];
//        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
//        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
////            AppDelegate *delegate= APP_DELEGATE;
////            [[DataBase shareDataBase] insertTripLogDataTripID:self.trip.trip_Id ulat:self.trip.user.lat ulng:self.trip.user.lng dlat:delegate.currLoc.coordinate.latitude dlng:delegate.currLoc.coordinate.longitude tripStatus:TS_ACCEPTED timeAt:[dict objectForKey:@"tm_acc"] key1:@"" key2:@"" key3:@"" key4:@"" ];
//            // success
//            
//            TripModel  *currTrip = [[TripModel alloc] initItemWithDict:[results objectForKey:P_RESPONSE]];
//            [self.delegate view:self onAcceptTripSuccess:currTrip];
//            [TripNotificationHelper sendNotificationToUser:TS_ACCEPTED data:[results objectForKey:P_RESPONSE] trip:self.trip];
//        }
//        
//        else  if (error != nil) {
//            [self.delegate view:self onCloseTripRequest:self.trip];
//            NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
//            id jsonObjects ;
//            if(data) {
//                jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            }
//            if ([[jsonObjects objectForKey:P_STATUS] isEqualToString:@"Error"]) {
//                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"] ];
//            }
//            else{
//                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] message:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] ];
//            }
//        }
//    }];
}

-(void) acceptOffer:(NSString *) paymentIntentId paymentType:(NSString *)paymentType{
    

    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        TRIP_STATUS         :TS_ACCEPTED,
        TRIP_ID             :isEmpty(self.trip.trip_Id),
    }];
    NSString *acceptTime=[NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    [dict  setObject:acceptTime forKey:@"tm_acc"];
    if([ConstantModel getConstantsObject].otp_start){
        [dict  setObject:[Utilities getRandomPINString:5] forKey:@"otp"];
    }
    if(self.tripOffer&&[self.tripOffer.user_offer_amt floatValue]>0){
        [dict setObject:self.tripOffer.user_offer_amt forKey:@"trip_pay_amount"];
    }
    if(paymentIntentId.length>0){
        [dict setObject:paymentIntentId forKey:@"payment_intent_id"];
    }
    if(paymentType.length>0){
        [dict setObject:paymentType forKey:@"trip_pay_mode"];
    }else{
        [dict setObject:CASH_PAY forKey:@"trip_pay_mode"];
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:trip_accept    d:dict    isa:NO   cb:^(id results, NSError *error) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
//        [self removeFromSuperview];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
//            AppDelegate *delegate= APP_DELEGATE;
//            [[DataBase shareDataBase] insertTripLogDataTripID:self.trip.trip_Id ulat:self.trip.user.lat ulng:self.trip.user.lng dlat:delegate.currLoc.coordinate.latitude dlng:delegate.currLoc.coordinate.longitude tripStatus:TS_ACCEPTED timeAt:[dict objectForKey:@"tm_acc"] key1:@"" key2:@"" key3:@"" key4:@"" ];
            // success
            
            TripModel  *currTrip = [[TripModel alloc] initItemWithDict:[results objectForKey:P_RESPONSE]];
            [self.delegate view:self onAcceptTripSuccess:currTrip];
            [TripNotificationHelper sendNotificationToUser:TS_ACCEPTED data:[results objectForKey:P_RESPONSE] trip:self.trip];
        }
        
        else  if (error != nil) {
            [self.delegate view:self onCloseTripRequest:self.trip];
            NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
            id jsonObjects ;
            if(data) {
                jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            if ([[jsonObjects objectForKey:P_STATUS] isEqualToString:@"Error"]) {
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"] ];
            }
            else{
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] message:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] ];
            }
        }
    }];
}

-(void)getForTestTripDetailsDemo:(NSString * )tripId{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"trip_id" :tripId,
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:TRIP_GETTRIP
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            // success
            self.hidden=NO;
            self.trip= [[TripModel alloc] initItemWithDict:[[results objectForKey:P_RESPONSE]objectAtIndex:0]];
            [self showDataOnUi];
        }
    }];
}



-(void) showDataOnUiBeforeLoadData{
    self.lblPickupAddrees.text=isEmpty(self.trip.trip_pick_loc);
    self.lblDropAddress.text=isEmpty(self.trip.trip_drop_loc);
    self.lblRequestTitle2.text=@"";
    CityModel * cityModel=[CityModel getCityByCityId:self.trip.city_id];
    self.lblCurrency.text=isEmpty(cityModel.city_cur);
    self.lblDuration.text=[NSString stringWithFormat:@"%d%@",self.trip.trip_total_time,[LanguageHelper getStringWithKey:self.trip.trip_total_time<=1?@"k_17_s4_min":@"k_17_s4_mins" defaultValue:@"min"]];
    self.lblDistance.text=[NSString stringWithFormat:@"%@ %@",[Utilities formatDistance:[self.trip.trip_distance floatValue
                                                                                         ]],cityModel.city_dist_unit];
    self.lblTripFare.text=[Utilities formatAmountAndCurrency:[self.trip.trip_fare floatValue] currency:cityModel.city_cur];
//    if([self.trip.toll_charges floatValue]>0){
//        self.lblTollCalcuated.text = [LanguageHelper getStringWithKey:@"k_d_toll"];
//    }else{
//        self.lblTollCalcuated.text = [LanguageHelper getStringWithKey:@"k_d_toll_not"];
//    }
    self.lblTollCalcuated.text = @"";
    [self drawroute];
    
    float totalFare= [self.trip.trip_fare floatValue];
    float totalFare1= totalFare+(totalFare*5/100);
    float totalFare2= totalFare+(totalFare*10/100);
//    float totalFare3= totalFare+(totalFare*15/100);
    
    CategoryModel *category=  [CategoryModel getCategoryByid:[self.trip.category_id intValue]];
    if(category){
        float estmateFare = [self.trip.base_est_amt floatValue];
        if([category isAllowToCheckMaxMin]){
          
            float minfare = estmateFare - (estmateFare *category.min_offer_perc)/100.0;
            float minHalffare = estmateFare - (estmateFare *category.min_offer_perc/2.0)/100.0;
            float maxfare = estmateFare + (estmateFare *category.max_offer_perc)/100.0;
            float maxHalffare = estmateFare + (estmateFare *category.max_offer_perc/2.0)/100.0;
            [self.btNewOffer1 setTitle:[Utilities formatAmountAndCurrency:minfare currency:cityModel.city_cur] forState:UIControlStateNormal];
            [self.btNewOffer2 setTitle:[Utilities formatAmountAndCurrency:minHalffare currency:cityModel.city_cur] forState:UIControlStateNormal];
            [self.btNewOffer3 setTitle:[Utilities formatAmountAndCurrency:maxHalffare currency:cityModel.city_cur] forState:UIControlStateNormal];
            [self.btNewOffer4 setTitle:[Utilities formatAmountAndCurrency:maxfare currency:cityModel.city_cur] forState:UIControlStateNormal];
        }else{
            [self.viewnewOfferCustomize hideByHeight:YES];
            [self.viewOfferCustomise hideByHeight:YES ];
        }
        [self updateOfferAmountOnButton:estmateFare cur:isEmpty(cityModel.city_cur)];
    }else{
        [self updateOfferAmountOnButton:[self.trip.trip_fare floatValue] cur:isEmpty(cityModel.city_cur)];
    }
    
    [self.btnOffer1 setTitle:[Utilities formatAmountAndCurrency:totalFare1 currency:cityModel.city_cur] forState:UIControlStateNormal];
    [self.btnOffer2 setTitle:[Utilities formatAmountAndCurrency:totalFare2 currency:cityModel.city_cur] forState:UIControlStateNormal];
//    [self.btnOffer3 setTitle:[Utilities formatAmountAndCurrency:totalFare3 currency:cityModel.city_cur] forState:UIControlStateNormal];
    if(self.tripOffer&&[self.tripOffer.user_offer_amt floatValue]>0){
        self.txtOfferAmt.text=[Utilities formatAmount:[self.tripOffer.offer_amt floatValue]];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_1_s9_accept"]];
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[Utilities formatAmountAndCurrency:[self.trip.trip_fare floatValue] currency:cityModel.city_cur]];
        [attributedString appendAttributedString:attributedString2];
        NSString * title =[NSString stringWithFormat:@"%@\n%@",[[LanguageHelper getStringWithKey:@"k_1_s9_accept"] uppercaseString],[Utilities formatAmountAndCurrency:[self.tripOffer.user_offer_amt floatValue] currency:cityModel.city_cur]];
        self.lblAccept.text=title;
    }else{
        if(self.tripOffer){
            self.txtOfferAmt.text=[Utilities formatAmount:[self.tripOffer.offer_amt floatValue]];
        }else{
            self.txtOfferAmt.text=[Utilities formatAmount:[self.trip.trip_fare floatValue]];
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[LanguageHelper getStringWithKey:@"k_1_s9_accept"]];
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[Utilities formatAmountAndCurrency:[self.trip.trip_fare floatValue] currency:cityModel.city_cur]];
        [attributedString appendAttributedString:attributedString2];
        NSString * title =[NSString stringWithFormat:@"%@\n%@",[[LanguageHelper getStringWithKey:@"k_1_s9_accept"] uppercaseString],[Utilities formatAmountAndCurrency:[self.trip.trip_fare floatValue] currency:cityModel.city_cur]];
        self.lblAccept.text=title;
    }
    
    if(self.trip){
        NSMutableAttributedString *attributed =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"]] attributes:@{NSFontAttributeName:FONTS_THEME_REGULAR_NO_SCALE(19)}];
        NSMutableAttributedString *attributedCategory =[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",isEmpty(self.trip.cat_name)] attributes:@{NSFontAttributeName:FONTS_THEME_BOLD_NO_SCALE(19)}];
        [attributed appendAttributedString:attributedCategory];
        self.lblRequestTitle.attributedText=attributed;
//        self.lblRequestTitle.text=[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"];
    }else{
        self.lblRequestTitle.text=[LanguageHelper getStringWithKey:@"k_1_s9_ncmng_rqst"];
    }
    
    SocketHelperSwift * socketHelper = [APP_DELEGATE getSockethelperSwift];
    [socketHelper connect];
    [self ndRefreshUI];
}



-(void) showDataOnUi{
    self.lblPickupAddrees.text=isEmpty(self.trip.trip_pick_loc);
    self.lblDropAddress.text=isEmpty(self.trip.trip_drop_loc);
    self.lblRequestTitle2.text=@"";
    CityModel * cityModel=[CityModel getCityByCityId:self.trip.city_id];
    self.lblDuration.text=[NSString stringWithFormat:@"%d min",self.trip.trip_total_time];
    self.lblDistance.text=[NSString stringWithFormat:@"%@ %@",[Utilities formatDistance:[self.trip.trip_distance floatValue
                                                                                         ]],cityModel.city_dist_unit];
    self.lblTripFare.text=[Utilities formatAmountAndCurrency:[self.trip.trip_fare floatValue] currency:cityModel.city_cur];
    [self animateProgress];
    [self drawroute];
    self.lblTollCalcuated.text = @"";
    [self ndRefreshUI];
}





- (void)animateProgress{
    ConstantModel *constantModel=[ConstantModel getConstantsObject];
    [self animateProgress:0 second:constantModel.max_time_span];
    animateStartTime=[NSDate date];
}




- (void)animateProgress:(float)value second:(int)second{
    self.viewProgress.progressValue = value;
    if (_ndProgressFillView) {
        _ndProgressFillView.frame = CGRectMake(0, 0, SCREEN_WIDTH * value, 3);
    }
    [UIView animateWithDuration:second
                     animations:^{
        self.viewProgress.progressValue = 1.f;
        if (self->_ndProgressFillView) {
            self->_ndProgressFillView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 3);
        }
    }
                     completion:^(BOOL finished1) {
        if(finished1){
            [self updateMissedStatus];
        }
        //                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //                             [UIView animateWithDuration:3
        //                                              animations:^{
        //                                                  self.viewProgress.progressValue = 0.f;
        //                                              }
        //                                              completion:^(BOOL finished2) {
        //                                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //                                                      [self animateProgress];
        //                                                  });
        //                                              }];
        //                         });
    }];
}


-(void) updateMissedStatus{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        @"status"         :@"missed",
        TRIP_ID             :isEmpty(self.trip.trip_Id),
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:API_UPDATE_OFFER
                  d:dict
              cb:^(id results, NSError *error) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        [self.delegate view:self onCloseTripRequest:self.trip];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
        }
    }];
}

- (IBAction)onRejectButtonTap:(id)sender {
    [APP_DELEGATE stopRequestSound];
//    [self removeFromSuperview];
    [self.delegate view:self onRejectTripSuccess:self.trip];
}


-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    
    MKAnnotationView *pinView = nil;
    if(annotation != self.mapView.userLocation)
    {
        static NSString *defaultPinID = @"com.driver.pin";
        pinView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        if (annotation == driverPin) {
            
            NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
            CategoryModel *category=  [CategoryModel getCategoryByid:[[dict1 objectForKey:P_CATEGORY_ID] intValue]];
            pinView.image=nil;
            if(category)
            {
                NSString * imageName=@"car_icon";
                imageName=category.cat_map_icon_path;
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
                
//                [[manager imageLoader] downloadImageWithURL:url completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
//                    if (image) {
//                        pinView.image=[UIHelper imageForMapWithImage:image];
//                    }
//                }];
            }
            
            //            pinView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
            [UIView animateWithDuration:2
                             animations:^{
                
                
                //                                 pinView.image = [UIImage imageNamed:imageName];
//                self->driverPinView =pinView;
            }];
        }
        else if([annotation isKindOfClass:[CustomPointAnnotation class]])
        {
            CustomPointAnnotation  *mAnno=(CustomPointAnnotation *) annotation;
            if([mAnno.type isEqualToString:PIN_START])
            {
                static UIImage *startDot = nil;
                if (!startDot) {
                    CGFloat s = 20.0;
                    UIGraphicsImageRenderer *ir = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(s, s)];
                    startDot = [ir imageWithActions:^(UIGraphicsImageRendererContext *c) {
                        [[UIColor whiteColor] setFill];
                        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, s, s)] fill];
                        [[UIColor colorNamed:@"app_theame"] setFill];
                        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(3, 3, s-6, s-6)] fill];
                    }];
                }
                pinView.image = startDot;
                pinView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            }
            else if([mAnno.type isEqualToString:PIN_USER] ){
                pinView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
                pinView.image = [UIImage imageNamed:@"PIN"];
            }
            else{
                pinView.image = [UIImage imageNamed:@"map_pin_drop"];
                pinView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
            }
            
        }
    }
    else {
        
        [self.mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}



-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
    MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
    ulv.hidden = YES;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor colorNamed:@"app_theame"];
    renderer.lineWidth = 4.0;
    renderer.lineJoin = kCGLineJoinRound;
    renderer.lineCap = kCGLineCapRound;
    return renderer;
}

-(BOOL)isDarkMode{
    if (@available(iOS 13, *)) {
        if([[ConstantModel getConstantsObject] getCValueFK:ckey_etld]){
            NSString * uiOri=defaults_object(@"app_mode");
            if(uiOri&&[uiOri isEqualToString:@"light"]){
                return NO;
            }else  if(uiOri&&[uiOri isEqualToString:@"dark"]){
                return YES;
            }else  if(uiOri&&[uiOri isEqualToString:@"auto"]){
                NSDate *date = [NSDate date];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
                NSInteger hour = [components hour];
                if(hour<=DAY_START_HURS){
                    return YES;
                }else if(hour>DAY_START_HURS&&hour<DAY_END_HURS){
                    return NO;
                }else{
                    return YES;
                }
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    }
    return NO;
}

-(void)drawroute{
    
    BOOL isDrawGoogleRoute=NO;
   
    sourcePoint=[[CLLocation alloc]   initWithLatitude:[self.trip.trip_pick_lat doubleValue]  longitude:[self.trip.trip_pick_long doubleValue]];
    destPoint=[[CLLocation alloc]  initWithLatitude:[self.trip.trip_drop_lat doubleValue] longitude:[self.trip.trip_drop_long doubleValue]];
    if(isDrawGoogleRoute)
    {
        GoogleDirectionSource * userDriverLocationRoute=[[GoogleDirectionSource alloc]  initWithSource:sourcePoint destination:destPoint];
        
        [userDriverLocationRoute findDirection_isInTrip:NO  WithCompletionBlock:^(id results, NSError *error) {
            if([results isKindOfClass:[DirectionModel class]])
            {
                
                DirectionModel  *dModel=(DirectionModel *)results;
                
                
                [self zoomToFitMapAnnotationsWith:userDriverLocationRoute];
                
                
                [self.mapView addOverlay:[dModel getPolyline] level:MKOverlayLevelAboveRoads];
                
                MKPointAnnotation *point1 = [[MKPointAnnotation alloc]init];
                point1.coordinate = dModel.northeast.coordinate;
                MKPointAnnotation *point2 = [[MKPointAnnotation alloc]init];
                point2.coordinate = dModel.southwest.coordinate;
                
                NSMutableArray *arrAnn = [[NSMutableArray alloc]initWithObjects:point1,point2, nil];
                
                [self zoomToFitMapAnnotations:arrAnn];
                
                
                
            }
            else {
                
            }
        }];
    }else{
        /*
         LOS PINES VAN PRIMERO, pase lo que pase con la ruta.

         Aqui se pedia la ruta GUARDADA del viaje (GET_ROUTE) y, si no venia, se salia por
         uno de los tres `return` sin dibujar absolutamente nada: ni linea ni pines. Y en una
         solicitud recien creada esa ruta casi nunca esta todavia -- la sube la app del
         pasajero despues, con saveCoverRouteOnServerForTripId. De ahi que el conductor viera
         un mapa gris y vacio justo cuando tiene que decidir por donde va el viaje.

         Ahora los dos pines se ponen siempre, con las coordenadas del propio viaje, y la
         linea se busca en dos sitios: la guardada si existe y, si no, se le pide a Google.
         */
        [self ndPonerPinesDeLaRuta];

        NSMutableDictionary * dict=[[NSMutableDictionary alloc] init];
        [dict setObject:self.trip.trip_Id forKey:@"trip_id"];
        [dict setObject:@"1" forKey:@"is_route_needed"];
        [GIC mkwu:GET_ROUTE   d:dict isa:NO  cb:^(id results, NSError *error) {
            NSArray *tripData = [[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]
                ? [results objectForKey:P_RESPONSE] : @[];
            NSArray *arrayPath = tripData.count > 0
                ? [self decodePoints:[[tripData objectAtIndex:0] objectForKey:@"req_route_data"]]
                : @[];
            if (arrayPath.count > 0) {
                MKPolyline *polyline = [self getPolyline:arrayPath];
                [self.mapView addOverlay:polyline];
                [self.mapView setVisibleMapRect:[polyline boundingMapRect]
                                    edgePadding:UIEdgeInsetsMake(50.0, 40.0, 40.0, 40.0)
                                       animated:YES];
            } else {
                [self ndDibujarRutaConGoogle];
            }
        }];
    }
  
}



/**
 Los dos pines del viaje, puestos desde las coordenadas del propio viaje.

 No dependen de que exista ninguna ruta: son el punto A y el punto B, y el conductor tiene
 que verlos aunque la linea no llegue nunca.
 */
- (void)ndPonerPinesDeLaRuta {
    if (pickUpPin) { [self.mapView removeAnnotation:pickUpPin]; }
    if (dropPin)   { [self.mapView removeAnnotation:dropPin]; }

    pickUpPin = [[CustomPointAnnotation alloc] initWithType:PIN_START];
    pickUpPin.coordinate = sourcePoint.coordinate;
    dropPin = [[CustomPointAnnotation alloc] initWithType:PIN_DROP];
    dropPin.coordinate = destPoint.coordinate;

    if ([Utilities isValidLocation:pickUpPin.coordinate]) {
        [self.mapView addAnnotation:pickUpPin];
    }
    if ([Utilities isValidLocation:dropPin.coordinate]) {
        [self.mapView addAnnotation:dropPin];
    }
    arrayAnotations = @[pickUpPin, dropPin];
    [self zoomToFitMapAnnotations:[NSMutableArray arrayWithArray:arrayAnotations]];
}

/**
 La linea del viaje pedida a Google, cuando el servidor no tiene ninguna guardada.

 Es lo que hace Android en getTripRoute: no espera a que exista una ruta almacenada, la pide.
 Sin esto, en una solicitud nueva el mapa se queda sin trazado.
 */
- (void)ndDibujarRutaConGoogle {
    if (![Utilities isValidLocation:sourcePoint.coordinate] ||
        ![Utilities isValidLocation:destPoint.coordinate]) {
        return;
    }
    GoogleDirectionSource *ruta = [[GoogleDirectionSource alloc] initWithSource:sourcePoint
                                                                   destination:destPoint];
    [ruta findDirection_isInTrip:NO WithCompletionBlock:^(id results, NSError *error) {
        if (![results isKindOfClass:[DirectionModel class]]) {
            return;
        }
        DirectionModel *dModel = (DirectionModel *)results;
        MKPolyline *linea = [dModel getPolyline];
        if (linea == nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addOverlay:linea];
            [self.mapView setVisibleMapRect:[linea boundingMapRect]
                                edgePadding:UIEdgeInsetsMake(50.0, 40.0, 40.0, 40.0)
                                   animated:YES];
        });
    }];
}

-( NSArray *) decodePoints:(NSString *) encoded
{
    NSMutableArray *poly=[[NSMutableArray alloc] init];
    int index = 0;
    int len = (int)encoded.length;
    int lat = 0, lng = 0;
    
    while (index < len) {
        int b, shift = 0, result = 0;
        do {
            
            //            b = encoded.charAt(index++) - 63;
            b =  [encoded characterAtIndex:index++]- 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        
        shift = 0;
        result = 0;
        do {
            b =  [encoded characterAtIndex:index++]- 63;
            //            b = encoded.charAt(index++) - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        
        CLLocation *p=[[CLLocation alloc] initWithLatitude:(((double) lat / 1E5)) longitude:(((double) lng / 1E5))];
        [poly addObject:p];
    }
    return poly;
}




-(MKPolyline *) getPolyline:(NSArray *)array
{
    
    CLLocationCoordinate2D coords[array.count];
    
    for (int i = 0; i <array.count; i++) {
//        NSDictionary *dict=[array  objectAtIndex:i];
        CLLocation *p=[array  objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(p.coordinate.latitude,p.coordinate.longitude);
    }
    
    CustomPointAnnotation * pickUp=[[CustomPointAnnotation alloc]  initWithType:PIN_START];
    CLLocation *pPickup=[array  objectAtIndex:0];
    pickUp.coordinate =CLLocationCoordinate2DMake(pPickup.coordinate.latitude,pPickup.coordinate.longitude);
    [self.mapView addAnnotation:pickUp];
    CustomPointAnnotation * dropAno=[[CustomPointAnnotation alloc]  initWithType:TS_END];
    CLLocation *drop=[array  objectAtIndex:array.count-1];
    dropAno.coordinate=CLLocationCoordinate2DMake(drop.coordinate.latitude,drop.coordinate.longitude);
    [self.mapView addAnnotation:dropAno];
    return   [MKPolyline polylineWithCoordinates:coords count:array.count];
}


-(void)zoomToFitMapAnnotations:(NSMutableArray *) arrayAnotations1
{
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -70;
    topLeftCoord.longitude = 140;
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 50;
    bottomRightCoord.longitude = -100;
    
    for (id <MKAnnotation> annotation in arrayAnotations1) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.5; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.5; // Add a little extra space on the sides
    [self mapRegion:region mapView:self.mapView];
}

- (void)zoomToFitMapAnnotationsWith:(GoogleDirectionSource * )directionSource  {
    
    pickUpPin=[[CustomPointAnnotation alloc]  initWithType:PIN_START];
    pickUpPin.coordinate= directionSource.source.coordinate;
    
    [self.mapView addAnnotation:pickUpPin];
    
    
    dropPin=[[CustomPointAnnotation alloc]  initWithType:PIN_DROP];
    dropPin.coordinate= directionSource.destination.coordinate; 
    [self.mapView addAnnotation:dropPin];
    arrayAnotations=@[pickUpPin,dropPin];
}



-(void)getAllPendingTrips:(BOOL)isShowLoader isResetTimer:(BOOL)isResetTimer{
    BOOL isTest=NO;
    if(isTest){ //for test
        self.trip=[[TripModel alloc] init];
        self.trip.trip_Id=@"280";
    }
    if(self.trip.trip_Id){
        // if trip id is come from notification then get only trip data by trip id.
        // But if the trip object already has full data (pick location populated), skip the
        // server round-trip and show data immediately — avoids the double-API-call delay.
        if(self.trip.trip_pick_loc.length > 0 && self.trip.trip_drop_loc.length > 0){
            // Both addresses already populated — skip API round-trip
            self.viewLoadingReequestData.hidden=YES;
            self.viewAddress.hidden=NO;
            self.viewTripInfo.hidden=NO;
            [self showDataOnUiBeforeLoadData];
            return;
        } else if(self.trip.trip_pick_loc.length > 0){
            // Pickup known but drop address missing — show partial data while API fetches the rest
            self.viewAddress.hidden=NO;
            self.viewTripInfo.hidden=NO;
            [self showDataOnUiBeforeLoadData];
        }
        self.viewLoadingReequestData.hidden=NO;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
            @"trip_id" :isEmpty(self.trip.trip_Id),
        }];
        [GIC mkwerwu:TRIP_GETTRIP
                      d:dict
                  cb:^(id results, NSError *error) {
            self.viewLoadingReequestData.hidden=YES;
            if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"] && [[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                NSArray *arrTemp = [results objectForKey:P_RESPONSE];
                NSMutableArray *arrtemp1 =[[NSMutableArray alloc]init];
                for (NSMutableDictionary *dict in arrTemp) {
                    TripModel  *currTrip1 = [[TripModel alloc] initItemWithDict:dict];
                    [arrtemp1 addObject:currTrip1];
                }
                if(arrtemp1.count>0){
                    self.viewAddress.hidden=NO;
                    self.viewTripInfo.hidden=NO;
                    self.trip=[arrtemp1 firstObject];
                    [self showDataOnUiBeforeLoadData];
                }else{
                    self.viewAddress.hidden=YES;
                    self.viewTripInfo.hidden=YES;
                    [self.delegate view:self onCloseTripRequest:self.trip];
                }
            }
            else{
                self.viewAddress.hidden=YES;
                self.viewTripInfo.hidden=YES;
                [self.delegate view:self onCloseTripRequest:self.trip];
            }

        }];
        return;
    } 
    AppDelegate *appdelegate =APP_DELEGATE;
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    if(dict1==nil)  {
        return;
    }
    if (isShowLoader) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    ConstantModel *constantTaxiModel=[ConstantModel getConstantsObject];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    
    [dict setObject:TS_REQUEST forKey:TRIP_STATUS];
    [dict setObject:[dict1 objectForKey:P_DRIVER_ID] forKey:P_DRIVER_ID];
    [dict setObject:@PENDING_HOURS forKey:@"hours"];
    [dict setObject:[dict1 objectForKey:P_CATEGORY_ID] forKey:P_CATEGORY_ID];
    [dict setObject:[NSString stringWithFormat:@"%f", appdelegate.currLoc.coordinate.latitude] forKey:@"lat"];
    [dict setObject:[NSString stringWithFormat:@"%f", appdelegate.currLoc.coordinate.longitude] forKey:@"lng"];
    if (constantTaxiModel.constant_driver_radius ==0.0) {
        [dict setObject:@"4" forKey:@"miles"];
    }
    else{
        [dict setObject:[NSString stringWithFormat:@"%.1f",constantTaxiModel.constant_driver_radius] forKey:@"miles"];
    }
    [GIC mkwerwu:GET_REVISED_TRIPS
                  d:dict
              cb:^(id results, NSError *error) {
       
        self.viewLoadingReequestData.hidden=YES;
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"] && [[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {

            NSArray *arrTemp = [results objectForKey:P_RESPONSE];
            NSMutableArray *arrtemp1 =[[NSMutableArray alloc]init];
            for (NSMutableDictionary *dict in arrTemp) {
                TripModel  *currTrip1 = [[TripModel alloc] initItemWithDict:dict];
                [arrtemp1 addObject:currTrip1];
            }
            if(arrtemp1.count>0){
                self.viewAddress.hidden=NO;
                self.viewTripInfo.hidden=NO;
                self.trip=[arrtemp1 firstObject];
                [self showDataOnUiBeforeLoadData];
            }else{
                self.viewAddress.hidden=YES;
                self.viewTripInfo.hidden=YES;
                [self.delegate view:self onCloseTripRequest:self.trip];
            }
        }
        else{
            self.viewAddress.hidden=YES;
            self.viewTripInfo.hidden=YES;
            [self.delegate view:self onCloseTripRequest:self.trip];
        }
    }];
}


- (IBAction)onOfferButtonTap:(UIButton *)sender {
    float offerAmt=0;
    float totalFare= [self.trip.trip_fare floatValue];
    if(self.btnOffer1 == sender){
        offerAmt= totalFare+(totalFare*5/100);
    }
    else if(self.btnOffer2 == sender){
        offerAmt= totalFare+(totalFare*10/100);
    }
    else if(self.btnOffer3 == sender){
        if([self.txtOfferAmt.text floatValue]<=0){
            [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_r1_s6_please_enter_amount"]];
            return;
        }
        offerAmt= [self.txtOfferAmt.text floatValue];
        CategoryModel *category=  [CategoryModel getCategoryByid:[self.trip.category_id intValue]];
        if(category){
            if([category isAllowToCheckMaxMin]){
                float estmateFare = [self.trip.base_est_amt floatValue];
                float minfare = estmateFare - (estmateFare *category.min_offer_perc)/100.0;
                float minHalffare = estmateFare - (estmateFare *category.min_offer_perc/2.0)/100.0;
                float maxfare = estmateFare + (estmateFare *category.max_offer_perc)/100.0;
                float maxHalffare = estmateFare + (estmateFare *category.max_offer_perc/2.0)/100.0;
                if(offerAmt<minfare){
                    [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_r1_s6_pls_ntr_amnt_grtr_thn_min_fare"]];
                    return;
                }
                if(offerAmt>maxfare){
                    [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_r1_s6_pls_ntr_amnt_less_thn_max_fare"]];
                    return;
                }
            }
        }
        
    }
    [self updateOfferForTrip:offerAmt];
}

-(void)updateOfferForTrip:(float) offerAmount{
    [APP_DELEGATE stopRequestSound];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        @"status"         :@"offer",
        TRIP_ID             :isEmpty(self.trip.trip_Id),
        @"offer_amt":[Utilities formatAmount:offerAmount],
    }];
    if(self.tripOffer==nil){
        [dict setObject:[Utilities formatAmount:[self.trip.trip_fare floatValue]] forKey:@"user_offer_amt"];
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:API_UPDATE_OFFER
                  d:dict
              cb:^(id results, NSError *error) {
        [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            SocketHelperSwift * socketHelper = [APP_DELEGATE getSockethelperSwift];
            if([socketHelper isConnected]){
                [socketHelper sendOfferToUserWithTrip:self.trip data:[results objectForKey:P_RESPONSE]];
//                [socketHelper disconnect];
            }else{
                [TripNotificationHelper sendNotificationToUser:TS_OFFER data:[results objectForKey:P_RESPONSE] trip:self.trip];
            }
            [self.delegate view:self onCloseTripRequest:self.trip];
            [self.delegate showAlertForOfferSent:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_45_s4_ofr_sent"]];
        }
        else  if (error != nil) {
            [self.delegate handleErrorApi:error];
            [self.delegate view:self onCloseTripRequest:self.trip];
        }
    }];
}

-(NSString *) getValueForKey:(NSString *) key lang:(NSString*)lang{
    return [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:lang];
}
-(void)sendNotification:(NSString *)status data:(NSDictionary *) data trip:(TripModel *) trip{
    NSString *message;
    if ( [status isEqualToString:TS_OFFER] ) {
        message = [self getValueForKey:@"k_2_s14_trip_offer" lang:trip.user.u_language];
    }
    else if ( [status isEqualToString:TS_DRIVER_CANCEL_AT_DROP] ) {
        message = [self getValueForKey:@"k_2_s14_trip_conplete" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP]){
        message =[self getValueForKey:@"k_5_s14_trip_cancelled_by_driver"  lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_ACCEPTED]){
        message = [self getValueForKey:@"k_1_s14_trip_confirm"  lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_ARRIVE]) {
        message = [self getValueForKey:@"k_3_s14_arrive_soon" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_END]){
        message = [self getValueForKey:@"k_2_s14_trip_conplete" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_BEGIN]){
        message = [self getValueForKey:@"k_4_s14_trip_started" lang:trip.user.u_language];
    }
    else if ([status isEqualToString:TS_REJECT])  {
        message = [self getValueForKey:@"k_10_s14_trip_request_rerject" lang:trip.user.u_language];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"message" :message, TRIP_STATUS  :status,TRIP_ID :self.trip.trip_Id, /*@"content-available":@"1"*/}];
    if([status isEqualToString:TS_ARRIVE]){
        [ dict  setObject:@"cab_arrive.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_BEGIN]){
        [ dict  setObject:@"vehicle_arrive_soon.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_REJECT]){
        [ dict  setObject:@"driver_cancelled.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_ACCEPTED]){
        [ dict  setObject:@"driver_accepted.caf" forKey:@"sound"];
    }
    else if([status isEqualToString:TS_END]){
        [ dict  setObject:@"trip_complete.caf" forKey:@"sound"];
    }
    if(self.trip.user.deviceToken!=nil) {
        if ([self.trip.user.deviceType isEqualToString:IOS]) {
            [dict setObject:self.trip.user.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:self.trip.user.deviceToken forKey:ANDROID_TOKEN];
        }
    }

    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:data options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    NSLog(@"%@",myString);

    [ dict  setObject:[NSString stringWithFormat:@"%d" ,self.trip.user.userId] forKey:P_USER_ID];
    [ dict  setObject:myString forKey:@"data"];
    if ([[dict objectForKey:IOS_TOKEN] length]==0  && [[dict objectForKey:ANDROID_TOKEN] length]==0) {
        return;
    }
    [dict setObject:@"user" forKey:@"to"];
    [GIC mk:url_notification to:send_user_notification
                  d:dict
      isa:NO
                    cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
        }
    }];
}

-(void)checkAndHideRequestView:(NSNotification *)notification{
    NSDictionary * dict = notification.userInfo;
    NSDictionary * aps = [notification.userInfo objectForKey:@"aps"];
    
    if([[aps objectForKey:@"trip_status" ] isEqualToString:@"declined"]){
        NSString * tripId = [aps objectForKey:@"trip_id" ];
        if([self.trip.trip_Id isEqualToString:tripId]){
            [self.delegate view:self onCloseTripRequest:self.trip];
            [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"]];
        }
    }
}


/**
 Las tres tarifas rapidas, calcadas de Android.

 Antes eran cuatro y salian de los porcentajes: minimo, medio minimo, medio maximo y maximo.
 Android las cambio a tres importes FIJOS con paso de 0,50 -- una a la baja y dos al alza --
 porque el porcentaje da cifras raras que nadie quiere pulsar, mientras que "medio dolar
 menos" es una decision inmediata. La de abajo es la que permite rebajar para ganar el viaje.

 Los limites del servidor se siguen respetando: se recorta lo que se salga, y nunca queda un
 importe de cero o negativo.
 */
- (float)ofertaRapidaNumero:(NSInteger)cual {
    float minimo = 0, maximo = 0;
    [self limitesDeLaOferta:&minimo maximo:&maximo paso:NULL];
    float tarifa = [self.trip.base_est_amt floatValue];

    float importe;
    if (cual <= 1) {
        importe = tarifa - kPasoDeOfertaRapida;
        if (minimo > 0 && importe < minimo) {
            importe = minimo;
        }
    } else if (cual == 2) {
        importe = tarifa + kPasoDeOfertaRapida;
    } else {
        importe = tarifa + (kPasoDeOfertaRapida * 2.0f);
    }
    if (maximo > tarifa && importe > maximo) {
        importe = maximo;
    }
    return importe < 0.01f ? 0.01f : importe;
}

- (IBAction)onNewOffer:(UIButton *)sender {
    [self updateOfferForTrip:[self ofertaRapidaNumero:sender.tag]];
}

/**
 Los limites y el paso de la oferta, calculados como en Android (setTripDetails).

 EL FALLO QUE ARREGLA. min_offer_perc y max_offer_perc valen -1 POR DEFECTO en CategoryModel,
 y aqui no se comprobaba. Con -1 las cuentas se dan la vuelta:

     maximo = tarifa + (tarifa * -1)/100 = tarifa * 0,99
     minimo = tarifa - (tarifa * -1)/100 = tarifa * 1,01

 O sea el minimo por ENCIMA del maximo. El boton de mas se pasaba del maximo al primer toque
 y el de menos bajaba del minimo: los dos saltaban con su alerta y la oferta no se movia. El
 conductor no podia ofertar nada. Android lo comprueba explicitamente
 (`if (minOff != -1 && maxOff != -1)`) y cae a los mismos respaldos que se usan aqui: sin
 minimo util, y un maximo de cinco veces la tarifa.

 EL PASO. Android lo lee de la constante offer_step_amount y lo divide entre diez, con 0,5
 de respaldo -- o sea 0,05. Se calca tal cual: si el panel cambia el paso, las dos apps
 cambian a la vez. iOS lo tenia clavado en `redondeo(tarifa * 0,05)` con suelo de 0,25, que
 ni salia del backend ni coincidia con Android.
 */
- (void)limitesDeLaOferta:(float *)minimo maximo:(float *)maximo paso:(float *)paso {
    CategoryModel *categoria = [CategoryModel getCategoryByid:[self.trip.category_id intValue]];
    float tarifa = [self.trip.base_est_amt floatValue];

    float porcMin = categoria ? categoria.min_offer_perc : -1;
    float porcMax = categoria ? categoria.max_offer_perc : -1;
    BOOL hayPorcentajes = (porcMin > -1 && porcMax > -1);

    if (minimo) {
        *minimo = hayPorcentajes ? (tarifa - (tarifa * porcMin) / 100.0f) : 0.0f;
        if (*minimo < 0.01f) {
            *minimo = 0.01f;
        }
    }
    if (maximo) {
        *maximo = hayPorcentajes ? (tarifa + (tarifa * porcMax) / 100.0f) : (tarifa * 5.0f);
    }
    if (paso) {
        NSString *crudo = [[ConstantModel valorDeConstantePorClave:@"offer_step_amount"]
                           stringByReplacingOccurrencesOfString:@"," withString:@"."];
        float valor = [crudo floatValue];
        if (valor <= 0) {
            valor = 0.5f;
        }
        *paso = valor / 10.0f;
    }
}

- (IBAction)onPlusButtonTap:(id)sender {
    float minimo = 0, maximo = 0, paso = 0;
    [self limitesDeLaOferta:&minimo maximo:&maximo paso:&paso];
    CityModel *cityModel = [CityModel getCityByCityId:self.trip.city_id];
    float nuevo = [self.txtOfferAmt.text floatValue] + paso;
    if (nuevo <= maximo) {
        self.txtOfferAmt.text = [Utilities formatAmount:nuevo];
        [self updateOfferAmountOnButton:nuevo cur:isEmpty(cityModel.city_cur)];
    } else {
        self.txtOfferAmt.text = [Utilities formatAmount:maximo];
        [self updateOfferAmountOnButton:maximo cur:isEmpty(cityModel.city_cur)];
        [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_r1_s6_pls_ntr_amnt_less_thn_max_fare"]];
    }
}

- (IBAction)onMinButtonTap:(id)sender {
    float minimo = 0, maximo = 0, paso = 0;
    [self limitesDeLaOferta:&minimo maximo:&maximo paso:&paso];
    CityModel *cityModel = [CityModel getCityByCityId:self.trip.city_id];
    float nuevo = [self.txtOfferAmt.text floatValue] - paso;
    if (nuevo >= minimo) {
        self.txtOfferAmt.text = [Utilities formatAmount:nuevo];
        [self updateOfferAmountOnButton:nuevo cur:isEmpty(cityModel.city_cur)];
    } else {
        self.txtOfferAmt.text = [Utilities formatAmount:minimo];
        [self updateOfferAmountOnButton:minimo cur:isEmpty(cityModel.city_cur)];
        [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_r1_s6_pls_ntr_amnt_grtr_thn_min_fare"]];
    }
}

    -(void) updateOfferAmountOnButton:(float) offerAmount cur:(NSString *)cur{
        NSString *formatted = [Utilities formatAmountAndCurrency:offerAmount currency:cur];
        NSString *btnTitle  = [NSString stringWithFormat:@"Enviar Oferta (%@)", formatted];
        [self.btnOffer3 setTitle:btnTitle forState:UIControlStateNormal];
        _ndOfferAmountLbl.text = formatted;
        [_ndSendOfferBtn setTitle:btnTitle forState:UIControlStateNormal];
        if(offerAmount==[self.trip.base_est_amt floatValue]){
            self.btnOffer3.enabled=NO;
            [self.btnOffer3 setBackgroundColor:[UIColor grayColor]];
            _ndSendOfferBtn.enabled = NO;
            _ndSendOfferBtn.alpha   = 0.5;
        }else{
            self.btnOffer3.enabled=YES;
            [self.btnOffer3 setBackgroundColor:[UIColor colorNamed:@"app_theame"]];
            _ndSendOfferBtn.enabled = YES;
            _ndSendOfferBtn.alpha   = 1.0;
        }
    }


#pragma mark - New Design


/**
 La pantalla de solicitud, calcada de activity_trip_request_detail.xml.

 LO QUE ESTABA MAL, comparando las dos capturas lado a lado:

   - El mapa se estiraba hasta la barra inferior y la hoja lo tapaba casi entero, asi que
     quedaba una franja gris sin nada. En Android ocupa del borde SUPERIOR al 45% de la
     pantalla, sin banda blanca encima: el titulo flota sobre el mapa.
   - Las etiquetas iban en una tarjeta blanca ENCIMA de la del pasajero. En Android son
     chips amarillos DEBAJO.
   - Habia un acordeon "Negociar Tarifa" con paso, mas un boton "Enviar Oferta" que quedaba
     cortado por la barra inferior. En Android todo eso es vestigial: en el XML esos
     elementos estan a 0dp y visibility="gone". Lo que se ve es el rotulo "OFRECER OTRA
     TARIFA" y tres botones amarillos.
   - Abajo habia dos botones, "Quitar" y "Aceptar", pequeños y de colores palidos. En
     Android hay UNO, verde y ancho, con su tilde: "ACEPTAR $X". Para rechazar esta la X.
   - Los extremos de la ruta eran iconos de pin. En Android son circulos con A y B.

 El contenido de la hoja va en un scroll a proposito: en pantallas cortas no cabe entero, y
 sin scroll lo ultimo queda debajo de la barra -- que es exactamente lo que le pasaba al
 boton de enviar oferta.
 */
- (void)setupNewDesign {
    // Pull out loading overlay before hiding everything
    UIView *loadingOverlay = self.viewLoadingReequestData;
    [loadingOverlay removeFromSuperview];

    for (UIView *v in self.subviews) { v.hidden = YES; }
    self.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f];

    CGFloat topSafe = 0, bottomSafe = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *win = UIApplication.sharedApplication.windows.firstObject;
        topSafe    = win.safeAreaInsets.top;
        bottomSafe = win.safeAreaInsets.bottom;
    }
    CGFloat W = SCREEN_WIDTH;
    CGFloat H = SCREEN_HEIGHT;

    UIColor *amarillo = [UIColor colorWithRed:0.98f green:0.75f blue:0.10f alpha:1.0f];
    UIColor *oscuro   = [UIColor colorWithRed:0.10f green:0.10f blue:0.10f alpha:1.0f];
    UIColor *gris     = [UIColor colorWithRed:0.50f green:0.50f blue:0.50f alpha:1.0f];
    UIColor *verde    = [UIColor colorWithRed:0.16f green:0.74f blue:0.31f alpha:1.0f];

    // ------------------------------------------------------------- El mapa, a sangre
    // Del borde de arriba al 45% de la pantalla, como guideline_map en Android.
    CGFloat mapH = H * 0.45f;
    _ndMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, W, mapH)];
    _ndMapView.delegate = self;
    _ndMapView.showsUserLocation = YES;
    _ndMapView.showsBuildings = NO;
    if (@available(iOS 11.0, *)) { _ndMapView.mapType = MKMapTypeMutedStandard; }
    self.mapView = _ndMapView;   // el resto de la logica ya apunta a este
    [self addSubview:_ndMapView];

    AppDelegate *appDel = APP_DELEGATE;
    driverPin = [[MKPointAnnotation alloc] init];
    driverPin.coordinate = appDel.currLoc.coordinate;
    [_ndMapView addAnnotation:driverPin];
    if ([Utilities isValidLocation:appDel.currLoc.coordinate]) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(appDel.currLoc.coordinate, 1500, 1500);
        [self mapRegion:region mapView:_ndMapView];
    }

    // El titulo y la X flotan SOBRE el mapa, sin banda blanca: es lo que hace Android.
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(56, topSafe + 8, W - 112, 30)];
    titleLbl.text = @"Solicitud de Viaje";
    titleLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:19] ?: [UIFont boldSystemFontOfSize:19];
    titleLbl.textColor = oscuro;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLbl];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(W - 52, topSafe + 4, 40, 40);
    if (@available(iOS 13.0, *)) {
        [closeBtn setImage:[[UIImage systemImageNamed:@"xmark"]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                  forState:UIControlStateNormal];
        closeBtn.tintColor = [UIColor colorWithRed:0.35f green:0.35f blue:0.35f alpha:1.0f];
    } else {
        [closeBtn setTitle:@"X" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor colorWithRed:0.35f green:0.35f blue:0.35f alpha:1.0f] forState:UIControlStateNormal];
    }
    [closeBtn addTarget:self action:@selector(onRejectButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];

    _ndChipRecogida = [self ndChipConFondo:[UIColor whiteColor] texto:verde];
    _ndChipViaje    = [self ndChipConFondo:amarillo texto:oscuro];
    [_ndMapView addSubview:_ndChipRecogida];
    [_ndMapView addSubview:_ndChipViaje];

    // ------------------------------------------------------------- Lo de abajo, fijo
    CGFloat pad = 16.0f;
    CGFloat altoAceptar = 64.0f;
    CGFloat altoBarra = 4.0f;
    CGFloat altoPie = altoBarra + 10.0f + altoAceptar + 12.0f + bottomSafe;
    CGFloat pieY = H - altoPie;

    UIView *pie = [[UIView alloc] initWithFrame:CGRectMake(0, pieY, W, altoPie)];
    pie.backgroundColor = [UIColor whiteColor];
    [self addSubview:pie];

    UIView *pista = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, altoBarra)];
    pista.backgroundColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.0f];
    [pie addSubview:pista];

    _ndProgressFillView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, altoBarra)];
    _ndProgressFillView.backgroundColor = [UIColor colorWithRed:0.90f green:0.20f blue:0.20f alpha:1.0f];
    [pista addSubview:_ndProgressFillView];

    _ndAceptarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _ndAceptarBtn.frame = CGRectMake(pad, altoBarra + 10.0f, W - pad * 2, altoAceptar);
    _ndAceptarBtn.backgroundColor = verde;
    _ndAceptarBtn.layer.cornerRadius = 14;
    [_ndAceptarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _ndAceptarBtn.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:18] ?: [UIFont boldSystemFontOfSize:18];
    _ndAceptarBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _ndAceptarBtn.titleLabel.minimumScaleFactor = 0.7f;
    if (@available(iOS 13.0, *)) {
        [_ndAceptarBtn setImage:[[UIImage systemImageNamed:@"checkmark"]
                                 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                       forState:UIControlStateNormal];
        _ndAceptarBtn.tintColor = [UIColor whiteColor];
        _ndAceptarBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    }
    [_ndAceptarBtn setTitle:@"ACEPTAR" forState:UIControlStateNormal];
    [_ndAceptarBtn addTarget:self action:@selector(onAcceptButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [pie addSubview:_ndAceptarBtn];

    // "Quitar" desaparece: en Android se rechaza con la X de arriba, que aqui hace lo mismo.
    _ndQuitarBtn = nil;

    // ------------------------------------------------------------- La hoja
    CGFloat hojaY = mapH - 18.0f;
    UIView *sheet = [[UIView alloc] initWithFrame:CGRectMake(0, hojaY, W, pieY - hojaY)];
    sheet.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.0f];
    sheet.layer.cornerRadius = 22;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    sheet.clipsToBounds = YES;
    [self addSubview:sheet];

    UIScrollView *lienzo = [[UIScrollView alloc] initWithFrame:sheet.bounds];
    lienzo.showsVerticalScrollIndicator = NO;
    [sheet addSubview:lienzo];

    CGFloat mx = pad, cw = W - pad * 2, sp = 10.0f;
    CGFloat y = 16.0f;

    // --- Pasajero
    CGFloat riderH = 96.0f;
    UIView *riderCard = [self ndMakeCard:CGRectMake(mx, y, cw, riderH)];
    [lienzo addSubview:riderCard];

    _ndRiderAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(12, 13, 52, 52)];
    _ndRiderAvatar.layer.cornerRadius = 26;
    _ndRiderAvatar.clipsToBounds = YES;
    _ndRiderAvatar.contentMode = UIViewContentModeScaleAspectFill;
    _ndRiderAvatar.backgroundColor = [UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.0f];
    [riderCard addSubview:_ndRiderAvatar];

    _ndSelloVerificado = [[UIImageView alloc] initWithFrame:CGRectMake(48, 49, 20, 20)];
    _ndSelloVerificado.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 13.0, *)) {
        _ndSelloVerificado.image = [[UIImage systemImageNamed:@"checkmark.seal.fill"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _ndSelloVerificado.tintColor = [UIColor colorWithRed:0.11f green:0.51f blue:0.95f alpha:1.0f];
    }
    _ndSelloVerificado.hidden = YES;
    [riderCard addSubview:_ndSelloVerificado];

    _ndRiderNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(76, 12, cw - 76 - 92, 22)];
    _ndRiderNameLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:16] ?: [UIFont boldSystemFontOfSize:16];
    _ndRiderNameLbl.textColor = oscuro;
    [riderCard addSubview:_ndRiderNameLbl];

    _ndRiderRatingLbl = [[UILabel alloc] initWithFrame:CGRectMake(76, 36, cw - 76 - 92, 18)];
    _ndRiderRatingLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:13] ?: [UIFont systemFontOfSize:13];
    _ndRiderRatingLbl.textColor = gris;
    [riderCard addSubview:_ndRiderRatingLbl];

    _ndDistanciaAlPasajero = [[UILabel alloc] initWithFrame:CGRectMake(76, 58, cw - 76 - 92, 20)];
    _ndDistanciaAlPasajero.font = [UIFont fontWithName:@"NotoSans-Bold" size:14] ?: [UIFont boldSystemFontOfSize:14];
    _ndDistanciaAlPasajero.textColor = verde;
    _ndDistanciaAlPasajero.adjustsFontSizeToFitWidth = YES;
    _ndDistanciaAlPasajero.minimumScaleFactor = 0.8f;
    [riderCard addSubview:_ndDistanciaAlPasajero];

    _ndFareLbl = [[UILabel alloc] initWithFrame:CGRectMake(cw - 88, 20, 80, 34)];
    _ndFareLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:22] ?: [UIFont boldSystemFontOfSize:22];
    _ndFareLbl.textColor = oscuro;
    _ndFareLbl.textAlignment = NSTextAlignmentRight;
    _ndFareLbl.adjustsFontSizeToFitWidth = YES;
    _ndFareLbl.minimumScaleFactor = 0.6f;
    [riderCard addSubview:_ndFareLbl];
    y += riderH + sp;

    // --- Los chips amarillos, DEBAJO del pasajero y no encima
    _ndTagsCard = [[UIView alloc] initWithFrame:CGRectMake(mx, y, cw, 44)];
    _ndTagsCard.backgroundColor = [UIColor clearColor];
    [lienzo addSubview:_ndTagsCard];
    y += 44 + sp;

    // --- Ruta, con los circulos A y B
    CGFloat routeH = 112.0f;
    UIView *routeCard = [self ndMakeCard:CGRectMake(mx, y, cw, routeH)];
    [lienzo addSubview:routeCard];

    CGFloat dotX = 14.0f, dotSz = 28.0f;
    CGFloat row1CY = routeH / 4.0f + 4;
    CGFloat row2CY = routeH * 3.0f / 4.0f - 4;

    UILabel *circuloA = [self ndCirculoConLetra:@"A"
                                          fondo:[UIColor colorWithRed:0.13f green:0.42f blue:0.93f alpha:1.0f]
                                          marco:CGRectMake(dotX, row1CY - dotSz/2, dotSz, dotSz)];
    [routeCard addSubview:circuloA];
    UILabel *circuloB = [self ndCirculoConLetra:@"B" fondo:verde
                                          marco:CGRectMake(dotX, row2CY - dotSz/2, dotSz, dotSz)];
    [routeCard addSubview:circuloB];

    CAShapeLayer *dash = [CAShapeLayer layer];
    dash.strokeColor     = [UIColor colorWithRed:0.75f green:0.75f blue:0.75f alpha:1.0f].CGColor;
    dash.lineWidth       = 1.5f;
    dash.lineDashPattern = @[@4, @4];
    dash.fillColor       = [UIColor clearColor].CGColor;
    UIBezierPath *bp = [UIBezierPath bezierPath];
    CGFloat cx = dotX + dotSz / 2.0f;
    [bp moveToPoint:CGPointMake(cx, row1CY + dotSz / 2.0f + 3)];
    [bp addLineToPoint:CGPointMake(cx, row2CY - dotSz / 2.0f - 3)];
    dash.path = bp.CGPath;
    [routeCard.layer addSublayer:dash];

    CGFloat anchoCifra = 66.0f;
    CGFloat textX = dotX + dotSz + 10.0f, textW = cw - textX - 10.0f - anchoCifra;

    _ndPickupPrimaryLbl = [[UILabel alloc] initWithFrame:CGRectMake(textX, row1CY - 18, textW, 19)];
    _ndPickupPrimaryLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:14] ?: [UIFont boldSystemFontOfSize:14];
    _ndPickupPrimaryLbl.textColor = oscuro;
    [routeCard addSubview:_ndPickupPrimaryLbl];

    _ndPickupSecondaryLbl = [[UILabel alloc] initWithFrame:CGRectMake(textX, row1CY + 2, textW, 16)];
    _ndPickupSecondaryLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:11] ?: [UIFont systemFontOfSize:11];
    _ndPickupSecondaryLbl.textColor = gris;
    [routeCard addSubview:_ndPickupSecondaryLbl];

    _ndDropPrimaryLbl = [[UILabel alloc] initWithFrame:CGRectMake(textX, row2CY - 18, textW, 19)];
    _ndDropPrimaryLbl.font = [UIFont fontWithName:@"NotoSans-Bold" size:14] ?: [UIFont boldSystemFontOfSize:14];
    _ndDropPrimaryLbl.textColor = oscuro;
    [routeCard addSubview:_ndDropPrimaryLbl];

    _ndDropSecondaryLbl = [[UILabel alloc] initWithFrame:CGRectMake(textX, row2CY + 2, textW, 16)];
    _ndDropSecondaryLbl.font = [UIFont fontWithName:@"NotoSans-Regular" size:11] ?: [UIFont systemFontOfSize:11];
    _ndDropSecondaryLbl.textColor = gris;
    [routeCard addSubview:_ndDropSecondaryLbl];

    _ndMinutosRecogida = [[UILabel alloc] initWithFrame:CGRectMake(cw - 10 - anchoCifra, row1CY - 9, anchoCifra, 18)];
    _ndMinutosRecogida.font = [UIFont fontWithName:@"NotoSans-Regular" size:12] ?: [UIFont systemFontOfSize:12];
    _ndMinutosRecogida.textColor = gris;
    _ndMinutosRecogida.textAlignment = NSTextAlignmentRight;
    [routeCard addSubview:_ndMinutosRecogida];

    _ndKmDelViaje = [[UILabel alloc] initWithFrame:CGRectMake(cw - 10 - anchoCifra, row2CY - 9, anchoCifra, 18)];
    _ndKmDelViaje.font = [UIFont fontWithName:@"NotoSans-Regular" size:12] ?: [UIFont systemFontOfSize:12];
    _ndKmDelViaje.textColor = gris;
    _ndKmDelViaje.textAlignment = NSTextAlignmentRight;
    [routeCard addSubview:_ndKmDelViaje];
    y += routeH + sp;

    // --- "OFRECER OTRA TARIFA" y las tres tarifas
    UILabel *rotuloOferta = [[UILabel alloc] initWithFrame:CGRectMake(mx, y, cw, 20)];
    rotuloOferta.text = @"OFRECER OTRA TARIFA";
    rotuloOferta.font = [UIFont fontWithName:@"NotoSans-Bold" size:12] ?: [UIFont boldSystemFontOfSize:12];
    rotuloOferta.textColor = gris;
    rotuloOferta.textAlignment = NSTextAlignmentCenter;
    [lienzo addSubview:rotuloOferta];
    y += 20 + 8;

    CGFloat anchoTarifa = (cw - 16.0f) / 3.0f;
    for (NSInteger i = 1; i <= 3; i++) {
        UIButton *rapida = [UIButton buttonWithType:UIButtonTypeCustom];
        rapida.tag = i;
        rapida.frame = CGRectMake(mx + (anchoTarifa + 8.0f) * (i - 1), y, anchoTarifa, 56);
        rapida.backgroundColor = amarillo;
        rapida.layer.cornerRadius = 14;
        [rapida setTitleColor:oscuro forState:UIControlStateNormal];
        rapida.titleLabel.font = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
        rapida.titleLabel.adjustsFontSizeToFitWidth = YES;
        rapida.titleLabel.minimumScaleFactor = 0.65f;
        [rapida addTarget:self action:@selector(onNewOffer:) forControlEvents:UIControlEventTouchUpInside];
        [lienzo addSubview:rapida];
        _ndOfertasRapidas[i - 1] = rapida;
    }
    y += 56 + 16;

    /*
     El importe editable no se pinta, igual que en Android: alli tvOfferYourAmount,
     tvOfferDecrease, tvOfferIncrease y tvSendOfferStepper estan a 0dp y visibility="gone".
     Se dejan creados pero ocultos porque updateOfferAmountOnButton escribe en ellos, y
     encontrarlos nulos seria peor que tenerlos invisibles.
     */
    _ndOfferAmountLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    _ndOfferAmountLbl.hidden = YES;
    [lienzo addSubview:_ndOfferAmountLbl];
    _ndSendOfferBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _ndSendOfferBtn.frame = CGRectZero;
    _ndSendOfferBtn.hidden = YES;
    [lienzo addSubview:_ndSendOfferBtn];

    lienzo.contentSize = CGSizeMake(W, y);

    if (loadingOverlay) {
        loadingOverlay.hidden = YES;
        loadingOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        loadingOverlay.frame = CGRectMake(0, 0, W, H);
        [self addSubview:loadingOverlay];
    }
    self.viewProgress.alpha = 0;
}

/** Un circulo con una letra dentro, como bg_circle_pickup / bg_circle_drop en Android. */
- (UILabel *)ndCirculoConLetra:(NSString *)letra fondo:(UIColor *)fondo marco:(CGRect)marco {
    UILabel *circulo = [[UILabel alloc] initWithFrame:marco];
    circulo.text = letra;
    circulo.textAlignment = NSTextAlignmentCenter;
    circulo.textColor = [UIColor whiteColor];
    circulo.font = [UIFont fontWithName:@"NotoSans-Bold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    circulo.backgroundColor = fondo;
    circulo.layer.cornerRadius = CGRectGetWidth(marco) / 2.0f;
    circulo.clipsToBounds = YES;
    return circulo;
}

- (UIView *)ndMakeCard:(CGRect)frame {
    UIView *card = [[UIView alloc] initWithFrame:frame];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius  = 12;
    card.layer.shadowColor   = [UIColor blackColor].CGColor;
    card.layer.shadowOffset  = CGSizeMake(0, 2);
    card.layer.shadowRadius  = 5;
    card.layer.shadowOpacity = 0.07f;
    return card;
}


- (IBAction)onSendOfferTap:(id)sender {
    [self onOfferButtonTap:self.btnOffer3];
}

- (void)ndRefreshUI {
    if (!self.trip || !_ndMapView) return;
    CityModel *city = [CityModel getCityByCityId:self.trip.city_id];
    NSString  *cur  = isEmpty(city.city_cur);

    // Los rotulos de las tres tarifas rapidas, que solo se pueden poner una vez se sabe la
    // tarifa del viaje. Si dos salen iguales -- pasa cuando el tope del servidor recorta las
    // dos de arriba al mismo numero -- la repetida se apaga en vez de ofrecer lo mismo dos
    // veces, que confunde y no aporta.
    float anterior = -1;
    for (NSInteger i = 1; i <= 3; i++) {
        UIButton *rapida = _ndOfertasRapidas[i - 1];
        if (rapida == nil) continue;
        float importe = [self ofertaRapidaNumero:i];
        BOOL repetida = (i > 1 && fabsf(importe - anterior) < 0.005f);
        [rapida setTitle:[Utilities formatAmountAndCurrency:importe currency:cur]
                forState:UIControlStateNormal];
        rapida.hidden  = repetida;
        rapida.enabled = !repetida;
        anterior = importe;
    }

    // Rider info
    UserModel *user = self.trip.user;
    if (user) {
        NSString *name = user.u_name.length > 0
            ? user.u_name
            : [NSString stringWithFormat:@"%@ %@", isEmpty(user.u_fname), isEmpty(user.u_lname)];
        _ndRiderNameLbl.text = name;

        if (user.rating > 0) {
            NSMutableAttributedString *ratingStr = [[NSMutableAttributedString alloc] init];
            UIImage *starImg = [UIImage imageNamed:@"ic_star"];
            if (starImg) {
                NSTextAttachment *attach = [[NSTextAttachment alloc] init];
                attach.image = starImg;
                CGFloat sz = _ndRiderRatingLbl.font.capHeight + 2;
                attach.bounds = CGRectMake(0, -2, sz, sz);
                [ratingStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
                [ratingStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            }
            // Solo la valoracion, como tvPassengerRating en Android: "5,0 (5)". Las distancias
            // tienen sus propios sitios -- el renglon verde y las cifras junto a cada
            // direccion -- en vez de ir todas apretadas en esta linea.
            NSString *ratingText = [NSString stringWithFormat:@"%.1f (%d)",
                                    user.rating, user.rating_count];
            [ratingStr appendAttributedString:[[NSAttributedString alloc] initWithString:ratingText attributes:@{NSFontAttributeName: _ndRiderRatingLbl.font, NSForegroundColorAttributeName: _ndRiderRatingLbl.textColor}]];
            _ndRiderRatingLbl.attributedText = ratingStr;
        } else {
            _ndRiderRatingLbl.text = @"";
        }

        /*
         Las distancias, con las MISMAS formulas que Android (TripRequestActivity.setTripDetails):

           tvDistanceToPassenger  "Recogida a %.1f km de ti"   o "Recogida muy cerca de ti"
           tvPickupEta            "%d min"                      con min = redondeo(km x 3)
           tvMapPickupBadge       "Recogida %d min"
           tvDropDistance         "%s Km"                       la distancia del viaje, del servidor
           tvMapTripBadge         "Viaje %d min - %s Km"

         Los tres minutos por kilometro no son una estimacion fina, pero son los MISMOS en las
         dos apps: para comparar vale mas eso que acertar en una sola.
         */
        CLLocationCoordinate2D dondeEstoy = [APP_DELEGATE currLoc].coordinate;
        CLLocationCoordinate2D laRecogida = CLLocationCoordinate2DMake([self.trip.trip_pick_lat doubleValue],
                                                                      [self.trip.trip_pick_long doubleValue]);
        ConrraMedidaDeRuta *medida = [ConrraRutaDeRecogida consultarDesde:dondeEstoy hasta:laRecogida];
        double kmRecogida = -1;
        if (medida != nil) {
            kmRecogida = medida.km;
        } else if (CLLocationCoordinate2DIsValid(dondeEstoy) && CLLocationCoordinate2DIsValid(laRecogida) &&
                   !(laRecogida.latitude == 0 && laRecogida.longitude == 0)) {
            CLLocation *a = [[CLLocation alloc] initWithLatitude:dondeEstoy.latitude longitude:dondeEstoy.longitude];
            CLLocation *b = [[CLLocation alloc] initWithLatitude:laRecogida.latitude longitude:laRecogida.longitude];
            kmRecogida = [a distanceFromLocation:b] / 1000.0;
        }

        if (kmRecogida >= 0) {
            NSInteger minutos = medida != nil ? medida.minutos : [self ndMinutosPara:kmRecogida];
            _ndDistanciaAlPasajero.text = [NSString stringWithFormat:@"Recogida a %.1f km de ti", kmRecogida];
            _ndMinutosRecogida.text = [NSString stringWithFormat:@"%ld min", (long)minutos];
            [self ndColocarChip:_ndChipRecogida
                          texto:[NSString stringWithFormat:@"Recogida %ld min", (long)minutos]
                     aLaDerecha:YES arriba:YES];
        } else {
            // Android dice esto mismo cuando no puede medir: es mas util que un hueco en blanco.
            _ndDistanciaAlPasajero.text = @"Recogida muy cerca de ti";
            _ndMinutosRecogida.text = @"";
            _ndChipRecogida.hidden = YES;
        }

        NSString *kmViaje = [isEmpty(self.trip.trip_distance) stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (kmViaje.length > 0 && [kmViaje caseInsensitiveCompare:@"null"] != NSOrderedSame) {
            _ndKmDelViaje.text = [NSString stringWithFormat:@"%@ Km", kmViaje];
            NSInteger minViaje = [self ndMinutosPara:[kmViaje doubleValue]];
            [self ndColocarChip:_ndChipViaje
                          texto:[NSString stringWithFormat:@"Viaje %ld min - %@ Km", (long)minViaje, kmViaje]
                     aLaDerecha:NO arriba:NO];
        } else {
            _ndKmDelViaje.text = @"";
            _ndChipViaje.hidden = YES;
        }

        // El sello azul solo si el pasajero esta verificado, como ivVerifiedBadge.
        _ndSelloVerificado.hidden = !user.is_verified;

        if (user.u_profile_image_path.length > 0) {
            // u_profile_image_path es una ruta RELATIVA. Sin url_base_images delante, el NSURL
            // sale invalido y la foto nunca carga: por eso salia el circulo gris vacio. Las
            // demas pantallas ya lo hacian bien; esta no.
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url_base_images, user.u_profile_image_path]];
            [[SDWebImageManager sharedManager] loadImageWithURL:url options:0 progress:nil
                completed:^(UIImage *image, NSData *data, NSError *err, SDImageCacheType ct, BOOL fin, NSURL *u) {
                    if (image) dispatch_async(dispatch_get_main_queue(), ^{ self->_ndRiderAvatar.image = image; });
                }];
        }
    }

    // Fare + accept button
    NSString *fareStr = [NSString stringWithFormat:@"%.1f%@", [self.trip.trip_fare floatValue], isEmpty(cur)];
    _ndFareLbl.text = fareStr;
    // "ACEPTAR $2.40", en mayusculas y con el importe, como btnAccept en Android. El
    // conductor tiene que ver cuanto acepta sin levantar la vista al otro extremo de la
    // tarjeta.
    [_ndAceptarBtn setTitle:[NSString stringWithFormat:@"ACEPTAR %@", fareStr] forState:UIControlStateNormal];

    // Route addresses
    NSArray *pickParts = [self ndSplitAddress:isEmpty(self.trip.trip_pick_loc)];
    NSArray *dropParts = [self ndSplitAddress:isEmpty(self.trip.trip_drop_loc)];
    _ndPickupPrimaryLbl.text   = pickParts[0];
    _ndPickupSecondaryLbl.text = pickParts[1];
    _ndDropPrimaryLbl.text     = dropParts[0];
    _ndDropSecondaryLbl.text   = dropParts[1];

    // Tags
    [self ndBuildTags];

    // Offer amount (initial value)
    CategoryModel *cat = [CategoryModel getCategoryByid:[self.trip.category_id intValue]];
    float initialAmt = (cat && [self.trip.base_est_amt floatValue] > 0)
        ? [self.trip.base_est_amt floatValue]
        : [self.trip.trip_fare floatValue];
    [self updateOfferAmountOnButton:initialAmt cur:cur];
}

- (NSArray<NSString *> *)ndSplitAddress:(NSString *)addr {
    if (!addr.length) return @[@"", @""];
    NSRange comma = [addr rangeOfString:@","];
    if (comma.location != NSNotFound) {
        NSString *primary   = [addr substringToIndex:comma.location];
        NSString *secondary = [[addr substringFromIndex:comma.location + 1]
                               stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        return @[primary, secondary];
    }
    return @[addr, @""];
}

/** Un rotulo flotante sobre el mapa, con el mismo relleno que el de Android (14 x 10). */
- (UILabel *)ndChipConFondo:(UIColor *)fondo texto:(UIColor *)colorTexto {
    UILabel *chip = [[UILabel alloc] initWithFrame:CGRectZero];
    chip.backgroundColor = fondo;
    chip.textColor = colorTexto;
    chip.font = [UIFont fontWithName:@"NotoSans-Bold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    chip.textAlignment = NSTextAlignmentCenter;
    chip.layer.cornerRadius = 16;
    chip.clipsToBounds = YES;
    chip.layer.shadowColor = [UIColor blackColor].CGColor;
    chip.layer.shadowOpacity = 0.12f;
    chip.layer.shadowOffset = CGSizeMake(0, 1);
    chip.layer.shadowRadius = 3;
    chip.hidden = YES;
    return chip;
}

/** Coloca un chip con su ancho justo, dentro del mapa. */
- (void)ndColocarChip:(UILabel *)chip texto:(NSString *)texto aLaDerecha:(BOOL)aLaDerecha arriba:(BOOL)arriba {
    if (chip == nil) {
        return;
    }
    if (texto.length == 0) {
        chip.hidden = YES;
        return;
    }
    chip.text = texto;
    chip.hidden = NO;
    CGSize medida = [chip sizeThatFits:CGSizeMake(CGRectGetWidth(_ndMapView.bounds) - 32, 40)];
    CGFloat ancho = MIN(medida.width + 28, CGRectGetWidth(_ndMapView.bounds) - 32);
    CGFloat alto = 34;
    CGFloat x = aLaDerecha ? (CGRectGetWidth(_ndMapView.bounds) - 12 - ancho) : 12;
    CGFloat y = arriba ? 12 : (CGRectGetHeight(_ndMapView.bounds) - 12 - alto);
    chip.frame = CGRectMake(x, y, ancho, alto);
    [_ndMapView bringSubviewToFront:chip];
}

/**
 Los minutos que se tarda en recorrer unos kilometros en ciudad.

 Tres por kilometro, que es el mismo criterio que usa Android en las dos cifras de esta
 pantalla. No es una estimacion fina, pero es la MISMA en las dos apps, que para comparar
 vale mas que ser preciso en una sola.
 */
- (NSInteger)ndMinutosPara:(double)km {
    NSInteger minutos = (NSInteger)round(km * 3.0);
    return minutos < 1 ? 1 : minutos;
}

- (void)ndBuildTags {
    for (UIView *v in _ndTagsCard.subviews) [v removeFromSuperview];

    NSMutableArray<NSDictionary *> *tags = [NSMutableArray array];

    NSString *notes = [self.trip.pickup_notes stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (notes.length > 0) {
        // Format: "PaymentMethod|PetOrDelivery|N Pasajero(s)|Time"
        NSArray<NSString *> *parts = [notes componentsSeparatedByString:@"|"];

        /*
         El metodo de pago, LEIDO de verdad.

         Aqui estaba clavado en "Paga en Efectivo" pasara lo que pasara: un viaje con billetera
         o con pago movil le decia al conductor que iba a cobrar en mano. Android lee esa misma
         parte y reparte (TripRequestActivity, sobre la linea 855), asi que en la misma
         solicitud una app decia una cosa y la otra, otra.

         Y si el metodo trae detalles entre corchetes -- "Cash [tengo 20$]" -- salen en su
         propia etiqueta, como tvCashDetailsBadge.
         */
        if (parts.count > 0) {
            NSString *modo = [parts[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            if (modo.length > 0) {
                NSString *soloModo = modo;
                NSString *detalles = @"";
                NSRange abre = [modo rangeOfString:@"["];
                NSRange cierra = [modo rangeOfString:@"]" options:NSBackwardsSearch];
                if (abre.location != NSNotFound && cierra.location != NSNotFound && cierra.location > abre.location) {
                    detalles = [modo substringWithRange:NSMakeRange(abre.location + 1,
                                                                    cierra.location - abre.location - 1)];
                    soloModo = [[modo substringToIndex:abre.location]
                                stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                }
                NSString *texto;
                NSString *icono = @"ic_trip_cash";
                if ([soloModo rangeOfString:@"Cash" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                    [soloModo rangeOfString:@"fectivo" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    texto = [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Paga en Efectivo"];
                } else if ([soloModo rangeOfString:@"Movil" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                           [soloModo rangeOfString:@"Móvil" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    texto = @"Pago Movil";
                    icono = @"ic_trip_person";
                } else if ([soloModo rangeOfString:@"Wallet" options:NSCaseInsensitiveSearch].location != NSNotFound ||
                           [soloModo rangeOfString:@"illetera" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    texto = @"Paga con Wallet";
                    icono = @"ic_trip_person";
                } else {
                    texto = soloModo;
                }
                [tags addObject:@{@"imageName": icono, @"text": texto}];
                if (detalles.length > 0) {
                    [tags addObject:@{@"imageName": @"ic_trip_cash", @"text": detalles}];
                }
            }
        }

        // Part 1: pet or delivery (skip if unrecognised)
        if (parts.count > 1) {
            NSString *sl = [parts[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].lowercaseString;
            if ([sl containsString:@"mascota"] || [sl containsString:@"pet"])
                [tags addObject:@{@"imageName": @"ic_trip_pet", @"text": @"Lleva Mascotas"}];
            else if ([sl containsString:@"delivery"])
                [tags addObject:@{@"imageName": @"ic_trip_delivery", @"text": @"Es un Delivery"}];
        }

        // Part 2: passenger count — extract the number, drop the word
        if (parts.count > 2) {
            NSString *pax = [parts[2] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            // El texto tal cual lo manda el servidor -- "1 Pasajero(s)" -- que es lo que pinta
            // tvPassengersBadge en Android. Reescribirlo a "1 Persona" hacia que la misma
            // solicitud se leyera distinta en cada telefono.
            if (pax.length > 0 && [pax intValue] > 0) {
                [tags addObject:@{@"imageName": @"ic_trip_person", @"text": pax}];
            }
        }
    } else {
        // Fallback: use trip_pay_mode + trip_customer_details
        if ([self.trip.trip_pay_mode isEqualToString:CASH_PAY] || self.trip.trip_pay_mode.length == 0) {
            [tags addObject:@{@"imageName": @"ic_trip_cash", @"text": [LanguageHelper getStringWithKey:@"k_r39_s9_cash" defaultValue:@"Paga en Efectivo"]}];
        } else if ([self.trip.trip_pay_mode isEqualToString:CARD]) {
            [tags addObject:@{@"icon": @"💳", @"text": @"Paga con Tarjeta"}];
        } else {
            [tags addObject:@{@"icon": @"💰", @"text": @"Paga con Wallet"}];
        }
        if (self.trip.trip_customer_details.length > 0) {
            NSData *d = [self.trip.trip_customer_details dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *det = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
            if ([det isKindOfClass:[NSDictionary class]]) {
                NSNumber *persons = det[@"persons"] ?: det[@"person_count"] ?: det[@"seats"];
                if ([persons intValue] > 1)
                    [tags addObject:@{@"imageName": @"ic_trip_person", @"text": [NSString stringWithFormat:@"+%d Personas", [persons intValue]]}];
                if ([det[@"is_pet"] boolValue] || [det[@"pets"] boolValue])
                    [tags addObject:@{@"imageName": @"ic_trip_pet", @"text": @"Lleva Mascotas"}];
                if ([det[@"is_delivery"] boolValue] || [det[@"delivery"] boolValue])
                    [tags addObject:@{@"imageName": @"ic_trip_delivery", @"text": @"Es un Delivery"}];
            }
        }
        if (self.trip.is_share)
            [tags addObject:@{@"icon": @"🤝", @"text": @"Viaje Compartido"}];
    }

    /*
     Chips AMARILLOS en fila, como layoutPayModeBadge y layoutPassengersBadge en Android.

     Eran etiquetas grises sueltas dentro de una tarjeta blanca, en dos filas de dos. En
     Android son pastillas amarillas de 44 de alto, una al lado de otra, y se leen de un
     vistazo: el metodo de pago es lo primero que el conductor mira despues del importe.

     Todos van en UNA fila repartiendo el ancho, con un tope de tres. La tarjeta mide 44
     fijos y lo que va debajo esta colocado contando con eso: si creciera a dos filas, se
     comeria la tarjeta de la ruta.
     */
    for (UIView *v in _ndTagsCard.subviews) { [v removeFromSuperview]; }

    NSUInteger cuantos = MIN(tags.count, 3u);
    if (cuantos == 0) {
        return;
    }

    UIColor *amarillo = [UIColor colorWithRed:0.98f green:0.75f blue:0.10f alpha:1.0f];
    UIColor *oscuro   = [UIColor colorWithRed:0.10f green:0.10f blue:0.10f alpha:1.0f];
    CGFloat anchoTotal = CGRectGetWidth(_ndTagsCard.frame);
    CGFloat hueco = 10.0f, altoChip = 44.0f;
    // Todos en UNA fila, repartiendo el ancho. La tarjeta mide 44 fijos y lo que va debajo
    // esta colocado contando con eso: si creciera, se comeria la tarjeta de la ruta.
    CGFloat anchoChip = (anchoTotal - hueco * (cuantos - 1)) / (CGFloat)cuantos;

    for (NSUInteger i = 0; i < cuantos; i++) {
        NSDictionary *tag = tags[i];
        UIView *chip = [[UIView alloc] initWithFrame:CGRectMake(i * (anchoChip + hueco), 0,
                                                                anchoChip, altoChip)];
        chip.backgroundColor = amarillo;
        chip.layer.cornerRadius = 12;
        chip.clipsToBounds = YES;
        [_ndTagsCard addSubview:chip];

        UILabel *texto = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, anchoChip - 16, altoChip)];
        texto.font = [UIFont fontWithName:@"NotoSans-Bold" size:14] ?: [UIFont boldSystemFontOfSize:14];
        texto.textColor = oscuro;
        texto.textAlignment = NSTextAlignmentCenter;
        texto.adjustsFontSizeToFitWidth = YES;
        texto.minimumScaleFactor = 0.65f;

        NSString *nombreIcono = tag[@"imageName"];
        UIImage *icono = nombreIcono.length > 0 ? [UIImage imageNamed:nombreIcono] : nil;
        if (icono) {
            NSMutableAttributedString *conIcono = [[NSMutableAttributedString alloc] init];
            NSTextAttachment *adjunto = [[NSTextAttachment alloc] init];
            adjunto.image = icono;
            CGFloat lado = texto.font.capHeight + 3;
            adjunto.bounds = CGRectMake(0, -2, lado, lado);
            [conIcono appendAttributedString:[NSAttributedString attributedStringWithAttachment:adjunto]];
            [conIcono appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
            [conIcono appendAttributedString:[[NSAttributedString alloc]
                initWithString:tag[@"text"] ?: @""
                    attributes:@{NSFontAttributeName: texto.font,
                                 NSForegroundColorAttributeName: oscuro}]];
            texto.attributedText = conIcono;
        } else if (tag[@"icon"]) {
            texto.text = [NSString stringWithFormat:@"%@  %@", tag[@"icon"], tag[@"text"] ?: @""];
        } else {
            texto.text = tag[@"text"] ?: @"";
        }
        [chip addSubview:texto];
    }
}

@end
