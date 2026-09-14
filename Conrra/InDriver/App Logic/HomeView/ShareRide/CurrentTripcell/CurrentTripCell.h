//
//  PendingTripCell.h
//  Captain Sareeie
//
//  Created by Devineer on 08/05/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "LanguageHelper.h"

@protocol CurrentTripCellDelegate

-(void)showAlert:(NSString *)title message:(NSString *)msg;
-(void) onAcceptTripStatusInitForTrip:(TripModel *) tripModel;
-(void) onPickUpTripStatusInitForTrip:(TripModel *) tripModel;
-(void) onArrivedTripStatusInitForTrip:(TripModel *) tripModel;
-(void) onBeginTripStatusInitForTrip:(TripModel *) tripModel;
-(void)onPickupLocationButonTap:(TripModel *)trip;
-(void)onDropLocationButonTap:(TripModel *)trip;
-(void)onCallToRiderButonTap:(TripModel *)trip;
-(void) onCloseView;

@end

@interface CurrentTripCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopMargin;
@property (strong, nonatomic) IBOutlet UIImageView *imgRider;
@property (strong, nonatomic) IBOutlet UILabel *lblRiderName;
@property (strong, nonatomic) IBOutlet UILabel *lblPickupAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblDropAddress;
@property (strong, nonatomic) IBOutlet UIView *viewAcceptRequest;
@property (strong, nonatomic) IBOutlet UIView *viewBottomSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;
@property (weak, nonatomic) IBOutlet UILabel *lbTripPickupTime;
@property (weak, nonatomic) IBOutlet UILabel *lbTimeRemaining;
@property (strong, nonatomic) IBOutlet UIView *viewTopSeparator;
@property (weak, nonatomic) IBOutlet UIButton *btAccept;
@property (weak, nonatomic) IBOutlet UILabel *lblPicupLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblDropLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentMode;
@property (weak, nonatomic) IBOutlet UILabel *lblFareEstmate;



@property (nonatomic, strong)TripModel *currTripModel;
@property(weak,nonatomic) id<CurrentTripCellDelegate> delegate;
@property(strong,nonatomic) id<CurrentTripCellDelegate> delegateForClose;

-(void)setdataWithTripModel:(TripModel *)tripModel;
@end
