//
//  DatePickerViewController.h
//  PrathiCabs
//
//  Created by Grepix on 29/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
@class DatePickerViewController;
@protocol DatePickerViewControllerDelegate <NSObject>

-(void) viewController:(DatePickerViewController *) datePicker dateSelected:(NSDate *)date;

@end
@interface DatePickerViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDateSuggest;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *viewDatePicker;
@property (strong, nonatomic)  NSString *titleText;
@property (strong, nonatomic)  NSDate *selectedDate;
@property(weak,nonatomic) id<DatePickerViewControllerDelegate>delegate;


@end

NS_ASSUME_NONNULL_END
