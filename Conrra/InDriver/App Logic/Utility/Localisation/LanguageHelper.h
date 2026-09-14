//
//  LanguageHelper.h

//
//  Created by Grepix - Baij on 27/01/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "LanguageHelper.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface LanguageHelper : NSObject

@property(strong,nonatomic)NSString * cunnrentLanguage;
+ (instancetype)sharedInstance;
-(NSArray *) getLanguageList;
-(void) getLanguageFromServerWithCompletionBlock:(void (^)(id results, NSError *error)) block;
-(NSString *) getStringWithKey:(NSString *) key currentLanguage:(NSString * ) language;
-(NSString *) getStringWithKey:(NSString *) key currentLanguage:(NSString * ) language defaultValue:(NSString*) defaultValue;
+(NSString *) getStringWithKey:(NSString *) key;
+(NSString *) getStringWithKey:(NSString *) key defaultValue:(NSString*) defaultValue;
+(NSString *) loginScreenTitle;
-(void) configureLanguage;
-(void) setLanguageListData:(NSArray *)array;
-(NSString *) getlcidForCode:(NSString*)code;
+(NSString *) getlcidCurrent;
@end

NS_ASSUME_NONNULL_END
