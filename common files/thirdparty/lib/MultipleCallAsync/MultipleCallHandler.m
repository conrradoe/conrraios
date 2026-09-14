//
//  MultipleCallHandler.m
//  LTS Rider
//
//  Created by Grepix on 01/03/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "MultipleCallHandler.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"

@implementation MultipleCallHandler
{
    NSMutableArray *arrayFailers;
    NSMutableArray *arraySuccess;
    int totalTask;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        totalTask=0;
        arrayFailers=[[NSMutableArray alloc] init];
        arraySuccess=[[NSMutableArray alloc] init];
    }
    return self;
}


-(void)addTask:(BOOL(^)(id result,NSError *error)) cBlock{
    
}

-(void)addTaskWith:(BOOL(^)(XYZSimpleBlock ablock) )cBlock {
    NSLog(@"start");
    BOOL isSuccess=cBlock(^{
        
    });
    NSLog(@"end %@",@(isSuccess));
}

-(void)addTaskWithCompleteBlock:(BOOL(^)(taskCompleteBlock blockAfterCompleteTask)) block{
    totalTask++;
    block(^(id result,NSError *error,NSString * type){
         if(result==nil){
             [self->arrayFailers addObject:@{@"error":error,@"type":type}];
         }else{
             [self->arraySuccess addObject:result];
         }
        [self checkAllTaskCompeleted];
    });
}


-(void) checkAllTaskCompeleted{
    if(totalTask==(self->arrayFailers.count+self->arraySuccess.count)){
        self.allBlock((int)self->arraySuccess.count, (int)self->arrayFailers.count, totalTask,arrayFailers);
    }
}

-(void)addAllTaskCompletedBlock:(allTaskCompleteBlock)cBlock{
    self.allBlock = cBlock;
}

-(void)start{
    [self checkAllTaskCompeleted];
}
@end
