//
//  tripHistoryCell.m
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 29/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "UTripHistoryCell.h"
#import "UIImageView+WebCache.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "Utilities.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "TripModel+Helper.h"

@implementation UTripHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.lbTripStatus setHidden:YES];
 
    [self.btCancelTrip.layer setCornerRadius:14];
    [self setThemeConstants];
    [self.btCancelTrip setHidden:YES];
    self.lblDropLocationText.text=[LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    self.lblPickupLocationText.text=[LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    [self.lbTripStatus setHidden:YES];
    [self.btCancelTrip setHidden:YES];
    [self.viewVerticalLine setConstraintConstant:35 forAttribute:NSLayoutAttributeHeight];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setThemeConstants{
    [_lblDate setFont:FONTS_THEME_REGULAR(16)];
}



-(void)setdataWithTripModel:(TripModel *)tripModel{
    
    self.tripModel=tripModel;
    _lblDate.text =[Utilities GetGMTDatetoLocalTZ:tripModel.trip_date :APP_DATE_FORMAT];
    _lbPickUpAddress.text = tripModel.pickupLocationApp;
    _lbDropUpAddress.text = tripModel.dropLocationApp;
    
    
    NSString *dis;
    NSString *tripDis;
    
    CityModel * cModel=[CityModel getCityByCityId:self.tripModel.city_id];
    dis =cModel.city_dist_unit;
    tripDis = tripModel.trip_distance;
    if(tripModel.is_ride_later){
        if(![tripModel.trip_Status isEqualToString:TS_END]) {
            [self.lbTripStatus setHidden:NO];
            [self.lbTripStatus setText:tripModel.trip_Status];
            [self.btCancelTrip setHidden:NO];
            if([tripModel.trip_Status isEqualToString:TS_BEGIN]||[tripModel.trip_Status isEqualToString:TS_RIDER_CANCEL]||[tripModel.trip_Status isEqualToString:TS_USER_CANCEL])  {
                [self.btCancelTrip setHidden:YES];
            }
        }
    }else
    {
        
        
    }
    if([tripModel isTripCancelled])  {
        if([tripModel isTripCancelledForStatus]){
            [self.lbTripStatus setTextColor:[UIColor redColor]];
        }else{
            [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        }
        [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_r8_s10_cancelled"]];
        [self.lbTripStatus setHidden:NO];
        if([tripModel.trip_Status isEqualToString:TS_RIDER_CANCEL_CANCEL]||[tripModel.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_DROP]){
            if([tripModel.trip_pay_status isEqualToString:TS_PAID]){
                [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_r8_s10_cancelled"]/*@"Payment Awaited"*/];
                [self.lbTripStatus setTextColor:[UIColor redColor]];
            }else{
                [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_trip_payment_awaited"]/*@"Payment Awaited"*/];
                [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
            }
        }
    }else
    {
        [self.lbTripStatus setText:isEmpty(tripModel.trip_Status)];
        [self.lbTripStatus setHidden:NO];
        [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        if([tripModel.trip_Status isEqualToString:TS_END]&&[tripModel.trip_pay_status isEqualToString:TS_PAID])
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_com_18_completed"]];
        }else if([tripModel.trip_Status isEqualToString:TS_END])
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_trip_payment_awaited"]/*@"Payment Awaited"*/];
        }else  if([tripModel.trip_Status isEqualToString:TS_REQUEST])
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_request"]/*@"Request"*/];
        }else  if([tripModel.trip_Status isEqualToString:TS_ASSIGNED])
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_assigned"]/*@"Request"*/];
        }else
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"p_14_s4_ongoing"]/*@"Ongoing"*/];
        }
    }
}
-(NSString *)getHoursAndMinutes:(NSInteger)minutes{
    
    NSString *tmpStr;
    int min = (int)minutes%60;
    int hours = (int)(minutes - min)/60;
    
    if (hours>0) {
        
        tmpStr =[NSString stringWithFormat:@"%dh %d min", hours, min];
        
    }
    else{
        
        tmpStr =[NSString stringWithFormat:@"%d min", min];
    }
    return tmpStr;
    
}
- (IBAction)onCancelTrip:(id)sender {
//    NSMutableDictionary *dict=[[NSMutableDictionary alloc]  init];
//    [dict setObject:[NSString stringWithFormat:@"%d", self.tripModel.trip_Id] forKey:TRIP_ID];
//    [dict setObject:TS_USER_CANCEL forKey:TRIP_STATUS];
//    [self.tripModel updateTripModelWith:dict completionBlock:^(id results, NSError *error) {
//        if([[results objectForKey:P_RESPONSE] isKindOfClass:[NSDictionary class]])
//        {
//
//        }
//        else{
//            if([[results objectForKey:P_RESPONSE] intValue]==1)
//            {
//                [self.delegate cancelTrip:self.tripModel];
//            }
//        }
//    } isShowLoader:YES isSendNotification:NO];
    [self.delegate cancelTrip:self.tripModel];
}

- (IBAction)onnDriverCallButtonTap:(id)sender {
    [self.delegate onDriverCallButtonTap:self.tripModel];
}

@end
