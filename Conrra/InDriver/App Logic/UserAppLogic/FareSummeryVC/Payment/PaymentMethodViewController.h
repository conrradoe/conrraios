//
//  PaymentMethodViewController.h
//  Conrra
//

#import <UIKit/UIKit.h>
#import "CityModel.h"

@class PaymentMethodViewController;

@protocol PaymentMethodViewControllerDelegate <NSObject>
/// Called immediately when the user selects a payment mode.
/// mode: 0=Cash, 1=Wallet, 2=PagoMóvil
- (void)paymentSheet:(PaymentMethodViewController *)vc didSelectMode:(int)mode;
@end

@interface PaymentMethodViewController : UIViewController

@property (weak,   nonatomic) id<PaymentMethodViewControllerDelegate> delegate;
@property (assign, nonatomic) int        selectedMode;            ///< Pass current mode before presenting
@property (assign, nonatomic) CityModel *cityModel;               ///< Used to know available payment options
@property (assign, nonatomic) float      walletBalance;           ///< Shown in Mi Billetera subtitle
@property (assign, nonatomic) float      tripFare;                ///< Used to validate wallet has enough balance
@property (assign, nonatomic) BOOL       isFormPrepaireConfirmTrip; ///< Kept for legacy compat

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel     *lblHeaderTitle;

@end
