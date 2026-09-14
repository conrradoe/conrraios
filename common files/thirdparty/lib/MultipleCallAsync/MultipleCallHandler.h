//
//  MultipleCallHandler.h
//  LTS Rider
//
//  Created by Grepix on 01/03/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^XYZSimpleBlock)(void);
typedef void (^taskCompleteBlock)(id _Nullable result,NSError * _Nullable error, NSString * _Nullable type);

typedef void (^allTaskCompleteBlock)(int completed,int failed ,int total,NSArray * _Nullable  arrayFailure);

NS_ASSUME_NONNULL_BEGIN

@interface MultipleCallHandler : NSObject

@property (copy) void (^simpleBlock)( id result,NSError * error);
@property (strong ,nonatomic)allTaskCompleteBlock  allBlock;
//-(void)addTask:(BOOL(^)(id result,NSError *error)) cBlock;
//-(void)addTaskWith:(BOOL(^)(XYZSimpleBlock ablock)) cBlock;
-(void)addTaskWithCompleteBlock:(BOOL(^)(taskCompleteBlock blockAfterCompleteTask)) block;

-(void)addAllTaskCompletedBlock:(allTaskCompleteBlock)cBlock;
-(void)start;

@end

NS_ASSUME_NONNULL_END
