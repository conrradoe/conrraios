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

@optional
/// El pasajero quiere recargar la billetera: la hoja ya se cerro al llamar.
- (void)paymentSheetDidRequestWalletTopUp:(PaymentMethodViewController *)vc;

/**
 Con que billete paga y que vuelto necesita.

 Llega antes que didSelectMode:, y con nil cuando el metodo elegido no es efectivo --
 asi quien lo reciba olvida lo que hubiera escrito antes de cambiar de metodo.
 */
- (void)paymentSheet:(PaymentMethodViewController *)vc
   instruccionesDeEfectivo:(NSString *)instrucciones;
@end

@interface PaymentMethodViewController : UIViewController

@property (weak,   nonatomic) id<PaymentMethodViewControllerDelegate> delegate;
@property (assign, nonatomic) int        selectedMode;            ///< Pass current mode before presenting
@property (assign, nonatomic) CityModel *cityModel;               ///< Used to know available payment options
@property (assign, nonatomic) float      walletBalance;           ///< Shown in Mi Billetera subtitle
@property (assign, nonatomic) float      tripFare;                ///< Used to validate wallet has enough balance
@property (assign, nonatomic) BOOL       isFormPrepaireConfirmTrip; ///< Kept for legacy compat
/// Lo ultimo que se escribio del billete y el vuelto. nil si no se paga en efectivo.
@property (strong, nonatomic) NSString *instruccionesDeEfectivo;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel     *lblHeaderTitle;

@end
