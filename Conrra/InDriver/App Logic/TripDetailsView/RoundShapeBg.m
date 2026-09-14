//
//  RoundShapeBg.m
//  HireMe Rider
//
//  Created by Grepix - Baij on 02/04/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "RoundShapeBg.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "TripModel.h"
#import "Utilities.h"
#import "TripModel+Helper.h"
@implementation RoundShapeBg
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pading=20;
        self.txtWidth=125;
    }
    return self;
}

-(void)makeRound:(UIView *)view tripModel:( TripModel *)tripModel heightView:(int)heightView bottomTop:(int)bottomTop
{
    UIBezierPath* polygonPath = [UIBezierPath bezierPath];
//    NSString * pick=tripModel.pickupLocationApp;
//    NSString * drop=tripModel.dropLocationApp;
//
//
//    CGFloat pickHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-self.txtWidth, 300) forText: pick  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
//    CGFloat dropHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-self.txtWidth, 300) forText: drop  withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    
//    if(dropHeight<20){
//        dropHeight=20;
//    }
//    CGFloat pickPickTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-self.txtWidth, 300) forText:  tripModel.pickupTitleWithPickUpTime withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
//    CGFloat pickDropTimeHeight = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-self.txtWidth, 300) forText: tripModel.dropTitleWithDropTime withFont:FONTS_THEME_REGULAR_NO_SCALE(16)];
    
    
//    if(pickPickTimeHeight>20)
//    {
//        dropHeight=dropHeight+(pickPickTimeHeight-20);
//    }
//    if(pickDropTimeHeight>20)
//    {
//        dropHeight=dropHeight+(pickDropTimeHeight-20);
//    }
    
    int width=SCREEN_WIDTH-2*self.pading;
    int height=heightView;
    int radius=10*(SCREEN_WIDTH/320.0);
    int topPadding=height-bottomTop;
    
    [polygonPath moveToPoint: CGPointMake(0, 0)];
    
    // top
    //    [polygonPath addLineToPoint: CGPointMake(width/2-radius, 0)];
    //    [polygonPath addArcWithCenter:CGPointMake(width/2, 0) radius:radius startAngle:[self DegreesToRadians:180]  endAngle:[self DegreesToRadians:360] clockwise:NO];
    
    [polygonPath addLineToPoint: CGPointMake(width, 0)];
    
    [polygonPath addLineToPoint: CGPointMake(width,radius-radius+topPadding)];
    [polygonPath addArcWithCenter:CGPointMake(width, radius+topPadding) radius:radius startAngle:[self DegreesToRadians:270]  endAngle:[self DegreesToRadians:450] clockwise:NO];
    
    
    [polygonPath addLineToPoint: CGPointMake(width, height)];
    
    
    // Bottom
    //    [polygonPath addLineToPoint: CGPointMake(width/2+radius, height)];
    //    [polygonPath addArcWithCenter:CGPointMake(width/2, height) radius:radius startAngle:[self DegreesToRadians:0]  endAngle:[self DegreesToRadians:180] clockwise:NO];
    //    [polygonPath moveToPoint: CGPointMake(width/2-radius, height)];
    
    
    
    [polygonPath addLineToPoint: CGPointMake(0, height)];
    [polygonPath addLineToPoint: CGPointMake(0, radius+radius+topPadding)];
    [polygonPath addArcWithCenter:CGPointMake(0, radius+topPadding) radius:radius startAngle:[self DegreesToRadians:90]  endAngle:[self DegreesToRadians:270] clockwise:NO];
    //    [polygonPath moveToPoint: CGPointMake(width/2-radius, height)];
    //    [polygonPath addLineToPoint: CGPointMake(0, height)];
    [polygonPath addLineToPoint: CGPointMake(0, 0)];
    
    
    
    
    
    
    
    
    
    [polygonPath closePath];
        [UIColor.grayColor setFill];
    [polygonPath fill];
    
    CAShapeLayer* maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = polygonPath.CGPath;
    view.layer.mask = maskLayer;
}


-(CGFloat) DegreesToRadians:(CGFloat )degrees
{
    return degrees * M_PI / 180;
};

-(CGFloat) RadiansToDegrees:(CGFloat) radians
{
    return radians * 180 / M_PI;
}
@end
