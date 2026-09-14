//
//  NetworkLocationAlertView.h

//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
NS_ASSUME_NONNULL_BEGIN

@interface HelpScreenAlertView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageInternet;
+(HelpScreenAlertView *) showHelperScreens:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
