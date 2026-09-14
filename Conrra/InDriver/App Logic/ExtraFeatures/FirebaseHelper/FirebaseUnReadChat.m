//
//  FirebaseUnReadChat.m
//  Golden Moto Driver
//
//  Created by Grepix - Baij on 23/07/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "FirebaseUnReadChat.h"

#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
@implementation FirebaseUnReadChat
{
    NSMutableArray *arrChatsCount;
}

- (instancetype)initWithChannId:(NSString *) channeId
{
    self = [super init];
    if (self) {
        self.channeId=channeId;
    }
    return self;
}
-(void)  startObserverForCount
{
    [self stopObserverForCount];
    [self homeChatCount];
}

-(void) stopObserverForCount
{
    self.handle_TripChat= 0;
    self.ref_TripChatCount=nil;
}

-(void) homeChatCount
{
    NSDictionary * dictUser=defaults_object(P_USER_DICT);
    NSString *fId= [dictUser objectForKey:P_FIRE_ID];
        arrChatsCount=[[NSMutableArray alloc] init];
        self.ref = [[FIRDatabase database] reference];
        self.ref_TripChatCount = [[self.ref child:@"Chats"] child:self.channeId];
        self.handle_TripChat = [[self.ref_TripChatCount queryLimitedToLast:1000] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
          
            if([snapshot.value isKindOfClass:[NSDictionary class]])
            {
                NSDictionary * value= snapshot.value;
                //                        is_read
//                if([[value objectForKey:@"isUser"] intValue]==1)
//                {
                NSString * from=[value objectForKey:@"from"];
                 if(![from isEqualToString:fId])
                 {
                    if([[value objectForKey:@"is_read"] intValue]==0)
                    {
                        [self->arrChatsCount addObject:snapshot];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"message_count_un_read"
                       object:nil];
//            self.lblUnReadMessageCount.text=[NSString stringWithFormat:@"%lu",(unsigned long)self->arrChatsCount.count];
        }];
        self.handle_TripChat = [[self.ref_TripChatCount queryLimitedToLast:1000] observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
            FIRDataSnapshot * shotRemove=nil;
            for (FIRDataSnapshot *shot in self->arrChatsCount) {
                
                if([shot.key  isEqualToString: snapshot.key])
                {
                    shotRemove =shot;
                }
            }
            if(shotRemove)
            {
                [self->arrChatsCount removeObject:shotRemove];
            }
            if([snapshot.value isKindOfClass:[NSDictionary class]])
            {
                NSDictionary * value= snapshot.value;
                //                        is_read'
//                if([[value objectForKey:@"isUser"] intValue]==1)
//                {
                NSString * from=[value objectForKey:@"from"];
                 if(![from isEqualToString:fId])
                 {
                if([[value objectForKey:@"is_read"] intValue]==0)
                    {
                        //                        count++;
                        [self->arrChatsCount addObject:snapshot];
                    }
                }
            }
            [[NSNotificationCenter defaultCenter]
            postNotificationName:@"message_count_un_read"
            object:nil];
        }];
}

-(int)messageCount
{
    return  (int)arrChatsCount.count;
}
-(NSString *)lastMessagText
{
    NSDictionary * dictUser=defaults_object(P_USER_DICT);
    NSString *fId= [dictUser objectForKey:P_FIRE_ID];
     if(arrChatsCount.count>0)
     {
         FIRDataSnapshot * snapshot= [arrChatsCount lastObject];
         if([snapshot.value isKindOfClass:[NSDictionary class]])
         {
             NSDictionary * value= snapshot.value;
             //                        is_read
//             if([[value objectForKey:@"isUser"] intValue]==1)
//             {
             NSString * from=[value objectForKey:@"from"];
              if(![from isEqualToString:fId])
              {
                 
                 if([[value objectForKey:@"is_read"] intValue]==0)
                 {
                     return [value objectForKey:@"text"];
                 }
             }
         }
     }
    return  @"";
}
@end
