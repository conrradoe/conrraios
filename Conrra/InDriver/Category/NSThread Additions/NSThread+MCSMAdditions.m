//
//  NSThread+MCSMAdditions.m
//  MCSMFoundation
//
//  Created by Spencer MacDonald on 06/07/2011.
//  Copyright 2011 Square Bracket Software. All rights reserved.
//

#import "NSThread+MCSMAdditions.h"

@implementation NSThread (MCSMAdditions)
+ (void)MCSM_performBlockOnMainThread:(void (^)(void))block{
	[[NSThread mainThread] MCSM_performBlock:block];
}

+ (void)MCSM_performBlockInBackground:(void (^)(void))block{
	[NSThread performSelectorInBackground:@selector(MCSM_runBlock:)
                               withObject:[[block copy] autorelease]];
}

+ (void)MCSM_runBlock:(void (^)(void))block{
	block();
}


- (void)MCSM_performBlock:(void (^)(void))block{
    
	if ([[NSThread currentThread] isEqual:self])
        block();
	else
        [self MCSM_performBlock:block waitUntilDone:NO];
}
- (void)MCSM_performBlock:(void (^)(void))block waitUntilDone:(BOOL)wait{
    
	[NSThread performSelector:@selector(MCSM_runBlock:)
					 onThread:self
				   withObject:[[block copy] autorelease]
				waitUntilDone:wait];
}

- (void)MCSM_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay{
    
	[self performSelector:@selector(MCSM_performBlock:) 
			   withObject:[[block copy] autorelease] 
               afterDelay:delay];
}

@end
