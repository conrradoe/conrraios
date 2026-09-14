//
//  Legal.h

//
//  Created by Grepix - Baij on 01/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Legal : NSObject
@property (strong,nonatomic) NSString * title;
@property (strong,nonatomic) NSString * url;

- (instancetype)initWithDict:(NSDictionary *) dict;
+(NSMutableArray *) parseArray:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
