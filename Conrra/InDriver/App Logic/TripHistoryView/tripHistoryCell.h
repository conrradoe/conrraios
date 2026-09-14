//
//  tripHistoryCell.h
//  TaxiDriver
//
//  Created by  Appicial on 29/05/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "ConstantModel.h"

@interface tripHistoryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgRider;
@property (weak, nonatomic) IBOutlet UIImageView *imgCar;
@property (strong, nonatomic) IBOutlet UILabel *lblriderName;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblAmmount;
@property (weak, nonatomic) IBOutlet UILabel *lbPickUpAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbDropUpAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbTripStatus;
@property (weak, nonatomic) IBOutlet UIImageView *viewVerticalLine;

@property (weak, nonatomic) IBOutlet UILabel *lblPickupLocationText;
@property (weak, nonatomic) IBOutlet UILabel *lblDropLocationText;
-(void)setdataWithTripModel:(TripModel *)tripModel;
@property(nonatomic,strong) ConstantModel *constantModel;

@end
