//
//  BasePaging.m
//  TeamJoe
//
//  Created by Grepix Infotech on 25/12/17.
//  Copyright © 2023 ZappDesignTemplates. All rights reserved.
//

#import "BasePaging.h"

@implementation BasePaging

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.limit=5;
        self.last_offset=0;
        self.next_offset=0;
        self.isMoreData=YES;
        self.data=[[NSMutableArray alloc]  init];
    }
    return self;
}

-(BOOL) checkIsMoreData
{
    if(self.next_offset<self.last_offset)
    {
        self.next_offset=self.last_offset;
        self.isMoreData=NO;
    }
    return self.isMoreData;
}

-(void)setPaggingData:(NSDictionary *)results
{
    self.last_offset=[[results objectForKey:@"last_offset"]  intValue];
    self.next_offset=[[results objectForKey:@"next_offset"]  intValue];
    [self checkIsMoreData];
}
-(void)addNewPageData:(NSMutableArray *)newData
{
    [self.data addObjectsFromArray:newData];
}

-(NSMutableDictionary *) getDictApiForPage
{
    NSMutableDictionary * dict=[[NSMutableDictionary alloc]  init];
    [dict setObject:@(self.limit) forKey:@"limit"];
    [dict setObject:@(self.next_offset) forKey:@"offset"];
    return dict;
}
@end
