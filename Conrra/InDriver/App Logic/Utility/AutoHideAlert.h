//
//  AutoHideAlert.h

//
//  Created by Grepix Infotech on 02/08/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AutoHideAlert;
@protocol AutoHideAlertDelegate <NSObject>

-(void) onAutoHide:( nonnull AutoHideAlert * ) autoHideAlertHelper;

@end
NS_ASSUME_NONNULL_BEGIN

@interface AutoHideAlert : NSObject
@property(strong, nonatomic) UIAlertController *alertAutoHide;
@property(strong, nonatomic)NSTimer *timerForHideAlert ;
@property(strong, nonatomic)NSString *tripId;
@property(strong, nonatomic)NSString *tripStatus;
@property(weak, nonatomic) id<AutoHideAlertDelegate>delegate ;
-(void)stopDissmissTimerAlert;
-(void) handle:(UIAlertController *)alert;
-(void) performAction;

@end

NS_ASSUME_NONNULL_END
