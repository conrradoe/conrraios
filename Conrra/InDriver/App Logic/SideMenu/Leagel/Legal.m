//
//  Legal.m

//
//  Created by Grepix - Baij on 01/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "Legal.h"

@implementation Legal

- (instancetype)initWithDict:(NSDictionary *) dict
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


+(NSMutableArray *) parseArray:(NSArray *)array
{
    NSMutableArray * arr=[[NSMutableArray alloc] init];
    if([array isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dict in array) {
             Legal *l1=[[Legal alloc] init];
            l1.title=[dict objectForKey:@"title"];
            l1.url=[dict objectForKey:@"url"];
            [arr addObject:l1];
            
        }

    }
    return  arr;
}
@end
