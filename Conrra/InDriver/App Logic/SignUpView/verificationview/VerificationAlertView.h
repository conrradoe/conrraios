//
//  NetworkLocationAlertView.h
//  HireMe Rider
//
//  Created by Grepix - Baij on 04/02/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
NS_ASSUME_NONNULL_BEGIN

@protocol VerificationAlertViewDelegate <NSObject>

-(void) onRefreshDriverVerified;
-(void) openUpdateDocument;

-(void) openMailComposer;
-(void) backToRider;

@end
@interface VerificationAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblAlert;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIImageView *imageInternet;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *txtUnVerified;
@property (weak, nonatomic) IBOutlet UIButton *btRefreshNow;
@property (weak, nonatomic) id<VerificationAlertViewDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIImageView *imageUnVerified;
@property (weak, nonatomic) IBOutlet UIButton *btnUploadDoc;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnBackToRider;
+(VerificationAlertView *) showView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
