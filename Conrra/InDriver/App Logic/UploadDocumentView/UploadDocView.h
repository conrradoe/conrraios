//
//  UploadDocView.h

//
//  Created by Grepix - Baij on 07/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NIDropDown.h"
#import "UIImagePickerController+Extension.h"
NS_ASSUME_NONNULL_BEGIN
@class UploadDocView;
@protocol UploadDocViewDelegate <NSObject>

-(void)  docUploadView:(UploadDocView *)docUploadView  startUploadDoc:(NSString *) status;
-(void)  docUploadView:(UploadDocView *)docUploadView  dateSelect:(NSDate *) date;
-(UIView *) getParentView;
@end
@interface UploadDocView : UIView<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
- (instancetype)initWithView:(UIView *)view frame:(CGRect) frame dict:(NSDictionary *) dict;
@property(weak, nonatomic) id <UploadDocViewDelegate> delegate;
@property(strong, nonatomic)NSDictionary * dict;
@property(strong, nonatomic) UITextField * textField;
@property(strong, nonatomic) NSDate * selectedDate;
@property(weak, nonatomic) UIViewController * viewController;
-(void) uploadDocuments:(UIImage *) resizeImage;

-(void) handleDocsData:(NSArray * )array;
-(int) getCalculatedHeight;
-(NSDictionary *) validateDocsData;
@end

NS_ASSUME_NONNULL_END
