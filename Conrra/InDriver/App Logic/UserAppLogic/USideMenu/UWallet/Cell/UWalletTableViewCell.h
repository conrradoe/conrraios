//
//  WalletTableViewCell.h
//  HireMe Rider
//
//  Created by Grepix Infotech on 27/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageHelper.h"


@interface UWalletTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *transTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *transCreatedLbl;

@property (weak, nonatomic) IBOutlet UILabel *amountLbl;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentBalance;
@property (weak, nonatomic) IBOutlet UILabel *lblCardAmount;

@property (weak, nonatomic) IBOutlet UILabel *lblTransDesc;

@end
