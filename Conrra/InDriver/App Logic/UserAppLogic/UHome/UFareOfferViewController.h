//
//  UFareOfferViewController.h
//  Conrra
//
//  Screen 3 — "Tarifa recomendada"
//  Presented as UIModalPresentationOverFullScreen over UHomeViewController so the
//  map (with drawn route) remains visible behind the white bottom sheet.
//

#import <UIKit/UIKit.h>

@class UFareOfferViewController;
@class CategoryModel;

@protocol UFareOfferDelegate <NSObject>

/// Back button tapped — dismiss Screen 3 and push Screen 2
- (void)fareOfferDidTapBack:(UFareOfferViewController *)vc;

/// "Pedir Taxi" tapped — dismiss Screen 3 then book with offer amount
- (void)fareOfferVC:(UFareOfferViewController *)vc didRequestTripWithAmount:(float)amount;

/// Payment row tapped — push PaymentMethodListVC onto vc.navigationController
- (void)fareOfferVCDidTapPayment:(UFareOfferViewController *)vc;

@optional
/// El pasajero cambio de categoria en la lista "Elige tu viaje".
- (void)fareOfferVC:(UFareOfferViewController *)vc eligioCategoria:(CategoryModel *)categoria;

@end

@interface UFareOfferViewController : UIViewController

@property (weak,   nonatomic) id<UFareOfferDelegate> delegate;

/// The fare currently shown in the stepper (read by delegate to validate wallet balance)
@property (assign, nonatomic, readonly) float      currentAmount;
/// Pre-filled from API estimate
@property (assign, nonatomic) float      recommendedFare;
/// Lower bound for stepper (from category.min_offer_perc)
@property (assign, nonatomic) float      minFare;
/// Upper bound for stepper (from category.max_offer_perc)
@property (assign, nonatomic) float      maxFare;
/// Currency string e.g. "USD" or "$"
@property (strong, nonatomic) NSString  *currency;

/// Todas las categorias de la ciudad, para la lista "Elige tu viaje".
@property (strong, nonatomic) NSArray      *categorias;
/// La que esta elegida ahora mismo.
@property (strong, nonatomic) CategoryModel *categoriaElegida;
/**
 Estimacion por categoria, indexada por category_id.

 Es el mismo diccionario que BookingModel ya construye: tripapi/estimatetripfare
 devuelve una estimacion por CADA categoria en una sola llamada, no solo la elegida.
 El dato ya estaba; lo que faltaba era enseñarlo.
 */
@property (strong, nonatomic) NSDictionary *estimacionesPorCategoria;
/// Display text for current payment method
@property (strong, nonatomic) NSString  *paymentLabel;
/// Icon for current payment method
@property (strong, nonatomic) UIImage   *paymentIcon;

/// Called by UHomeViewController after the user selects a payment method
- (void)updatePaymentLabel:(NSString *)label icon:(nullable UIImage *)icon;

/// Read the configuration toggles when building the trip request
@property (assign, nonatomic, readonly) BOOL configExtraPassengers;
@property (assign, nonatomic, readonly) BOOL configPetsAllowed;
@property (assign, nonatomic, readonly) BOOL configIsDelivery;

@end
