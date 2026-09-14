
//
//  PendingTripCell.m
//  Captain Sareeie
//
//  Created by Devineer on 08/05/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "UpcommingTripCell.h"
#import "WebCallConstants.h"
#import "UIImageView+WebCache.h"
#import <GIKit/GIKit.h>
#import <Conrra-Swift.h>
#import "Utilities.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "CategoryModel.h"
@implementation UpcommingTripCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.btAccept setClipsToBounds:YES];
    [self.lbTimeRemaining setHidden:YES];
    [self.btAccept.layer setCornerRadius:17];
    [self.btnPaymentStatus.layer setCornerRadius:17];
    [self setUIFields];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
     
}

-(void) setUIFields{
    self.lblPicupLocation.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    self.lblDropLocation.text = [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    [self.btnPessangeDetails setTitle: [LanguageHelper getStringWithKey:@"k_s3_passenger_details" defaultValue:@"Passenger Details"]   forState:UIControlStateNormal];
    [self.btAccept setTitle: [LanguageHelper getStringWithKey:@"k_1_s9_details"]   forState:UIControlStateNormal];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [self setUIFields ];
    self.isUpcommingRide = YES;
    [self.btAccept setHidden:NO];
    [self.lbTripPickupTime setHidden:YES];
    [self.lbTimeRemaining setHidden:YES];
    [self.btAccept setTitle:[LanguageHelper getStringWithKey:@"k_1_s9_details"] forState:UIControlStateNormal];
}


-(void)setdataWithTripModel:(TripModel *)tripModel{
    if ([tripModel.trip_Status isEqualToString:TS_REQUEST]) {
        self.viewAcceptRequest.hidden=NO;
    }
    CityModel *cityModel=[CityModel getCityByCityId:tripModel.city_id];
    self.lblFareEstmate.text=[NSString stringWithFormat:@"%@%@",[LanguageHelper getStringWithKey:@"k_1_s8_est"],[Utilities formatAmountAndCurrency:[tripModel.trip_fare floatValue] currency:cityModel.city_cur]];
    if([tripModel.trip_fare floatValue]==0){
        self.lblFareEstmate.hidden=YES;
    }
    BOOL isPrePaid = [tripModel.trip_pay_mode isEqualToString:CARD]&&tripModel.payment_card_id.length>0;
    if(isPrePaid){
        [self.btnPaymentStatus setTitle:[LanguageHelper getStringWithKey:@"k_4_s21_paid"] forState:(UIControlStateNormal)];
        self.btnPaymentStatus.backgroundColor = [UIColor colorNamed:@"color_trip_paid"];
    }else{
        [self.btnPaymentStatus setTitle:[LanguageHelper getStringWithKey:@"k_4_s21_not_paid"] forState:(UIControlStateNormal)];
        self.btnPaymentStatus.backgroundColor = [UIColor colorNamed:@"color_trip_not_paid"];
    }
    
    CategoryModel *cateModel=[CategoryModel getCategoryByid:[tripModel.category_id intValue]];
    //    cateModel.show_paymode=NO;
    if(cateModel)  {
        if(cateModel.show_paymode) {
            self.lblPaymentMode.text=[NSString stringWithFormat:@"%@ %@",[LanguageHelper getStringWithKey:@"k_1_s8_pay_via"],isEmpty(tripModel.trip_pay_mode)];
            [self.lblPaymentMode setConstraintConstant:17 forAttribute:NSLayoutAttributeHeight];
        }else{
            [self.lblPaymentMode setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        }
        if(cateModel.show_fare){
            [self.lblFareEstmate setConstraintConstant:17 forAttribute:NSLayoutAttributeHeight];
        }else{
            [self.lblFareEstmate setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        }
    }else{
        [self.lblPaymentMode setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
        [self.lblFareEstmate setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    }
    
    
    self.currTripModel = tripModel;
    self.lblRiderName.text = [NSString stringWithFormat:@"%@ %@",tripModel.user.u_fname,tripModel.user.u_lname];
    self.lblPickupAddress.text = tripModel.trip_pick_loc;
    if(tripModel.pickup_notes.length>0)    {
        self.lblPickupAddress.text=[NSString stringWithFormat:@"%@\n\n%@ %@",tripModel.trip_pick_loc,[LanguageHelper getStringWithKey:@"k_1_s8_special_notes"],tripModel.pickup_notes];
    }
    
    self.lblDropAddress.text = tripModel.trip_drop_loc;
    self.imgRider.layer.borderColor =[UIColor lightGrayColor].CGColor;
    NSString *profile= tripModel.user.u_profile_image_path;
    if (profile.length>0) {
        [self.imgRider sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    else{
        [_imgRider setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    self.lbTripPickupTime.text=[NSString stringWithFormat:@"@%@",[Utilities GetGMTDatetoLocalTZ:tripModel.trip_date :APP_DATE_FORMAT]];
    [self.lbTripPickupTime setHidden:NO];
    if(tripModel.is_ride_later)  {
   
        if([self.currTripModel.trip_Status isEqualToString:TS_ASSIGNED])  {
            [self comppareDateAndShowTime:tripModel];
        }else{
            [self.btAccept setHidden:NO];
        }
        if([tripModel.trip_Status isEqual:TS_REQUEST])  {
            [self.btnCall setHidden:YES];
            [self.btnPessangeDetails setHidden:YES];
            self.nameTopMargin.constant=14;
        }else    {
            [self.btnCall setHidden:NO];
            [self.btnPessangeDetails setHidden:YES];
            self.nameTopMargin.constant=6;
        }
    }else{
        [self.btnCall setHidden:YES];
        self.nameTopMargin.constant=14;
        if(tripModel.trip_customer_details.length==0)    {
            [self.btnPessangeDetails setHidden:YES];
            self.nameTopMargin.constant=14;
        }else   {
            [self.btnPessangeDetails setHidden:NO];
            self.nameTopMargin.constant=6;
        }
    }
}


-(void)comppareDateAndShowTime:(TripModel *)tripModel{
    NSString * cTime = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
    NSDate *date1=[Utilities GetGMTDatetoLocalTZ1:tripModel.trip_date];
    NSDate *date2=[Utilities GetGMTDatetoLocalTZ1:cTime];
    NSComparisonResult result = [date2 compare:date1];
    if(result == NSOrderedAscending){
        NSTimeInterval secondsBetween = [date1 timeIntervalSinceDate:date2];
        int total=secondsBetween / 60;
        int minutes =total%60;
        int hours = total/60;
        if(secondsBetween<RIDE_LATER_DELAY)   {
            [self.btAccept setTitle:[LanguageHelper getStringWithKey:@"k_98_s4_arrive"] forState:UIControlStateNormal];
            [self.btAccept setHidden:NO];
            [self.lbTimeRemaining setHidden:YES];
        }else {
            [self.btAccept setHidden:YES];
            [self.lbTimeRemaining setHidden:NO];
            if(hours==0)  {
                self.lbTimeRemaining.text=[NSString stringWithFormat:@"%d min remaining to begin",minutes];
            }else{
                self.lbTimeRemaining.text=[NSString stringWithFormat:@"%d hours %d min remaining to begin",hours,minutes];
            }
        }
    }else{
        [self.lbTimeRemaining setHidden:YES];
        [self.btAccept setTitle:[LanguageHelper getStringWithKey:@"k_98_s4_arrive"] forState:UIControlStateNormal];
        [self.btAccept setHidden:NO];
    }
}


- (IBAction)ButtonAcceptPressed:(id)sender {
    [APP_DELEGATE stopRequestSound];
    if(self.currTripModel.is_ride_later)   {
        if([self.currTripModel.trip_Status isEqualToString:TS_ASSIGNED])   {
            NSString * cTime = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
            NSDate *date1=[Utilities GetGMTDatetoLocalTZ1:self.currTripModel.trip_date];
            NSDate *date2=[Utilities GetGMTDatetoLocalTZ1:cTime];
            NSComparisonResult result = [date2 compare:date1];
            if(result == NSOrderedAscending){
                NSTimeInterval secondsBetween = [date1 timeIntervalSinceDate:date2];
                if(secondsBetween<RIDE_LATER_DELAY)    {
                    [self ButtonAcceptAfterAssignPressed:sender];
                }else  {
                    [self ButtonAssignPressed:sender];
                }
            }else{
                if(result == NSOrderedDescending||result==NSOrderedSame){
                    [self ButtonAcceptAfterAssignPressed:sender];
                }else{
                    [self ButtonAssignPressed:sender];
                }
            }
        }else  {
            [self ButtonAssignPressed:sender];
        }
        return ;
    }
    [self.delegate requestGetButtonTapWithTrip:self.currTripModel];
}


- (void)ButtonAcceptAfterAssignPressed:(id)sender {
    NSString* runingTripID= defaults_object(TRIP_ID);
    if([runingTripID intValue]>0){
        [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_46_s4_already_in_trip"] ];
        return;
    }
    
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        TRIP_STATUS         :TS_ACCEPTED,
        TRIP_ID             :self.currTripModel.trip_Id,
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:TRIP_UPDATE   d:dict   isa:NO   cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [self.btAccept setHidden:YES];
            self.currTripModel.trip_Status=TS_ACCEPTED;
            [self.delegate refreshOnAcceptOnGoingTrip:self.currTripModel];
        }else if(isStatusError(results)){
            [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[LanguageHelper getStringWithKey:errorMessage(results)]];
        }
        else  if (error != nil) {
            NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
            id jsonObjects ;
            if(data)   {
                jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            if ([[jsonObjects objectForKey:P_STATUS] isEqualToString:@"Error"]) {
                [self.delegate refreshONRejectTripGoingTrip:self.currTripModel];
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"]];
            }
            else{
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] message:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] ];
            }
        }
    }];
}

- (void)ButtonAssignPressed:(id)sender {
    [self.delegate requestGetButtonTapWithTrip:self.currTripModel];
}


- (IBAction)ButtonCancelPressed:(id)sender {
    
    [self.delegate refreshONRejectTripGoingTrip:self.currTripModel];
}



#pragma send notifications
-(NSString *) getValueForKey:(NSString *) key lang:(NSString*)lang{
    return [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:lang];
}
-(void)sendNotification:(NSString *)status{
    NSString *message;
    if ([status isEqualToString:TS_ACCEPTED]){
        message = [self getValueForKey:@"k_1_s14_trip_confirm" lang:self.currTripModel.user.u_language];
    }else if([status isEqualToString:TS_ASSIGNED])  {
        message=[self getValueForKey:@"k_10_s14_trip_request_assign" lang:self.currTripModel.user.u_language];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"message"       :message,
        TRIP_STATUS      :status,
        TRIP_ID          :self.currTripModel.trip_Id,
        @"content-available":@"1",
    }];
    
    if(self.currTripModel.user.deviceToken!=nil) {
        if ([self.currTripModel.user.deviceType isEqualToString:IOS]) {
            [dict setObject:self.currTripModel.user.deviceToken forKey:IOS_TOKEN];
        }
        else{
            [dict setObject:self.currTripModel.user.deviceToken forKey:ANDROID_TOKEN];
        }
    }
    if ([[dict objectForKey:IOS_TOKEN] length]==0  && [[dict objectForKey:ANDROID_TOKEN] length]==0) {
        return;
    }
    [dict setObject:@"user" forKey:@"to"];
    [GIC mk:url_notification to:send_user_notification
          d:dict
        isa:NO
         cb:^(id results, NSError *error) {
        
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
        }
        
    }];
}

- (IBAction)onPickupLocationButTap:(id)sender {
    if(self.isUpcommingRide){
        [self.delegate onPickupLocationButonTap:self.currTripModel];
    }else{
        [self.delegate  requestGetButtonTapWithTrip:self.currTripModel];
    }
}
- (IBAction)onDropLocationButTap:(id)sender {
    if(self.isUpcommingRide){
        [self.delegate onDropLocationButonTap:sender];
    }else{
        [self.delegate  requestGetButtonTapWithTrip:self.currTripModel];
    } 
}

- (IBAction)onCallButtonTap:(id)sender {
    [self.delegate onCallToRiderButonTap:self.currTripModel];
}
- (IBAction)onPassengerDetails:(id)sender {
    [self.delegate onPassengerDetailsButonTap:self.currTripModel];
}
- (IBAction)onRejectButton:(id)sender {
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        TRIP_STATUS         :@"p_cancel_pickup",
        @"is_ride_later":@"1",
        @"can_fee_by":@"d",
        @"is_cancelled":@"1",
        TRIP_ID             :self.currTripModel.trip_Id,
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:TRIP_UPDATE   d:dict   isa:NO   cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [self.btAccept setHidden:YES];
            self.currTripModel.trip_Status=TS_ACCEPTED;
            [self.delegate refreshONRejectTripGoingTrip:self.currTripModel];
        }else if(isStatusError(results)){
            [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[LanguageHelper getStringWithKey:errorMessage(results)]];
        }
        else  if (error != nil) {
            NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
            id jsonObjects ;
            if(data)   {
                jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            if ([[jsonObjects objectForKey:P_STATUS] isEqualToString:@"Error"]) {
                [self.delegate refreshONRejectTripGoingTrip:self.currTripModel];
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[jsonObjects objectForKey:@"message"]];
            }
            else{
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] message:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] ];
            }
        }
    }];
}

@end
