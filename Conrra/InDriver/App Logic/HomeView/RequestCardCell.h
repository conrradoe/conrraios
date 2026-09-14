//  RequestCardCell.h

#import <UIKit/UIKit.h>
@class TripModel;

NS_ASSUME_NONNULL_BEGIN

@interface RequestCardCell : UICollectionViewCell

- (void)configureWithTrip:(TripModel *)trip;

@end

NS_ASSUME_NONNULL_END
