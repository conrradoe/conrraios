//
//  TripHistoryViewController.m
//  TaxiDriver
//
//  Created by  Appicial on 24/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import "TripUpCommingViewController.h"
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "PendingTripCell.h"
#import "TripDetailsViewController.h"
#import "ConstantModel.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "TripModel+Helper.h"
#import "TripDetailsViewController.h"
#import "SingleRequestView.h"
#import "UpcommingTripCell.h"
#import "PickupDetailViewController.h"
@interface TripUpCommingViewController ()<SingleRequestViewDelegate,TripRequestDelegate>
{
    NSMutableArray *tripArray;
    BOOL IsLoadNext;
    ConstantModel  *constantModel;
    SingleRequestView *singleRequestView;
}

@end

@implementation TripUpCommingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblNoRec.text =[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_avail"];
    [self setThemeConstants];
    tripArray =[[NSMutableArray alloc]init];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    constantModel =[ConstantModel getConstantsObject];
    [_tableView registerNib:[UINib nibWithNibName:@"UpcommingTripCell" bundle:nil]
     forCellReuseIdentifier:@"UpcommingTripCell"];
    IsLoadNext =NO;
    [self gettripHistory];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUIFields];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUIFields{
    self.lblHeader.text = [LanguageHelper getStringWithKey:@"k_6_s4_a1_upcmng_rides"];
    self.lblNoRec.text=[LanguageHelper getStringWithKey:@"k_17_s10_no_trips_avail"];
}

-(void)setThemeConstants{
    
    [_lblHeader setFont:FONTS_THEME_REGULAR(18)];
    [_lblNoRec setFont:FONTS_THEME_REGULAR(18)];
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"TripDetailsViewController"]) {
        
        TripDetailsViewController *details =(TripDetailsViewController *)[segue destinationViewController];
        
        details.trip = [tripArray objectAtIndex:[sender floatValue]];
        //        details.constantModel=constantModel;
    }
}

- (IBAction)ButtonBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gettripHistory{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID          :[dict1 objectForKey:P_DRIVER_ID],
        TRIP_STATUS:TS_ASSIGNED
    }];
    [dict setObject:[NSString stringWithFormat:@"%lu", (unsigned long)tripArray.count] forKey:@"offset"];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:TRIP_GETTRIP   d:dict    isa:NO  cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"]) {
            NSArray *arrtrip =[[NSArray alloc]init];
            if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                arrtrip = [results objectForKey:P_RESPONSE];
                for (int i=0; i<arrtrip.count; i++) {
                    TripModel *Trip = [[TripModel alloc] initItemWithDict:[arrtrip objectAtIndex:i]];
                    [self->tripArray addObject:Trip];
                }
            }
            if (arrtrip.count<SIZE) {
                self->IsLoadNext =YES;
            }
            if (self->tripArray.count ==0 ) {
                self.lblNoRec.hidden =NO;
            }
            else{
                self.lblNoRec.hidden =YES;
            }
            
            [self.tableView reloadData];
        }
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return tripArray.count;
    
}

-(void)requestGetButtonTapWithTrip:(TripModel *)trip{
    if(self->singleRequestView==nil)  {
        self->singleRequestView=[SingleRequestView showTripRequestAcceptViewWithDelegate:self parentView:self.view tripIdFromRequest:trip];
        self->singleRequestView.delegate=self;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UpcommingTripCell";
    UpcommingTripCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    [cell setdataWithTripModel:[tripArray objectAtIndex:indexPath.row]];
    TripModel * tripModel = [tripArray objectAtIndex:indexPath.row];
    NSString *trip_pick_loc=tripModel.pickupLocationApp;
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-80, 300) forText:  trip_pick_loc  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    [cell.viewVerticalLine setConstraintConstant:pickHeight+25 forAttribute:NSLayoutAttributeHeight];
    //    if (indexPath.row >tripArray.count-2 && !IsLoadNext) {
    //        [self gettripHistory];
    //    }
    cell.isUpcommingRide = YES;
    cell.delegate= self;
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TripModel * tripModel = [tripArray objectAtIndex:indexPath.row];
    NSString * stringPickup=tripModel.trip_pick_loc;
    if(tripModel.pickup_notes.length>0){
        stringPickup=[NSString stringWithFormat:@"%@\n\n%@ %@",tripModel.trip_pick_loc,[LanguageHelper getStringWithKey:@"k_1_s8_special_notes"],tripModel.pickup_notes];
    }
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText:  stringPickup  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat dropHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText: tripModel.trip_drop_loc withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat finalHeight = 10 + dropHeight;
    return 128 + pickHeight + finalHeight+15+40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    TripDetailsViewController *details = (TripDetailsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.TRIP_DETAIL_VC];
    //    details.trip = [tripArray objectAtIndex:indexPath.row];
    //    [self addChildViewController:details];
    //    [details.view setFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT)];
    //    [self.view addSubview:details.view];
    //    [details didMoveToParentViewController:self];
    
}
-(void) view:(SingleRequestView *) view onAcceptTripSuccess:(TripModel *) trip{
    
}
-(void) view:(SingleRequestView *) view onRejectTripSuccess:(TripModel *) trip{
    
}
-(void) view:(SingleRequestView *) view onCloseTripRequest:(TripModel *) trip{
    
}
-(void)showAlert:(NSString *) title message:(NSString*)message{
    
}
-(void)showAlertForOfferSent:(NSString *) title message:(NSString*)message{
    
}

-(void)handleErrorApi:(NSError *) error{
    
}

-(void)onPickupLocationButonTap:(TripModel *)tripModel
{
    PickupDetailViewController * vc=(PickupDetailViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.PICKUP_DETAIL_VC];
    vc.isPickup=YES;
    vc.tripModel=tripModel;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)onDropLocationButonTap:(TripModel *)tripModel
{
    PickupDetailViewController * vc=(PickupDetailViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.PICKUP_DETAIL_VC];
    vc.isPickup=NO;
    vc.tripModel=tripModel;
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)refreshONRejectTrip:(TripModel *)trip{
    TripModel * tripRemove;
    for (TripModel *tripModelTemp in self->tripArray) {
        if(tripModelTemp.trip_Id==trip.trip_Id)   {
            tripRemove = tripModelTemp;
            break;
        }
    }
    if(tripRemove){
        [tripArray removeObject:tripRemove];
    }
    if (self->tripArray.count ==0) {
        self.lblNoRec.hidden =NO;
    }
    else{
        self.lblNoRec.hidden=YES;
    }
    [self.tableView reloadData];
}


-(void)refreshOnAcceptOnGoingTrip:(TripModel *)trip{
    NSString *tripId=[NSString stringWithFormat:@"%@",trip.trip_Id];
    defaults_set_object(TRIP_ID,tripId);
    [self loadHomeViewController];
}
@end
