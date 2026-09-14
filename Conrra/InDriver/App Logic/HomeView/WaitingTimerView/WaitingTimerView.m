//
//  CategoryCell.m
//  DemoMap
//
//  Created by Devineer on 19/01/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "WaitingTimerView.h"

#import "WebCallConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utilities.h"
#import "ConstantModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "WaitingTimerView.h"
#import "UIImage+GIF.h"
@implementation WaitingTimerView{
    NSDate *animateStartTime;
    NSTimer *aTimer;
    NSString * setupDate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



-(instancetype)initFromNib{
    
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil] firstObject];
}




-(void)setUpView:(NSString *) time{
    setupDate=time;
    self.lblCancelRide.text=[LanguageHelper getStringWithKey:@"k_67_s4_cncl_rid_drv"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    NSString * htmlString = [LanguageHelper getStringWithKey:@"k_16_s4_waiting_timer_msg"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    [self.lblCatName setAttributedText:attrStr];
    self.lblCatName.textColor = [UIColor colorNamed:@"color_app_label"];
    self.lblCatName.font=FONTS_THEME_REGULAR_NO_SCALE(14);
    [self animateProgress];
    [self refreshBanner];
    [self startTimer];
}



- (void)applicationWillEnterForeground {
    [self stopTimer];
    [self refreshBanner];
    int totalSeconds=self.category.d_can_free_min;
    int diff=[[NSDate date] timeIntervalSince1970]-[animateStartTime timeIntervalSince1970];
    
    if(diff<totalSeconds){
        [self.viewProgressTimer.layer removeAllAnimations];
        float part=(1.0/(totalSeconds*1.0));
        float pro=part*diff;
        [self animateProgress:pro second:totalSeconds-diff];
        [self startTimer];
    }else{
        [self.delegate onTimeWaitCompleted];
    }
}




-(void) startLoading{
    self.viewDots.hidden=NO;
}



-(void)startTimer{
    [self stopTimer];
    aTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(refreshBanner)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:aTimer forMode:NSRunLoopCommonModes];
}




-(void) stopTimer{
    if(aTimer){
        [aTimer invalidate];
        aTimer=nil;
    }
}




-(void)refreshBanner{
    ConstantModel *constantModel=[ConstantModel getConstantsObject];
    int totalSeconds=self.category.d_can_free_min;
    int diff=[[NSDate date] timeIntervalSince1970]-[animateStartTime timeIntervalSince1970];
    if(diff<totalSeconds){
        float part=(1.0/(totalSeconds*1.0));
        float pro=part*diff;
        long second=(totalSeconds-diff)%60;
        long min=(totalSeconds-diff)/60;
        self.lbltime.text=[NSString stringWithFormat:@"%02ld:%02ld",min,second];
        
        self.viewProgressTimer.progressValue=pro;
        
    }else{
        self.viewProgressTimer.progressValue=1;
        self.lbltime.text=[NSString stringWithFormat:@"%02d:%02d",totalSeconds,0];
//        self.lbltime.text=[NSString stringWithFormat:@"03:00"];
        [self.delegate onTimeWaitCompleted];
        [self stopTimer];
    }
}




- (void)animateProgress{
    int totalSeconds=self.category.d_can_free_min;
    if(setupDate.length>0){
        NSString *startStr =  [Utilities GetGMTDatetoLocalTZ:setupDate :@"yyyy-MM-dd HH:mm:ss"];
        animateStartTime =  [self convertStringToDate:startStr fromFormat:@"yyyy-MM-dd HH:mm:ss"];
        if(animateStartTime==nil){
            animateStartTime=[NSDate date];
        }
    }else{
        animateStartTime=[NSDate date];
    }
    int diff=[[NSDate date] timeIntervalSince1970]-[animateStartTime timeIntervalSince1970];
    
    if(diff<totalSeconds){
        float part=(1.0/(totalSeconds*1.0));
        float pro=part*diff;
        [self animateProgress:pro second:totalSeconds-diff];
    }else{
        [self.delegate onTimeWaitCompleted];
    }
}




-(NSDate *)convertStringToDate:(NSString *)strDate fromFormat:(NSString *)strFromFormat{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = strFromFormat;
    return [dateFormatter dateFromString:strDate];
}



- (void)animateProgress:(float)value second:(float)second{
    self.viewProgressTimer.progressValue = value;
//    [UIView animateWithDuration:second
//                     animations:^{
//        self.viewProgressTimer.progressValue = 1.f;
//    }
//                     completion:^(BOOL finished1) {
//        if(finished1){
//            int totalSeconds=self.category.d_can_free_min;
//            self.lbltime.text=[NSString stringWithFormat:@"%02d:%02d",totalSeconds,0];
////            self.lbltime.text=[NSString stringWithFormat:@"03:00"];
//            [self.delegate onTimeWaitCompleted];
//        }
//    }];
}




- (IBAction)onCancelButtonTap:(id)sender {
    [self.delegate onCancelButtonTap];
}

@end
