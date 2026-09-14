//
//  FirebaseUnReadChat.h
//  Golden Moto Driver
//
//  Created by Grepix - Baij on 23/07/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase.h>
NS_ASSUME_NONNULL_BEGIN

@interface FirebaseUnReadChat : NSObject
@property(strong,nonatomic) FIRDatabaseReference *ref;
@property(strong,nonatomic,nullable) FIRDatabaseReference *ref_TripChatCount;
@property(assign,nonatomic) FIRDatabaseHandle handle_TripChat;
@property(strong,nonatomic) NSString * channeId;

- (instancetype)initWithChannId:(NSString *) channeId;
-(void) startObserverForCount;
-(void)stopObserverForCount;

-(int) messageCount;
-(NSString *)lastMessagText;
@end

NS_ASSUME_NONNULL_END
