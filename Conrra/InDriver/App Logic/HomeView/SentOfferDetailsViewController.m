//
//  SentOfferDetailsViewController.m
//  InDriver
//
//  Created by Grepix Infotech on 08/04/22.
//

#import "SentOfferDetailsViewController.h"
#import "SingleRequestView.h"
#import "Utilities.h"
#import "TripNotificationHelper.h"
@interface SentOfferDetailsViewController ()<SingleRequestViewDelegate>

@end

@implementation SentOfferDetailsViewController
{
    SingleRequestView *singleRequestView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.trip.isOfferSent=YES;
    self->singleRequestView=[SingleRequestView showSentTripRequestAcceptViewWithDelegate:self parentView:self.view tripIdFromRequest:self.trip];
    self->singleRequestView.delegate =self;
    self.lblHeaderText.text=[LanguageHelper getStringWithKey:@"k_1_s9_offer_details" defaultValue:@"Offer Details"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkAndHideRequestView:) name:AppNotificationName.USER_OFFER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkAndHideRequestView:) name:AppNotificationName.USER_OFFER_NOTIFICATION object:nil];
    
}

-(void)checkAndHideRequestView:(NSNotification *)notification{
    NSDictionary * dict = notification.userInfo;
    NSDictionary * aps = [notification.userInfo objectForKey:@"aps"];
    if([[aps objectForKey:@"trip_status" ] isEqualToString:@"declined"]){
        NSString * tripId = [aps objectForKey:@"trip_id" ];
        if([tripId isEqualToString:self.trip.trip_id]){
//            [self.delegate view:self onCloseTripRequest:self.trip];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self showAlertWithOk:@"" message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"] handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popToRootViewControllerAnimated:NO];
            }];
//            [self.navigationController popToRootViewControllerAnimated:NO];
//            [[NSNotificationCenter defaultCenter] postNotificationName:AppNotificationName.USER_DECLINE_Alert_NOTIFICATION object:nil userInfo:nil];
//            [self showAlert:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_31_s8_another_driver_accepted"]];
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) view:(SingleRequestView *) view onAcceptTripSuccess:(TripModel *) trip{
    [self.delegate onUserOfferAcceptedByDriver:self];
}

-(void) view:(SingleRequestView *) view onRejectTripSuccess:(TripModel *) trip{
    NSMutableDictionary *dict= [[NSMutableDictionary  alloc] init];
    [dict setObject:@"decline" forKey:@"status"];
    NSDictionary * dictDriver = defaults_object(P_USER_DICT);
    [dict setObject:[dictDriver objectForKey:P_DRIVER_ID] forKey:P_DRIVER_ID];
    [dict setObject:self.trip.trip_id forKey:TRIP_ID];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwerwu:API_UPDATE_OFFER d:dict cb:^(id  _Nonnull results, NSError * _Nonnull error) {
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
        if(isOK(results)){
            SocketHelperSwift * socket=[APP_DELEGATE getSockethelperSwift];
            if([socket isConnected]){
                [socket sendOfferToUserWithTrip:self.trip.trip status:@"declined" data:[results objectForKey:P_RESPONSE]];
            }else{
                [TripNotificationHelper sendNotificationToUser:@"declined" data:[results objectForKey:P_RESPONSE] trip:self.trip.trip];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [Utilities handleError:error viewController:self defaultMessage:@""];
        }
    }];    
}

-(void) view:(SingleRequestView *) view onCloseTripRequest:(TripModel *) trip{
    
}

-(void)showAlert:(NSString *) title message:(NSString*)message{
    [self showAlertWithOk:title message:message handler:^(UIAlertAction * _Nonnull action) {
        
    }];
}
- (IBAction)onBackButtonTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)handleErrorApi:(NSError *) error{
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showAlertForOfferSent:(NSString *)title message:(NSString *)message{
    
}
@end
