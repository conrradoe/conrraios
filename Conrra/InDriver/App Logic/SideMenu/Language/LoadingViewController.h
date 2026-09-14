//
//  LoadingViewController.h

//
//  Created by Grepix - Baij on 28/01/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HandlingHelper.h"
#import "BaseViewController.h"
#import "Utilities.h"
NS_ASSUME_NONNULL_BEGIN

@interface LoadingViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *viewOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageBottom;

@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@end

NS_ASSUME_NONNULL_END
