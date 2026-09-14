//
//  SentOfferDetailsViewController.h
//  InDriver
//
//  Created by Grepix Infotech on 08/04/22.
//

#import "BaseViewController.h"
#import "TripModel.h"

NS_ASSUME_NONNULL_BEGIN
@class  SentOfferDetailsViewController;
@protocol SentOfferDetailsViewControllerDelegate <NSObject>

-(void) onUserOfferAcceptedByDriver:(SentOfferDetailsViewController *) viewController;

@end
@interface SentOfferDetailsViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderText;
@property(weak,nonatomic) id<SentOfferDetailsViewControllerDelegate> delegate;
@property(strong,nonatomic)TripOffer *trip;
@end

NS_ASSUME_NONNULL_END
