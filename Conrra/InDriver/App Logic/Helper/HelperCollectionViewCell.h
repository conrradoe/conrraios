//
//  HelperCollectionViewCell.h

//
//  Created by Grepix - Baij on 15/04/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HelperCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageScreen;
@property (weak, nonatomic) IBOutlet UIImageView *imLogo;
@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;

/// New onboarding: dim overlay + white title/body on background image (Figma style)
@property (nonatomic, strong) UIView *dimOverlay;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;

- (void)configureWithTitle:(NSString *)title body:(NSString *)body backgroundImage:(UIImage * _Nullable)backgroundImage;

@end

NS_ASSUME_NONNULL_END
