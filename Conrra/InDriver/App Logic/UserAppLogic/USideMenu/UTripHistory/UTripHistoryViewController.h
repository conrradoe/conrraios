//
//  TripHistoryViewController.h
//  TaxiDriver
//
//  Created by Appicial Taxi App Soutions on 24/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UTripDetailsViewController.h"
#import "LanguageHelper.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+Extension.h"
#import "UChatViewController.h"
#import "BaseViewController.h"
@class UTripHistoryViewController;
@protocol UTripHistoryViewControllerDelegate <NSObject>

-(void) openTripOfferPageForTrip:(TripModel *) trip;

@end
@interface UTripHistoryViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UTripDetailsViewControllerDelegate,UIViewControllerExtensionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lblNoRec;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;
@property (strong, nonatomic) IBOutlet UIButton *btnPast;
@property (strong, nonatomic) IBOutlet UIButton *btnUpcoming;
@property (strong, nonatomic) IBOutlet UIView *viewPastUpcomingBg;
@property (weak, nonatomic) IBOutlet UIView *pastBottomView;
@property (weak, nonatomic) IBOutlet UIView *upcomingBottomView;
@property(weak,nonatomic) UTripDetailsViewController *tripDetailsViewController;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property(weak,nonatomic) id<UTripHistoryViewControllerDelegate> delegate;


@end
