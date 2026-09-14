//
//  HandleAlertViewController.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 05/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "HandleAlertViewController.h"
#import "LanguageHelper.h"
@interface HandleAlertViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageLocation;

@end

@implementation HandleAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(appDidEnterForeground)
                                                          name:UIApplicationWillEnterForegroundNotification
                                                        object:nil];
    // Do any additional setup after loading the view from its nib.
    self.lblAlert.text=[LanguageHelper getStringWithKey:@"k_com_s18_Ooops" defaultValue:@"Ooops!"];
    self.lblMessage.text=[LanguageHelper getStringWithKey:@"k_com_s18_check_setting_msg" defaultValue:@"To re-enable, please go to Settings and turn on Location Service for this app."];
    [self.btnTitle setTitle:[LanguageHelper getStringWithKey:@"k_com_s18_check_setting" defaultValue:@"Check Settings" ] forState:UIControlStateNormal];
    [self.imageLocation sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_app_images,@"location-service.jpg"]] placeholderImage:[UIImage imageNamed:@"image_location-service.jpg"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkisLocationServiceEnabled) name:@"refresh_location" object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated ];
    [self checkisLocationServiceEnabled];
}
- (IBAction)onOpenSettingButtonTap:(id)sender {
     
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
        
    }];
}


-(void)appDidEnterForeground{
    
    int authorizationStatus=[CLLocationManager authorizationStatus];
    if(authorizationStatus==0){
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self checkisLocationServiceEnabled];
    }
}

-(void)checkisLocationServiceEnabled
{
    if([CLLocationManager locationServicesEnabled]){
        int authorizationStatus =[CLLocationManager authorizationStatus];
        if(authorizationStatus==kCLAuthorizationStatusDenied||authorizationStatus==kCLAuthorizationStatusNotDetermined||authorizationStatus==kCLAuthorizationStatusRestricted){
            
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

- (IBAction)onBackButtonTap:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
@end
