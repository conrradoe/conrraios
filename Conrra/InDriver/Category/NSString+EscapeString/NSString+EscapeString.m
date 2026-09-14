//
//  NSString+EscapeString.m
//  Frankly_App
//
//  Created by   on 17/04/14.
//  Copyright (c) 2013  . All rights reserved.
//

#import "NSString+EscapeString.h"

@implementation NSString (EscapeString)
+ (NSString*) GET_UN_ESCAPED_STRING:(NSString*) str
{
    CFStringRef escapedstring = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(CFStringRef)[NSString stringWithFormat:@"%@", str],(CFStringRef)@";'",kCFStringEncodingUTF8 );
    
    NSString *retStr = [[NSString alloc] initWithString:(__bridge NSString*) escapedstring];
    CFRelease(escapedstring);
    return retStr;
}

+ (NSString*) GET_ESCAPED_STRING:(NSString*) str
{
    CFStringRef escapedstring = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)[NSString stringWithFormat:@"%@", str],NULL,(CFStringRef)@";'",kCFStringEncodingUTF8);
    
    NSString *retStr = [[NSString alloc] initWithString:(__bridge NSString*) escapedstring];
    CFRelease(escapedstring);
    return retStr;
}

@end
