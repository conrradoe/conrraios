//
//  SuggestedLocationDataSource.h
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 12/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LanguageHelper.h"

@class  SuggestedLocationDataSource;
@protocol SuggestedLocationDataSourceDelegate <NSObject>

//-(void) onSelectLocation:(NSDictionary * )dictLocation;
//-(void) onAddressStartEditing;
//-(void) onAddressEndEditing;

-(void) source:(SuggestedLocationDataSource *) soure onSelectLocation:(NSDictionary * )dictLocation;
-(void)   onAddressStartEditingsource:(SuggestedLocationDataSource *) soure;
-(void)  onAddressEndEditingsource:(SuggestedLocationDataSource *) soure;
-(void)  onAddressShouldClear:(SuggestedLocationDataSource *) soure;

-(void)  onAddressEmptyShouldClear:(SuggestedLocationDataSource *) soure;
@end

@interface SuggestedLocationDataSource : NSObject<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>


@property(strong ,nonatomic)UITableView * tablview;
@property(strong ,nonatomic) UITextField *textField;
@property(weak ,nonatomic)id<SuggestedLocationDataSourceDelegate> delegate;

@property(strong ,nonatomic) NSDictionary *dictLocationSelected;
-(instancetype)initWithTableView:(UITableView *) tableView textFiled:(UITextField *) textField;

-(void) clearDataOfSuggestion;

@end
