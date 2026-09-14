//
//  NetworkLocationAlertView.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "ShareRideTripView.h"
#import "LanguageHelper.h"
#import "ConstantModel.h"
@implementation ShareRideTripView
{
    ConstantModel *constantTaxiModel;
    NSTimer *timerPendingRequest;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    [super awakeFromNib];
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    [self.tableview registerNib:[UINib nibWithNibName:@"PendingTripCell" bundle:nil ] forCellReuseIdentifier:@"PendingTripCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"CurrentTripCell" bundle:nil ] forCellReuseIdentifier:@"CurrentTripCell"];
   
    
}




+(void) showShareRide:(UIView *)view tripModel:(TripModel  *) tripModel delegate:(id<CurrentTripCellDelegate>) delegate {
    ShareRideTripView *shareRideTripView=[[[NSBundle mainBundle] loadNibNamed:@"ShareRideTripView" owner:self options:nil] firstObject];
    shareRideTripView.tripModel=tripModel;
    CGRect rect=[UIScreen mainScreen].bounds;
    shareRideTripView.frame=CGRectMake(0, 0, rect.size.width, rect.size.height);
    [view addSubview:shareRideTripView];
    shareRideTripView.alpha=0;
    [UIView animateWithDuration:0.3 animations:^{
    shareRideTripView.alpha=1;
    }];
    shareRideTripView.delegate=delegate;
    [shareRideTripView onCurrentTripButTap:nil];
}


#pragma - mark  Handle Button Click

- (IBAction)onCloseButtonTap:(id)sender {
    self.alpha=1;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}




- (IBAction)onCurrentTripButTap:(id)sender {
    self.btnCurrentTrip.selected=YES;
    self.btnTripRequest.selected=NO;
    
    [self.btnCurrentTrip  setTitleColor:RGB(0,185,225) forState:UIControlStateNormal];
    [self.btnTripRequest  setTitleColor:RGB(184,184,184) forState:UIControlStateNormal];
    
    [self.viewTripRequest setBackgroundColor:[UIColor clearColor]];
    [self.viewCurrentTrip setBackgroundColor:RGB(0,185,225)];
     [self getAllPendingTrips:YES];
    
}



- (IBAction)onTripRequestButTap:(id)sender {
    self.btnCurrentTrip.selected=NO;
    self.btnTripRequest.selected=YES;
    
    [self.btnCurrentTrip  setTitleColor:RGB(184,184,184) forState:UIControlStateNormal];
    [self.btnTripRequest  setTitleColor:RGB(0,185,225) forState:UIControlStateNormal];
    [self.viewCurrentTrip setBackgroundColor:[UIColor clearColor]];
    [self.viewTripRequest setBackgroundColor:RGB(0,185,225)];
    [self getAllPendingTrips:nil];
}


#pragma - mark  UITableViewDelegate Method

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.arrayCurrentTrip.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CurrentTripCell";
    
    
    CurrentTripCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    
    UIColor *lightGray = RGBA(0.0, 0.0, 0.0, 0.1);
    
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
        cell.backgroundColor=[UIColor clearColor];
        cell.viewTopSeparator.backgroundColor =lightGray;
        cell.viewBottomSeparator.backgroundColor =lightGray;
    
    cell.delegate = self.delegate;
    cell.delegateForClose=self;
    [cell setdataWithTripModel:[self.arrayCurrentTrip objectAtIndex:indexPath.row]];
    TripModel * tripModel = [self.arrayCurrentTrip objectAtIndex:indexPath.row];
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText:  tripModel.trip_pick_loc  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    [cell.viewVerticalLine setConstraintConstant:pickHeight+25 forAttribute:NSLayoutAttributeHeight];
    
    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    TripModel * tripModel = [self.arrayCurrentTrip objectAtIndex:indexPath.row];
    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText:  tripModel.trip_pick_loc  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat dropHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-95, 300) forText: tripModel.trip_drop_loc withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    CGFloat finalHeight = 10 + dropHeight;
    return 128 + pickHeight + finalHeight+15;
    //    return 112;
}



-(void)getAllPendingTrips:(BOOL)isShowLoader{
    AppDelegate *appdelegate =APP_DELEGATE;
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
     if(dict1==nil)
     {
         if (isShowLoader) {
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
            }
         return;
     }
    if (constantTaxiModel==nil) {
        constantTaxiModel =[ConstantModel getConstantsObject];
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{}];
     
    if(self.btnCurrentTrip.isSelected)
    {
        
        // if  m_trip_id == nil or 0 then send trip_id on trip_id parameter for get the current trip data
          // for get the  marte trip data only  then send is_detail = 0 in this trip otherwise  do not send this parameter
        if([self.tripModel.m_trip_id intValue]>0)
        {
            [dict setObject:self.tripModel.m_trip_id forKey:@"m_trip_id"];
            
        }else{
            [dict setObject:self.tripModel.trip_Id forKey:@"trip_id"];
        }
        
        [dict setObject:[dict1 objectForKey:P_DRIVER_ID] forKey:P_DRIVER_ID];
    }else
    {
         // for the the  share ride rquest  send new parameter is_share in revised trip
        [dict setObject:TS_REQUEST forKey:TRIP_STATUS];
        [dict setObject:@"1" forKey:@"is_share"];
        [dict setObject:@PENDING_HOURS forKey:@"hours"];
        [dict setObject:[dict1 objectForKey:P_CATEGORY_ID] forKey:P_CATEGORY_ID];
        [dict setObject:[NSString stringWithFormat:@"%f", appdelegate.currLoc.coordinate.latitude] forKey:@"lat"];
        [dict setObject:[NSString stringWithFormat:@"%f", appdelegate.currLoc.coordinate.longitude] forKey:@"lng"];
        if (constantTaxiModel.constant_driver_radius ==0.0) {
            [dict setObject:@"4" forKey:@"miles"];
        }
        else{
            [dict setObject:[NSString stringWithFormat:@"%.1f",constantTaxiModel.constant_driver_radius] forKey:@"miles"];
        }
    }

    if (isShowLoader) {
        [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }
    [GIC mkwu:self.btnCurrentTrip.isSelected?TRIP_GET_MASTER_TRIP:GET_REVISED_TRIPS
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
    
           if ([[[results objectForKey:P_STATUS]  uppercaseString]isEqualToString:@"OK"] && [[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
               // success
               NSArray *arrTemp = [results objectForKey:P_RESPONSE];
               NSMutableArray *arrtemp1 =[[NSMutableArray alloc]init];
               
               if(self.btnCurrentTrip.isSelected)
               {
                
                   for (NSMutableDictionary *dictTripMaster in arrTemp) {
                       NSArray * tripInMsater=[dictTripMaster objectForKey:@"Trip"];
                       for (NSMutableDictionary *dict in tripInMsater  ) {
                           
                           TripModel  *currTrip1 = [[TripModel alloc] initItemWithDict:dict];
                            if([currTrip1.trip_Status isEqualToString:@"accept"]||[currTrip1.trip_Status isEqualToString:@"arrive"]||[currTrip1.trip_Status isEqualToString:@"begin"])
                           [arrtemp1 addObject:currTrip1];
                       }
                   }
               }
               else
               {
                   for (NSMutableDictionary *dict in arrTemp) {
                       TripModel  *currTrip1 = [[TripModel alloc] initItemWithDict:dict];
                           [arrtemp1 addObject:currTrip1];
                   }
               }
               
               self.arrayCurrentTrip = [[NSMutableArray alloc] initWithArray:arrtemp1];
               [self invalidatePendingTripTimer];
               self->timerPendingRequest = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
                                                                    selector: @selector(getPending) userInfo: nil repeats: NO];
               
           }
           else{
               if(error!=nil)
               {
//                   if(self->apiCallAttempt<3)
//                   {
//                       if (isShowLoader) {
//                           [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
//                       }
//                       [self getPending];
//                   }
//                   else{
//                       self->apiCallAttempt=0;
                       self->_arrayCurrentTrip = [[NSMutableArray alloc]init];
                       [self invalidatePendingTripTimer];
                       self->timerPendingRequest = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
                                                                            selector: @selector(getPending) userInfo: nil repeats: NO];
//                   }
               }else{
//                   self->apiCallAttempt=0;
                   self->_arrayCurrentTrip = [[NSMutableArray alloc]init];
                   [self invalidatePendingTripTimer];
                   self->timerPendingRequest = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
                                                                        selector: @selector(getPending) userInfo: nil repeats: NO];
               }
           }
           
           [self.tableview reloadData];
           
           if (self.arrayCurrentTrip.count>0) {
               self.lblNoTrips.hidden=YES;
           }
           else{
               self.lblNoTrips.hidden =NO;
           }
           
           
           if (isShowLoader) {
               
               if (isShowLoader) {
                   [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
               }
           }
           
       }];
    
}


-(void)getPending{
    [self getAllPendingTrips:NO];
}

-(void)invalidatePendingTripTimer{
    [timerPendingRequest invalidate];
    timerPendingRequest = nil;
}


-(void)onPickupLocationButonTap:(TripModel *)trip{
    
}

-(void)onDropLocationButonTap:(TripModel *)trip
{
    
}

-(void)onCallToRiderButonTap:(TripModel *)trip
{
    
}

-(void)onCloseView
{
    [self onCloseButtonTap:nil];
}

@end
