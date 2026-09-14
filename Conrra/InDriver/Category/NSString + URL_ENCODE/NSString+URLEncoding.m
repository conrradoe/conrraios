//
//  NSString+URLEncoding.m
//  Shagatie
//
//  Created by Appicial Taxi App Soutions on 23/04/16.
//  Copyright © 2016 Appicial Taxi App Soutions. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding{
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];

    return (NSString*) [self stringByAddingPercentEncodingWithAllowedCharacters:set];
    
//    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
//                                                               (CFStringRef)self,
//                                                               NULL,
//                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
//                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
    
    
}

-(NSString *)urlDecodeUsingEncoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)self, CFSTR("")));
    
//    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(__bridge CFStringRef)self,CFSTR(""),kCFStringEncodingUTF8)
}

@end
