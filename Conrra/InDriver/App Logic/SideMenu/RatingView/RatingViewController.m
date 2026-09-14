//
//  RatingViewController.m
//  TaxiDriver
//
//  Created by  Appicial on 24/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "RatingViewController.h"
#import "StarRatingView.h"
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import <GIKit/GIKit.h>

#define kStarViewHeight 35.0f*0.75
#define kStarViewWidth 180.0f*0.75



@interface RatingViewController ()

@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUIFields];
    [self setThemeConstants];
    [self getDriverProfile:defaults_object(P_API_KEY)];
    
    
    
    
}



-(void) setUIFields{
    
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_7_s4_a1_rating"];
//    [_btnBack setBackgroundImage:[UIImage imageNamed:@"backward-arrow"] forState:UIControlStateNormal];



}

-(void)setThemeConstants{
  
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
    
    
}

- (IBAction)ButtonBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)getDriverProfile:(NSString *)apikey{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_API_KEY :apikey,
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:GET_DRIVER_PROFILE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
           if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
               defaults_set_object(P_USER_DICT,  [[results objectForKey:P_RESPONSE]objectAtIndex:0]);
           }
           [self showRating];
           [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
       }];
}





-(void)showRating{
    
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    
    NSString *rating = [dict1 objectForKey:@"d_rating"];
    
    StarRatingView* starViewNoLabel = [[StarRatingView alloc]initWithFrame:CGRectMake((self.view.frame.size.width -kStarViewWidth) /2, self.viewtemp.frame.origin.y, kStarViewWidth, kStarViewHeight) andRating:[rating floatValue]*20 withLabel:NO animated:YES];
    [starViewNoLabel setUserInteractionEnabled:NO];
    
    UILabel * ratingCount=[[UILabel alloc]  initWithFrame:CGRectMake(30, self.viewtemp.frame.origin.y+kStarViewHeight+5, SCREEN_WIDTH-60, 40)];
    ratingCount.font=FONTS_THEME_REGULAR(14);
    ratingCount.textAlignment=NSTextAlignmentCenter;
    
    ratingCount.text=[NSString stringWithFormat:@"%@ : %d",[LanguageHelper getStringWithKey:@"k_66_s4_rating_count"],[[dict1  objectForKey:@"d_rating_count"]  intValue]];
    [self.view addSubview:starViewNoLabel];
    [self.view addSubview:ratingCount];
}
@end
