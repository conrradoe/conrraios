//
//  FireBaseModel.m
//  GrepixChat
//
//  Created by Prashant on 28/12/17.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "FireBaseModel.h"
#import <GIKit/GIKit.h>
#import "AppDelegate.h"
#import "WebCallConstants.h"

#define K_MESSAGES_PER_PAGE 15

@interface FireBaseModel()
{
    NSString *readCountForUser,*unReadCount;
    NSTimer *timerMV, *timerTS;
}

//ref
@property (strong, nonatomic) FIRDatabaseReference *ref_TripChat;
//@property (strong, nonatomic) FIRDatabaseReference *ref_typingIndicator;

//handle
@property (nonatomic) FIRDatabaseHandle handle_TripChat;

//// temp
//@property (strong,nonatomic) FIRDatabaseReference *totalChatCountRef;
//@property (strong, nonatomic) FIRDatabaseReference *userReadCountRef;
@property (nonatomic) FIRDatabaseHandle totalChatCountHandle;
@property (nonatomic) FIRDatabaseHandle userReadCountHandle;

@property (nonatomic,readwrite,assign) BOOL isKeyValueSet;

@end

@implementation FireBaseModel

-(instancetype)initFirebaseWithChannelID:(NSString *)channelID{
    
    self = [super init];
    if (self) {
        self.ref = [[FIRDatabase database] reference];
        self.channelId = channelID;
        self.ref_TripChat = [[self.ref child:@"Chats"] child:self.channelId];
        
//        [[[self.ref child:@"Chats"] child:self.channelId] childByAutoId] setValue:@"adriver_abcd" forKey:P_DRIVER_ID];
        //temp
//        self.totalChatCountRef = [[[self.ref child:@"Rooms"] child:self.channelId] child:@"totalChats"]; // ===> to check this ref
//        NSDictionary *userDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
//        NSString *userid = [userDict  objectForKey:P_DRIVER_ID];
//        self.userReadCountRef = [[[self.ref child:@"Users_Read_Count"] child:self.channelId] child:userid];
    }
    return self;
}

-(void) updateDriverFireId:(NSString *) driverFireId{
//    [[[[self.ref child:@"Chats"] child:self.channelId] child:P_DRIVER_ID] setValue:driverFireId withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//    }];
}


-(void) updateRiderFireId:(NSString *) riderFireId{
//    [[[[self.ref child:@"Chats"] child:self.channelId] child:P_DRIVER_ID] setValue:riderFireId withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//    }];
}


#pragma mark - Update user read count
-(void)updateUserTotalReadCount{
//    [[[[_ref child:@"Rooms"] child:self.channelId] child:@"totalChats"] removeObserverWithHandle:_totalChatCountHandle];
//
//    _totalChatCountHandle = [_totalChatCountRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        FIRDataSnapshot *child = snapshot;
//
//
//        if (![child.value isKindOfClass:[NSNull class]]) {
//
//            self->readCountForUser = [NSString stringWithFormat:@"%@",child.value] ;
//            //*** postpone this call by timer
//            [self invalidate_MVC_TimerAndStart:YES];
//
//            //[_userChatCountRef setValue:child.value];
//        }
//        else {
//            [self.userReadCountRef setValue:[NSNumber numberWithInt:0]];
//        }
//    }];
}
-(void)updateReadCount{
//    [_userReadCountRef setValue: readCountForUser];
}

-(void)invalidate_MVC_TimerAndStart:(BOOL)toStart{
    if ([timerMV isValid]) {
        [timerMV invalidate];
        timerMV = nil;
    }
    if (toStart) {
        timerMV = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(updateReadCount) userInfo:nil repeats:NO];
    }
}


#pragma mark - Get Unread Msg Count

-(void)getUnreadChatCount{
    
    
//    //[[[[_ref child:@"Channels"] child:self.channelId] child:@"totalChats"] removeObserverWithHandle:_team_chatCountHandle];
//
//    _totalChatCountHandle = [_totalChatCountRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        FIRDataSnapshot *child = snapshot;
//        //self.lblMessageCounter.text = [NSString stringWithFormat:@"%@",child.value];
//
//        if (![child.value isKindOfClass:[NSNull class]]) {
//            [self getUserReadCount:[child.value intValue]];
//        }
//        else {
//            /*
//             self.lblMessageCounter.text = [NSString stringWithFormat:@"%d",0];
//             [self.lblMessageCounter setHidden:YES];
//             */
//        }
//    }];
}

-(void)makerRead:(NSDictionary *)chatData key:(NSString *) key withCompletion:(fireBaseCompletion)block{
    [[[[[self.ref child:@"Chats"] child:self.channelId] child:key] child:@"is_read"] setValue:[NSNumber numberWithBool:YES] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        block(ref,error);
    }];
}

-(void)getUserReadCount:(NSUInteger)totalChats{
    
//    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
//    NSString *userid = [userDict  objectForKey:P_DRIVER_ID];
//
//    ///////////// * user CHAT COUNT
//    [[[[_ref child:@"Users_Read_Count"] child:self.channelId] child:userid] removeObserverWithHandle:_userReadCountHandle];
//
//    _userReadCountHandle = [_userReadCountRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
//
//        FIRDataSnapshot *child = snapshot;
//
//        //[[[[_ref child:@"Users"] child:self.channelId] child:[[APP_DELEGATE dictUser]objectForKey:p_u_fire_id] ]removeObserverWithHandle:_readCountHandle];
//
//        if (![child.value isKindOfClass:[NSNull class]]) {
//
//            self->unReadCount = [NSString stringWithFormat:@"%lu",totalChats - [child.value intValue]];
//        }
//        else {
//            self->unReadCount = [NSString stringWithFormat:@"%ld",(unsigned long)totalChats];
//        }
//
//        [self invalidate_TS_TimerAndStart:YES];
//
//    }];
}

-(void)updateUnReadCount{
    
    if ([unReadCount intValue]>=10) {
        unReadCount = @"9+";
    }
//    [self setValue:unReadCount forKey:@"unReadMessageCount"];     //////////   <<<======================================
    //remove observer for Message VC here if any
    //[self removeMessageVCObservers];
}

-(void)invalidate_TS_TimerAndStart:(BOOL)toStart{
    if ([timerTS isValid]) {
        [timerTS invalidate];
        timerTS = nil;
    }
    if (toStart) {
        timerTS = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateUnReadCount) userInfo:nil repeats:NO];
    }
}


#pragma mark - KVO Enabled helper

-(void)setKVOProperty:(BOOL)isSet {
    self.isKeyValueSet = isSet;
}


- (void)configureDatabase {
    
    
//    FIRDatabaseReference *ref_typing = [[[_ref child:@"Rooms"] child:self.channelId] child:@"typingIndicator"];
//
//    self.ref_typingIndicator = [ref_typing child:[[APP_DELEGATE dictUser] objectForKey:p_u_fire_id]];
//    [_userTypingRef onDisconnectRemoveValue];
//
//    //_userTypingQuery = [[_typingIndicatorRef queryOrderedByValue] queryEqualToValue:[NSNumber numberWithBool:YES]];
//
//
//    typingQueryHandle =[_userTypingQuery observeEventType:(FIRDataEventType)FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//
//        NSEnumerator *enumerator = [[NSEnumerator alloc] init];
//        enumerator = snapshot.children;
//        if(snapshot.childrenCount>0){
//
//            if (snapshot.childrenCount==1) {
//                FIRDataSnapshot *user = [snapshot.children.allObjects firstObject];
//                if (user.key == [[APP_DELEGATE dictUser]objectForKey:p_u_fire_id]) {
//                    //self.lblHeaderTitle.text = @"No typing";
//                }
//                else {
//                    //self.lblHeaderTitle.text = @"user typing";
//                }
//
//            }
//            else {
//                //self.lblHeaderTitle.text = @"user typing";
//            }
//        }
//        else {
//            //self.lblHeaderTitle.text = @"No typing";
//        }
//        //        if (snapshot.childrenCount==1 && localTyping == YES) {
//        //            return ;
//        //        }
//
//        //self.lblHeaderTitle.text = snapshot.childrenCount>0 ? @"user typing" : @"No typing";
//
//    }];
    
}

//+(void)createRoomWithData:(NSDictionary *)dict withCompletion:(fireBaseCompletion)block{
//    
//    //TODO: Put this in Request VC
//    
//    NSDictionary *channelDict = @{
//                                  @"driverID" : [dict objectForKey:@"driverID"],
//                                  @"userID" : [dict objectForKey:@"userID"],
//                                  };
//    
//    [self notificationSetup:dict];
//    
//    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
//    
//    [[[ref child:@"Rooms"] child:[dict objectForKey:@"roomID"]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//        
//        if ([snapshot exists]) {
//            // room already created
//        }
//        else {
//            //create room
//            [[[ref child:@"Rooms"] child:[dict objectForKey:@"roomID"]] setValue:channelDict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//                
//                if (error == nil) {
//                    block(ref,nil);
//                }
//                else {
//                    //group not created ==> show error
//                    NSError *error = [NSError errorWithDomain:@"error" code:200 userInfo:nil];
//                    block(nil,error);
//                }
//            }];
//        }
//        
//    }];
//}

//#pragma mark - Chat Notifications
//+(void)notificationSetup:(NSDictionary *)roomDict{
//    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
//    NSMutableDictionary *dictUserID = [[NSMutableDictionary alloc] init];
//    [dictUserID setObject:[NSNumber numberWithBool:YES] forKey:[roomDict objectForKey:@"userID"]];
//    [dictUserID setObject:[NSNumber numberWithBool:YES] forKey:[roomDict objectForKey:@"driverID"]];
//    [[[ref child:@"Room_Tokens"] child:[roomDict objectForKey:@"roomID"]] setValue:dictUserID];
//}


//-(void)registerForChatNotifications:(BOOL)toGetNotification{
//    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
//    NSString *userid = [userDict  objectForKey:P_FIRE_ID];
//    [[[[self.ref child:@"Room_Tokens"] child:self.channelId] child:userid] setValue:[NSNumber numberWithBool:toGetNotification]] ;
//}

#pragma mark -

-(void)getAllChatsWithCompletion:(fireBaseCompletion)block{
    self.handle_TripChat = [[self.ref_TripChat queryLimitedToLast:K_MESSAGES_PER_PAGE] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        block(snapshot,nil);
    }];
}

-(void)getAllChatsValueChangeWithCompletion:(fireBaseCompletion)block{
    self.handle_TripChat = [[self.ref_TripChat queryLimitedToLast:K_MESSAGES_PER_PAGE] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        block(snapshot,nil);
    }];
}
-(void)loadPreviousChatsWithKey:(NSString *)firstKey withCompletionBlock:(fireBaseCompletion)block{
    // dummy key = @"-L1X2KzxMtppXHcfYo4x"
    
    //AppDelegate *delegate = APP_DELEGATE;
    // Paging started
    [[[[[[_ref child:@"Chats"] child:self.channelId] queryOrderedByKey] queryLimitedToLast:K_MESSAGES_PER_PAGE + 1] queryEndingAtValue:firstKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            block(snapshot,nil);
        }
    }];
    
}

-(void)sendChat:(NSDictionary *)chatData withCompletion:(fireBaseCompletion)block{

    
    [[[[self.ref child:@"Chats"] child:self.channelId] childByAutoId] setValue:chatData withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error == nil) {
            
//            [self.ref_typingIndicator setValue:[NSNumber numberWithBool:NO]];
            //[self scrollToBottom_animated:YES];
            block(ref,nil);
            
        }
        else {
            //chat not updated in group ==> show error
            NSError *error = [NSError errorWithDomain:@"error" code:200 userInfo:nil];
            block(nil,error);
        }
    }];
}

//
//#pragma mark - Token update
//+(void)checkAndSendFCMToken:(NSString *)fcmToken{
//
//
//    if(fcmToken.length > 0){
//
//        if (defaults_object(@"FCMToken")) {
//
//            defaults_set_object(@"FCMToken", @"123");
//            //check if same
//            NSString *oldToken = defaults_object(@"FCMToken");
//
//            if (![oldToken isEqualToString:[FIRMessaging messaging].FCMToken]) {
//                [self sendFCMTokenToFirebase:fcmToken];
//            }
//        }
//        else {
//            [self sendFCMTokenToFirebase:fcmToken];
//        }
//    }
//}
//
//+(void)sendFCMTokenToFirebase:(NSString*)fcmToken{
//
//    //save it to firebase
//    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
//    NSString *userid = [NSString stringWithFormat:@"%d",[[userDict  objectForKey:P_DRIVER_ID] intValue]];
//    FIRDatabaseReference *databaseRef = [[FIRDatabase database] reference];
//    [[[databaseRef child:@"User-Tokens"] child: userid] setValue:fcmToken withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
//
//        if(error==nil) //fcm token updated
//        {
//            defaults_set_object(@"FCMToken", fcmToken);
//        }
//    }];
//}

#pragma mark - Removing observers

-(void)removeTotalChatObservers{
//    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
//    NSString *userid = [userDict  objectForKey:P_DRIVER_ID];
//    [[[[_ref child:@"Users_Read_Count"] child:self.channelId] child:userid] removeAllObservers];
//    [[[[_ref child:@"Rooms"] child:self.channelId] child:@"totalChats"] removeAllObservers];
}

-(void)removeMessageVCObservers{
//    [[[[_ref child:@"Rooms"] child:self.channelId] child:@"totalChats"] removeAllObservers];
//    [[[_ref child:@"Chats"] child:self.channelId] removeObserverWithHandle:_handle_TripChat];//removeObserverWithHandle:_msg_chatCountHandle];
}

@end
