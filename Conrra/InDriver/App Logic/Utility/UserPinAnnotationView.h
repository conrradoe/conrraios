//
//  UserPinAnnotationView.h
//  Conrra
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Squircle bubble annotation view for the passenger's location pin.
/// Yellow fill (#F5C518), circular avatar, speech-bubble tail pointing down.
@interface UserPinAnnotationView : MKAnnotationView

/// Set the user's avatar photo. Falls back to a person-silhouette icon if nil.
- (void)setAvatarImage:(nullable UIImage *)image;

@end

NS_ASSUME_NONNULL_END
