//
//  LanguageViewController.h
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
@class PaymentMethodListViewController;

@protocol PaymentMethodListViewControllerDelegate <NSObject>

-(void) onPaymentMethodSelected:(NSString *) paymentMethodType  viewControlllor:(PaymentMethodListViewController*)viewControlllor;
-(void) onPaymentIntentSelected:(NSString *) paymentMethod dict:(NSDictionary *) dict viewControlllor:(PaymentMethodListViewController*)viewControlllor;

@end

@interface PaymentMethodListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (assign, nonatomic)  BOOL isFromPaymentJob;
@property (assign, nonatomic)  BOOL isFormPrepaireTrip;
@property(weak ,nonatomic) id<PaymentMethodListViewControllerDelegate> delegate;
@property (assign, nonatomic)  BOOL isFormPrepaireConfirmTrip;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCard;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;

@end
