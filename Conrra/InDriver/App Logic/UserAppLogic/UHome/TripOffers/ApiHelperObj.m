//
//  ApiHelperObj.m
//  TruckPager
//
//  Created by Grepix on 28/10/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "ApiHelperObj.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "Utilities.h"
@implementation ApiHelperObj


- (void) mkwerwus:(NSString*)apu
           d:(NSDictionary*)d
               cb:(void (^)(id _Nullable results, NSError * _Nullable error)) b{
    [GIC mkwerwu:apu d:d cb:^(id  _Nonnull results, NSError * _Nonnull error) {
        if(results!=nil){
            b(results,error);
        }else{
            b(nil,error);
        }
    }];
    
}
@end
