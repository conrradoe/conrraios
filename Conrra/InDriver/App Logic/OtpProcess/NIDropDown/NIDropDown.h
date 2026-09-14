//
//  NIDropDown.h
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebCallConstants.h"
#import "CityModel.h"
@class NIDropDown;
@protocol NIDropDownDelegate
//- (void) niDropDownDelegateMethod: (NIDropDown *) sender;
- (void) niDropDownDelegateMethod: (NIDropDown *) sender index:(int) index  result:(id) resullt;
@end

@interface NIDropDown : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSString *animationDirection;
    UIImageView *imgView;
    BOOL isFullScreen;
}
@property (nonatomic, retain) id <NIDropDownDelegate> delegate;
@property (nonatomic, retain) NSString *animationDirection;


@property (nonatomic, assign) BOOL isLeftAligin;
@property (nonatomic, assign) BOOL isShowCountryCode;
-(void)hideDropDown:(UIButton *)b;
- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction;
- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction view:(UIView *) view frame:(CGRect) frame up:(BOOL) isDown;
- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction view:(UIView *) view frame:(CGRect) frame up:(BOOL) isDown isLeftAligin:(BOOL) isLeftAligin;
- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction view:(UIView *) view frame:(CGRect) frame up:(BOOL) isDown isLeftAligin:(BOOL) isLeftAligin isShowCountryCode:(BOOL) isShowCountryCode;
-(void) updateFarame:(CGRect) rect;
@end
