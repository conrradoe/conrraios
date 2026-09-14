//  OfferCardCell.h

#import <UIKit/UIKit.h>
@class TripOffer;

NS_ASSUME_NONNULL_BEGIN

@protocol OfferCardCellDelegate <NSObject>
- (void)offerCardCellDidSelectOffer:(TripOffer *)offer;
- (void)offerCardCellDidRequestCancelOffer:(TripOffer *)offer;
@end

@interface OfferCardCell : UICollectionViewCell
@property (nonatomic, weak) id<OfferCardCellDelegate> delegate;
- (void)configureWithOffer:(TripOffer *)offer;
@end

NS_ASSUME_NONNULL_END
