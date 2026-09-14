//
//  LanguageCell.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "NotificationCell.h"
#import "Utilities.h"
@implementation NotificationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void) populateData:(NotificationModel *) notificationModel indexPath:(NSIndexPath *) indexPath
{
    self.lblLanguage.text = notificationModel.title;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *indianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:indianLocale];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate *ts_GMT = [dateFormat dateFromString:notificationModel.createdDate];
    
    NSDate * currentDate=[NSDate date];
    NSTimeInterval  interval=[currentDate timeIntervalSinceDate:ts_GMT];
    if(interval<60*60)
    {
     int    minutes = interval / 60;
        self.lbDate.text=[NSString stringWithFormat:@"%d mn ago",minutes];
    }
    else
    {
        
        NSDateFormatter *dateFormatCurrentMid = [[NSDateFormatter alloc] init];
        [dateFormatCurrentMid setDateFormat:@"yyyy-MM-dd"];
        [dateFormatCurrentMid setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSDate * currentDateMidNight=[dateFormatCurrentMid dateFromString:[dateFormatCurrentMid stringFromDate:currentDate]];
        NSTimeInterval  interval=[ts_GMT timeIntervalSinceDate:currentDateMidNight];
         if(interval>0)
         {
             NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:notificationModel.createdDate :@"hh:mm a"];
             self.lbDate.text=startStr;
         }else{
             NSDate * currentDateMidNightTwo=[NSDate dateWithTimeIntervalSince1970:[currentDateMidNight timeIntervalSince1970]-60*60*24];
              if([currentDateMidNightTwo timeIntervalSince1970]<[ts_GMT timeIntervalSince1970])
              {
                  self.lbDate.text=[LanguageHelper getStringWithKey:@"k_6_s16_yesterday"];
              }else{
                  NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
                  NSCalendarUnitMonth | NSCalendarUnitYear;
                  
                  // if `date` is before "now" (i.e. in the past) then the components will be positive
                  NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                                 fromDate:ts_GMT
                                                                                   toDate:currentDateMidNight
                                                                                  options:0];
                  
                  if (components.year > 0) {
                      NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:notificationModel.createdDate :@"d MMM yyyy"];
                      self.lbDate.text=startStr;
                  }
                  else {
                      NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:notificationModel.createdDate :@"d MMM"];
                      self.lbDate.text=startStr;
                  }
                  
              }
         }
        
    }
    self.lbRefId.text=notificationModel.message;
}

@end
