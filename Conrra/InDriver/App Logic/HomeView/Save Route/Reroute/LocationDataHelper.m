//
//  LocationDataHelper.m
//  LTS Driver
//
//  Created by Grepix on 15/03/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "LocationDataHelper.h"
#import "LocationData.h"

@implementation LocationDataHelper
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.array=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addObject:(CLLocation *)location  index:(int) index{
    BOOL isValidIndex=[self isValidIndex:index];
    if(isValidIndex){
        LocationData *data=[[LocationData alloc] init];
        data.location=location;
        data.index=index;
        data.isValid=YES;
        [self.array addObject:data];
        [self removeOldObject];
        self.inValidLocationCounter=0;
    }else{
        self.lastInValidIndex=index;
        self.inValidLocationCounter++;
        if(self.inValidLocationCounter>5){
//            [self.delegate  drawReRoute];
        }
    }
}


-(void)validIndexs{
//    if(self.array.count>0){
//        LocationData *locationData=[self.array lastObject];
//        if(index<locationData.index){
//
//        }
//    }
    if(self.array.count>5){
        self.inValidLocationCounter=0;
    }
//    for (int i=self.array.count in ) {
//        <#statements#>
//    }
}

-(void)removeOldObject{
    // need to implement other login for remove
    if(self.array.count>5){
        [self.array removeObjectAtIndex:0];
    }
}

-(void) removeOldObjectWhenReRoute{
    [self resetInValidData];
    [self.array removeAllObjects];
}

-(void) resetInValidData{
    self.inValidLocationCounter=0;
}

-(BOOL) isOnValidRoute{
    if(self.inValidLocationCounter>5){
        return NO;
    }
    // need to implement
    return YES;
}

-(BOOL) isValidIndex:(int) index{
    if(self.array.count>0){
        LocationData *locationData=[self.array lastObject];
        if(index<locationData.index){
            return NO;
        }
    }
    return YES;
}

-(int)lastValidIndex{
    if(self.array.count>0){
        LocationData *locationData=[self.array lastObject];
        return locationData.index;
    }
    return -1;
}
@end
