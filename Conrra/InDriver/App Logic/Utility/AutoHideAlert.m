//
//  AutoHideAlert.m

//
//  Created by Grepix Infotech on 02/08/22.
//

#import "AutoHideAlert.h"


@implementation AutoHideAlert
{
    int duration;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self->duration=5;
    }
    return self;
}
- (instancetype)initWith:(int) duration{
    self = [super init];
    if (self) {
        self->duration=duration;
    }
    return self;
}

-(void) handle:(UIAlertController *)alert {
    self.alertAutoHide=alert;
    [self setDissmissTimerAlert];
}

-(void)setDissmissTimerAlert{
    [self stopDissmissTimerAlert];
    self.timerForHideAlert = [NSTimer scheduledTimerWithTimeInterval: self->duration target: self
                                                     selector: @selector(dissmissTimerAlertCalled) userInfo: nil repeats: NO];
}

-(void) performAction{
    [self stopDissmissTimerAlert];
    if(self.delegate){
        [self.delegate onAutoHide:self];
    }
}
-(void)stopDissmissTimerAlert{
    if(self.timerForHideAlert){
        [self.timerForHideAlert invalidate];
//        self.timerForHideAlert=nil;
    }
}
-(void)dissmissTimerAlertCalled{
    if(self.alertAutoHide!=nil){
        [self.alertAutoHide  dismissViewControllerAnimated:YES completion:^{
//            self.alertAutoHide=nil;
            [self stopDissmissTimerAlert];
            if(self.delegate){
                [self.delegate onAutoHide:self];
            }
        }];
    }
}
@end
