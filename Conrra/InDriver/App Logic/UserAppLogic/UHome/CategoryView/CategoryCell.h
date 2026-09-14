//
//  CategoryCell.h
//  DemoMap
//
//  Created by Devineer on 19/01/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  CategoryCell;
@protocol CategoryCellDelegate <NSObject>

-(void)onFareInfoButtonTaped:(CategoryCell*)cell;

@end

@interface CategoryCell : UIView
@property (strong, nonatomic) IBOutlet UIImageView *imgTrack;
@property (strong, nonatomic) IBOutlet UILabel *lblCategoryName;
@property (weak, nonatomic) IBOutlet UIButton *btnFareInfo;
@property (weak, nonatomic) id<CategoryCellDelegate> deleate;
@property (assign, nonatomic) int indexFareinfo ;
-(instancetype)initFromNib;
@end
