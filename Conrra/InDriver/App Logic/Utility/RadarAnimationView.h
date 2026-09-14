//
//  RadarAnimationView.h
//  Conrra
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Amber pulsing radar rings shown when a ride is requested.
/// Sized large enough to cover typical map visibility — position it over the map
/// with its center at the user's screen coordinate.
@interface RadarAnimationView : UIView

- (void)startAnimating;
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
