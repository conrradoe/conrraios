//
//  ChatViewController.h
//  HireMe Rider
//
//  Created by Prashant on 12/02/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripModel.h"
#import "UIImageView+WebCache.h"
#import "LanguageHelper.h"
#import "SAMTextView.h"

@interface ChatViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIImageView *imageSendIcon;
@property (weak, nonatomic) IBOutlet SAMTextView *txtChatMessage;

@property (strong,nonatomic) NSString *tripID;
@property (strong,nonatomic) TripModel *tripModel;
@property (nonatomic) BOOL isFromHistory;

@end


