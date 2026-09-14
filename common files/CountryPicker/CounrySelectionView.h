//
//  CounrySelectionView.h
//  Golden Moto
//
//  Created by Grepix - Baij on 07/01/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CounrySelectionView;
@protocol CounrySelectionViewDelegate <NSObject>

-(void) onCountrySelction:(NSDictionary *_Nullable) countryDict;
-(void) onCloseView;
@end
NS_ASSUME_NONNULL_BEGIN

@interface CounrySelectionView : UIView<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *viewSearchBg;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtSeach;
@property (strong, nonatomic)  UILabel *label;
@property (weak, nonatomic) id<CounrySelectionViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageCloseIcon;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
+(NSAttributedString *) getCurrentCountry;
+(NSAttributedString *) getCurrentCountryWithCountryCode :(NSString * )countryCode;
+(NSDictionary  *) getCurrentCountryDict;

+(NSDictionary  *) getCurrentCountryDictWithCountryCode :(NSString * )countryCode;
+(NSDictionary  *) getCurrentCountryDictWithIsoCode :(NSString * )isocode;
+(NSDictionary  *) getCurrentCountryDictWithDialCode :(NSString * )dialCode;
+(void)showCountrySelectionViewWithDelegate:(id<CounrySelectionViewDelegate>)delegate parentView:(UIView *)parentView label:(UILabel *) label;
/// Returns the emoji flag string for a two-letter ISO country code (e.g. "VE" → 🇻🇪).
+ (NSString *)flagEmojiForCode:(NSString *)code;


@end

NS_ASSUME_NONNULL_END
