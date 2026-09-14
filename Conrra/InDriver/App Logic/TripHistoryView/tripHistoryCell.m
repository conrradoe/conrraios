//
//  tripHistoryCell.m
//  TaxiDriver
//
//  Created by  Appicial on 29/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "tripHistoryCell.h"
#import "UIImageView+WebCache.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "ConstantModel.h"
#import "CategoryModel.h"
#import "TripModel+Helper.h"
#import "Utilities.h"

@implementation tripHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.imgRider setClipsToBounds:YES];
    [self.imgRider.layer setBorderColor:[UIColor colorNamed:@"color_app_label"].CGColor];
    [self.imgRider.layer setBorderWidth:1];
    [self.imgRider .layer setCornerRadius:25];
    [self setThemeConstants];
    self.lblDropLocationText.text=[LanguageHelper getStringWithKey:@"k_11_s8_search_drop_location"];
    self.lblPickupLocationText.text=[LanguageHelper getStringWithKey:@"k_1_s11_pickup_n_loc"];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setThemeConstants{
    [_lblDate setFont:FONTS_THEME_REGULAR(16)];
    [_lblAmmount setFont:FONTS_THEME_REGULAR(16)];
    [_lblriderName setFont:FONTS_THEME_REGULAR(14)];
    //     [_lbPickUpAddress setFont:FONTS_THEME_REGULAR(16)];
    //    [_lbDropUpAddress setFont:FONTS_THEME_REGULAR(16)];
    [_lbPickUpAddress sizeToFit];
    [_lbDropUpAddress sizeToFit];
}

-(void)setdataWithTripModel:(TripModel *)tripModel{
    
    tripModel = tripModel;
    _lbPickUpAddress.text = tripModel.pickupLocationApp;
    _lbDropUpAddress.text = tripModel.dropLocationApp;
    
    
    
    NSString * language = [[[NSLocale preferredLanguages] firstObject] substringToIndex:2];
    if ([language isEqualToString:@"ar"]) {
        
        _lblAmmount.textAlignment =NSTextAlignmentLeft;
    }
    
    CityModel * cModel=[CityModel getCityByCityId:tripModel.city_id];
    NSString *dis;
    NSString *tripDis;
    
    //    if (isDistanceUnitKm(cModel.city_dist_unit)/*[[_constantModel.constant_distance capitalizedString] isEqualToString:@"Km"]*/) {
    dis =cModel.city_dist_unit;
    tripDis = tripModel.trip_distance;
    //    }
    //    else{
    //        dis =cModel.city_dist_unit;
    //        float miles = KM_TO_MI([tripModel.trip_distance floatValue]);
    //        tripDis = [Utilities formatDistance:miles];
    //
    //    }
    
    
    //    NSDate *date1 = [Utilities GetGMTDatetoLocalTZ1:tripModel.trip_pickup_time];
    //    NSDate *date2 = [Utilities GetGMTDatetoLocalTZ1:tripModel.trip_drop_time];
    //
    //    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:date1];
    //
    //    float minutes = secondsBetween / 60;
    //
    //    NSString *time = [self getHoursAndMinutes:minutes];
    //
    float total = [tripModel.trip_fare floatValue]-[tripModel.trip_promo_amt floatValue];
    
    if (total<=0.0) {
        total =0.0;
    }
    
    //    _lblriderName.text=[NSString stringWithFormat:@"%@ - %@",[NSString stringWithFormat:@"%@ %@",tripDis,dis],time];
    
    _lblDate.text =[Utilities GetGMTDatetoLocalTZ:tripModel.trip_date :APP_DATE_FORMAT ];
    
    _lblAmmount.text =[Utilities formatAmountAndCurrency:total currency:isEmpty(cModel.city_cur)];
    NSString *profile= tripModel.user.u_profile_image_path;
    
    if (profile.length>0) {
        [_imgRider sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, profile]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    else
    {
        [_imgRider setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    
    if ([tripModel.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP] ||[tripModel.trip_Status isEqualToString:TS_RIDER_CANCEL]) {
        _lblriderName.text=[NSString stringWithFormat:@"%@ - %@",[NSString stringWithFormat:@"%@ %@",@"0.00",dis],[NSString stringWithFormat:@"%@ min",@"0"]];
    }
    if ([tripModel.trip_Status isEqualToString:TS_DRIVER_CANCEL_AT_PICKUP] ||[tripModel.trip_Status isEqualToString:TS_RIDER_CANCEL]) {
        _lblriderName.text=[NSString stringWithFormat:@"%@ - %@",[NSString stringWithFormat:@"%@ %@",@"0.00",dis],[NSString stringWithFormat:@"%@ min",@"0"]];
    }
    if([tripModel isTripCancelled]) {
        [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_r8_s10_cancelled"]];
        if([tripModel isTripCancelledForStatus]){
            [self.lbTripStatus setTextColor:[UIColor redColor]];
        }else{
            [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        }
        
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
    }else {
        [self.lbTripStatus setTextColor:[UIColor colorNamed:@"color_app_label"]];
        [self.lbTripStatus setText:isEmpty(tripModel.trip_Status)];
        [self.lbTripStatus setHidden:NO];
        if([tripModel.trip_Status isEqualToString:TS_END]&&[tripModel.trip_pay_status isEqualToString:TS_PAID])   {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_com_18_completed"]];
        }else if([tripModel.trip_Status isEqualToString:TS_END])
        {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_trip_payment_awaited"]/*@"Payment Awaited"*/];
        }else  if([tripModel.trip_Status isEqualToString:TS_REQUEST])    {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_request"]/*@"Request"*/];
        }else  if([tripModel.trip_Status isEqualToString:TS_ASSIGNED])    {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"k_con_21_assigned"]/*@"Request"*/];
        }else  {
            [self.lbTripStatus setText:[LanguageHelper getStringWithKey:@"p_14_s4_ongoing"]/*@"Ongoing"*/];
        }
    }
}

-(NSString *)getHoursAndMinutes:(NSInteger)minutes{
    
    NSString *tmpStr;
    int min = (int)minutes%60;
    int hours = (minutes - min)/60;
    
    if (hours>0) {
        
        tmpStr =[NSString stringWithFormat:@"%dh %d min", hours, min];
        
    }
    else{
        
        tmpStr =[NSString stringWithFormat:@"%d min", min];
    }
    
    return tmpStr;
    
}


@end
