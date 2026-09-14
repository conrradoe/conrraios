//
//  NSString+UnicodeUtilities.h
//  Application
//
//  Created by Appicial Taxi App Soutions on 21/05/14.
//  Copyright (c) 2014 Appicial Taxi App Soutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UnicodeUtilities)
+ (NSString*) unescapeUnicodeString:(NSString*)string;
+ (NSString*) escapeUnicodeString:(NSString*)string;

@end
