
//
//  PendingTripCell.m
//  Captain Sareeie
//
//  Created by Devineer on 08/05/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "CurrentTripCell.h"
#import "WebCallConstants.h"
#import "UIImageView+WebCache.h"
#import <GIKit/GIKit.h>
#import "Utilities.h"
#import "CategoryModel.h"
#import <Conrra-Swift.h>
#import "UIView+UpdateAutoLayoutConstraints.h"
@implementation CurrentTripCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.btAccept setClipsToBounds:YES];
    [self.lbTimeRemaining setHidden:YES];
    [self.btAccept.layer setCornerRadius:17];
    [self setUIFields];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) setUIFields{
    self.lblPicupLocation.text = [LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    self.lblDropLocation.text = [LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    [self.btAccept setTitle: [LanguageHelper getStringWithKey:@"k_1_s9_accept"]   forState:UIControlStateNormal];
    
    
    
}
-(void)prepareForReuse
{
    [super prepareForReuse];
    [self setUIFields ];
    [self.btAccept setHidden:NO];
    [self.lbTripPickupTime setHidden:YES];
    [self.lbTimeRemaining setHidden:YES];
    [self.btAccept setTitle:[LanguageHelper getStringWithKey:@"k_1_s9_accept"] forState:UIControlStateNormal];
}
-(void)setdataWithTripModel:(TripModel *)tripModel{
    if ([tripModel.trip_Status isEqualToString:TS_REQUEST]) {
        self.viewAcceptRequest.hidden=NO;
    }
    self.currTripModel = tripModel;
    self.lblRiderName.text = [NSString stringWithFormat:@"%@ %@",tripModel.user.u_fname,tripModel.user.u_lname];
    self.lblPickupAddress.text = tripModel.trip_pick_loc;
    self.lblDropAddress.text = tripModel.trip_drop_loc;
    
    self.imgRider.layer.borderColor =[UIColor lightGrayColor].CGColor;
    NSString *profile= tripModel.user.u_profile_image_path;
    
    if (profile.length>0) {
        [self.imgRider sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    else
    {
        [_imgRider setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    
    CityModel *cityModel=[CityModel getCityByCityId:tripModel.city_id];
    self.lblFareEstmate.text=[NSString stringWithFormat:@"%@%@",[LanguageHelper getStringWithKey:@"k_1_s8_est"],[Utilities formatAmountAndCurrency:[tripModel.trip_fare floatValue] currency:cityModel.city_cur]];
    if([tripModel.trip_fare floatValue]==0){
        self.lblFareEstmate.hidden=YES;
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
    
    if(tripModel.is_ride_later)
    {
        [self.btAccept setTitle:[LanguageHelper getStringWithKey:@"k_4_s9_assign"] forState:UIControlStateNormal];
        
        if([tripModel.trip_Status isEqualToString:TS_ASSIGNED])
        {
            [self.btAccept setHidden:YES];
            if([self.currTripModel.trip_Status isEqualToString:TS_ASSIGNED])
            {
                
                
                NSString * cTime = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
                
                NSDate *date1=[Utilities GetGMTDatetoLocalTZ1:tripModel.trip_date];
                NSDate *date2=[Utilities GetGMTDatetoLocalTZ1:cTime];
                //                  NSDate *date2 = [NSDate date];
                NSComparisonResult result = [date2 compare:date1];
                switch (result)
                {
                    case NSOrderedAscending:
                    {
                        
                        NSTimeInterval secondsBetween = [date1 timeIntervalSinceDate:date2];
                        int total=secondsBetween / 60;
                        int minutes =total%60;
                        int hours = total/60;
                        
                        if(secondsBetween<RIDE_LATER_DELAY)
                        {
                            [self.btAccept setTitle:[LanguageHelper getStringWithKey:@"k_19_s4_arrived"] forState:UIControlStateNormal];
                            [self.btAccept setHidden:NO];
                            [self.lbTimeRemaining setHidden:YES];
                        }else
                        {
                            [self.lbTimeRemaining setHidden:NO];
                            if(hours==0)
                            {
                                self.lbTimeRemaining.text=[NSString stringWithFormat:@"%d min remaining to begin",minutes];
                            }else{
                                self.lbTimeRemaining.text=[NSString stringWithFormat:@"%d hours %d min remaining to begin",hours,minutes];
                            }
                        }
                        break;
                    }
                    case NSOrderedDescending:
                    {
                        [self.btAccept setTitle:[LanguageHelper getStringWithKey:@"k_19_s4_arrived"] forState:UIControlStateNormal];
                        [self.btAccept setHidden:NO];
                        break;
                    }
                    case NSOrderedSame:
                    {
                        {
                            [self.btAccept setTitle:[LanguageHelper getStringWithKey:@"k_19_s4_arrived"] forState:UIControlStateNormal];
                            [self.btAccept setHidden:NO];
                            break;
                        }
                        break;
                    }
                    default:
                        break;
                }
                
                
            }
            
        }
        [self.lbTripPickupTime setHidden:NO];
        self.lbTripPickupTime.text=[NSString stringWithFormat:@"@%@",[Utilities GetGMTDatetoLocalTZ:tripModel.trip_date :APP_DATE_FORMAT]];
         if([tripModel.trip_Status isEqual:TS_REQUEST])
         {
             [self.btnCall setHidden:YES];
             self.nameTopMargin.constant=14;
         }else
         {
             [self.btnCall setHidden:NO];
             self.nameTopMargin.constant=6;
         }
        
    }else
    {
        [self.lbTripPickupTime setHidden:NO];
        [self.btnCall setHidden:YES];
        self.nameTopMargin.constant=14;
        self.lbTripPickupTime.text=[NSString stringWithFormat:@"@%@",[Utilities GetGMTDatetoLocalTZ:tripModel.trip_date :APP_DATE_FORMAT]];
    }
    
    if([tripModel.trip_Status isEqualToString:@"request"])
    {
        [self.btAccept setTitle:@"Accept" forState:UIControlStateNormal];
    }
    else if([tripModel.trip_Status isEqualToString:@"accept"])
    {
        [self.btAccept setTitle:@"Arrived" forState:UIControlStateNormal];
        
    }else if([tripModel.trip_Status isEqualToString:@"arrive"]) {
        
        [self.btAccept setTitle:@"Pick Up" forState:UIControlStateNormal];
        
    }else if([tripModel.trip_Status isEqualToString:@"begin"]) {
        
        [self.btAccept setTitle:@"End" forState:UIControlStateNormal];
    }
}


- (IBAction)ButtonAcceptPressed:(id)sender {
    
//    if([tripModel.trip_Status isEqualToString:@"request"])
//    {
//        [self.btAccept setTitle:@"Accept" forState:UIControlStateNormal];
//    }
//    else
    if([self.currTripModel.trip_Status isEqualToString:@"accept"])
    {
        [self.delegateForClose onCloseView];
        [self.delegate onArrivedTripStatusInitForTrip:self.currTripModel];
        return;
    }else if([self.currTripModel.trip_Status isEqualToString:@"arrive"]) {
        [self.delegateForClose onCloseView];
        [self.delegate onPickUpTripStatusInitForTrip:self.currTripModel];
          return;
    }else if([self.currTripModel.trip_Status isEqualToString:@"begin"]) {
        [self.delegateForClose onCloseView];
        [self.delegate onBeginTripStatusInitForTrip:self.currTripModel];
          return;
    }
    
    
    
    if(self.currTripModel.is_ride_later)
    {
        
        if([self.currTripModel.trip_Status isEqualToString:TS_ASSIGNED])
        {
            NSString * cTime = [NSString stringWithFormat:@"%@",[Utilities getStringFromDate:[NSDate date]]];
            NSDate *date1=[Utilities GetGMTDatetoLocalTZ1:self.currTripModel.trip_date];
            NSDate *date2=[Utilities GetGMTDatetoLocalTZ1:cTime];
            NSComparisonResult result = [date2 compare:date1];
            switch (result)
            {
                case NSOrderedAscending:
                {
                    NSTimeInterval secondsBetween = [date1 timeIntervalSinceDate:date2];
                    if(secondsBetween<RIDE_LATER_DELAY)
                    {
                        [self ButtonAcceptAfterAssignPressed:sender];
                    }else
                    {
                        [self ButtonAssignPressed:sender];
                    }
                    break;
                }
                case NSOrderedDescending:
                {
                    [self ButtonAcceptAfterAssignPressed:sender];
                    break;
                }
                case NSOrderedSame:
                {
                    {
                        [self ButtonAcceptAfterAssignPressed:sender];
                        break;
                    }
                    break;
                }
                default:
                    break;
            }
        }else
        {
            [self ButtonAssignPressed:sender];
        }
        
        return ;
    }
    
    
    
    
    
    
    
    
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        TRIP_STATUS         :TS_ACCEPTED,
        TRIP_ID             :self.currTripModel.trip_Id,
    }];
    
    NSString *master_trip_id =defaults_object(M_TRIP_ID);
    if(master_trip_id)
    {
        [dict setObject:master_trip_id forKey:@"m_trip_id"];
    }
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    
    [GIC mkwerwu:trip_accept
                  d:dict
//      isa:NO
              cb:^(id results, NSError *error) {
        
         
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
            // success
            
            TripModel  *currTrip = [[TripModel alloc] initItemWithDict:[results objectForKey:P_RESPONSE]];
            [self.delegateForClose onCloseView];
            [self.delegate onAcceptTripStatusInitForTrip:currTrip];
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            //               NSString *driverAvailability =@"0";
            //               [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:driverAvailability];
            //               [self showAcceptView:YES];
            //               driverStatus = TS_ACCEPTED;
            //               _goPopUpView.hidden=NO;
            //
            //               defaults_set_object(DRIVER_STATUS, driverStatus);
            //
            //               progCount =0;
            //               _progressView.progress=1;
            //               [progressTimer invalidate];
            //               progressTimer=nil;
            //               [self sendNotification:TS_ACCEPTED];
            //               isRiderCancelCalled =NO;
            //               [self getTripDetails];
            
        }
        
        else  if (error != nil) {
            NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
            id jsonObjects ;
            if(data)
            {
                jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            if ([[jsonObjects objectForKey:P_STATUS] isEqualToString:@"Error"]) {
                
//                [self.delegate refreshONRejectTrip:self.currTripModel];
              
                
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[jsonObjects objectForKey:@"message"]/*[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"]*/];
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                
            }
            else{
                
                
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] message:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] ];
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                
                
            }
        }
    }];
}


- (IBAction)ButtonAcceptAfterAssignPressed:(id)sender {
    
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        TRIP_STATUS         :TS_ACCEPTED,
        TRIP_ID             :self.currTripModel.trip_Id,
    }];
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    
    [GIC mkwu:TRIP_UPDATE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            [self.btAccept setHidden:YES];
            self.currTripModel.trip_Status=TS_ACCEPTED;
            [self.delegate onAcceptTripStatusInitForTrip:self.currTripModel];
        }
        
        else  if (error != nil) {
            NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
            id jsonObjects ;
            if(data)
            {
                jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            if ([[jsonObjects objectForKey:P_STATUS] isEqualToString:@"Error"]) {
                
//                [self.delegate refreshONRejectTrip:self.currTripModel];
                
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"]];
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                
            }
            else{
                
                
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] message:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] ];
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                
                
            }
        }
    }];
    
    
    
}

- (IBAction)ButtonAssignPressed:(id)sender {
    
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        P_DRIVER_ID         :[dict1 objectForKey:P_DRIVER_ID],
        TRIP_STATUS         :TS_ASSIGNED,
        TRIP_ID             :self.currTripModel.trip_Id,
    }];
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    
    [GIC mkwu:trip_assigned
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            
            // success
            
            //               TripModel  *currTrip = [[TripModel alloc] initItemWithDict:[results objectForKey:P_RESPONSE]];
            [self.btAccept setHidden:YES];
//            [self.delegate refreshOnAssginedTrip:self.currTripModel
//             ];
            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            //               NSString *driverAvailability =@"0";
            //               [[UpdateUserCurrentLocation sharedInstance]  updateDriverAvailablity:driverAvailability];
            //               [self showAcceptView:YES];
            //               driverStatus = TS_ACCEPTED;
            //               _goPopUpView.hidden=NO;
            //
            //               defaults_set_object(DRIVER_STATUS, driverStatus);
            //
            //               progCount =0;
            //               _progressView.progress=1;
            //               [progressTimer invalidate];
            //               progressTimer=nil;
            [self sendNotification:TS_ASSIGNED];
            //               isRiderCancelCalled =NO;
            //               [self getTripDetails];
            
        }
        
        else  if (error != nil) {
            NSData *data=[error.userInfo objectForKey:AppKeysName.ERROR_DATA];
            id jsonObjects ;
            if(data)
            {
                jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            if ([[jsonObjects objectForKey:P_STATUS] isEqualToString:@"Error"]) {
                
//                [self.delegate refreshONRejectTrip:self.currTripModel];
                
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_30_s8_too_late"] message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"]];
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                
            }
            else{
                
                
                [self.delegate showAlert:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] message:[LanguageHelper getStringWithKey:@"k_36_s6_please_check_network"] ];
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
                
                
            }
        }
    }];
    
    
    
}


- (IBAction)ButtonCancelPressed:(id)sender {
    
//    [self.delegate refreshONRejectTrip:self.currTripModel];
}


-(NSString *) getValueForKey:(NSString *) key lang:(NSString*)lang{
    return [[LanguageHelper sharedInstance] getStringWithKey:key currentLanguage:lang];
}
#pragma send notifications

-(void)sendNotification:(NSString *)status{
    NSString *message;
    if ([status isEqualToString:TS_ACCEPTED]){
        message = [self getValueForKey:@"k_1_s14_trip_confirm" lang:self.currTripModel.user.u_language];
    }else if([status isEqualToString:TS_ASSIGNED]) {
        message=[self getValueForKey:@"k_10_s14_trip_request_assign" lang:self.currTripModel.user.u_language];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        
        @"message"       :message,
        TRIP_STATUS      :status,
        TRIP_ID          :self.currTripModel.trip_Id,
        @"content-available":@"1",
        
    }];
    if(self.currTripModel.user.deviceToken!=nil){
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
    [self.delegate  onPickupLocationButonTap:self.currTripModel];
}
- (IBAction)onDropLocationButTap:(id)sender {
    [self.delegate  onDropLocationButonTap:self.currTripModel];
}

- (IBAction)onCallButtonTap:(id)sender {
    [self.delegate onCallToRiderButonTap:self.currTripModel];
}

@end
