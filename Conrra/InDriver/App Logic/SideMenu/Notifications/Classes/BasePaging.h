//
//  BasePaging.h
//  TeamJoe
//
//  Created by Grepix Infotech on 25/12/17.
//  Copyright © 2023 ZappDesignTemplates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasePaging : NSObject
@property (assign,nonatomic) int limit;
@property (assign,nonatomic) int last_offset;
@property (assign,nonatomic) int next_offset;
@property (assign,nonatomic)BOOL isMoreData;
@property(strong, nonatomic) NSMutableArray * data;

-(void) addNewPageData:(NSMutableArray *) newData;
-(BOOL) checkIsMoreData;
-(void)  setPaggingData:(NSDictionary *) results;
-(NSMutableDictionary *) getDictApiForPage;
 @end
