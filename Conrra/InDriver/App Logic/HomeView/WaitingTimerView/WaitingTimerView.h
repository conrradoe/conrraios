//
//  CategoryCell.h
//  DemoMap
//
//  Created by Devineer on 19/01/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryModel.h"
#import "DRCircularProgressView.h"

@protocol WaitingTimerViewDelegate <NSObject>

-(void)onTimeWaitCompleted;
-(void)onCancelButtonTap;

@end

@interface WaitingTimerView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *imgTrack;
@property (strong, nonatomic) IBOutlet UILabel *lblCategoryName;
@property (weak, nonatomic) IBOutlet UILabel *lblCatName;

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblEstmateTime;

@property (weak, nonatomic) IBOutlet UIView *viewDots;
@property(strong,nonatomic) CategoryModel *category;
@property(strong,nonatomic) CityModel *cityModel;
@property(strong,nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSDictionary *dictCustomiseOptions;
-(instancetype)initFromNib;
@property (weak, nonatomic) IBOutlet UILabel *lblCapcitySeat;
@property (weak, nonatomic) IBOutlet UIImageView *imageCate;
@property (weak, nonatomic) IBOutlet UIButton *btnFareInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblFareDiable;
@property (assign, nonatomic)  BOOL isSelectedLocal;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lbltime;
@property (unsafe_unretained, nonatomic) IBOutlet DRCircularProgressView *viewProgressTimer;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblCancelRide;
@property(weak,nonatomic)id<WaitingTimerViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageGif;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
-(void)setUpView:(NSString *) time;
-(void) stopTimer;
-(void) startLoading;
-(void) stopLoading;
@end
