//
//  tripHistoryCell.h
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 29/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "ConstantModel.h"
#import "CategoryModel.h"
#import "LanguageHelper.h"

@class UTripHistoryCell;
@protocol UTripHistoryCellCellDelegate <NSObject>

-(void) cancelTrip:(TripModel *) tripModel;
-(void) onDriverCallButtonTap:(TripModel *) tripModel;

@end
@interface UTripHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewDriverInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lbPickUpAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbDropUpAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupLocationText;
@property (weak, nonatomic) IBOutlet UILabel *lblDropLocationText;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;
@property (weak, nonatomic) IBOutlet UILabel *lbTripStatus;
@property (weak, nonatomic) IBOutlet UIButton *btCancelTrip;

@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UIButton *btDriverCall;
@property (weak, nonatomic) IBOutlet UIImageView *imgDriverProfileImage;

@property(strong,nonatomic) TripModel* tripModel;
@property(nonatomic,strong) ConstantModel *constantModel;
@property (nonatomic, strong) NSMutableArray  *arrCategory;
@property (nonatomic, strong) CategoryModel *carCategory;
@property(weak,nonatomic) id<UTripHistoryCellCellDelegate> delegate;

-(void)setdataWithTripModel:(TripModel *)tripModel;
@end
