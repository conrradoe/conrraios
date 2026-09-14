//
//  FireBaseModel.h
//  GrepixChat
//
//  Created by Prashant on 28/12/17.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase.h>

typedef void(^fireBaseCompletion)(id result, NSError *error);

@interface FireBaseModel : NSObject

/**
 This is main Firebase DB reference
 */
@property(strong,nonatomic) FIRDatabaseReference *ref;

/**
 This is your trip id
 */
@property(strong,nonatomic) NSString *channelId;

/**
 Unread Message Count
 */
@property(strong,nonatomic) NSString *unReadMessageCount;

/**
 Tells if KVO is set on "unReadMessageCount" property
 */
@property (nonatomic,readonly) BOOL isKeyValueSet;

/**
 Initialze this when you are going for chat
 */
-(instancetype)initFirebaseWithChannelID:(NSString *)channelID;

/**
 Create room when trip is accepted by driver
 */
//+(void)createRoomWithData:(NSDictionary *)dict withCompletion:(fireBaseCompletion)block;

-(void)getAllChatsValueChangeWithCompletion:(fireBaseCompletion)block;
/**
 Get all chats in a room
 */
-(void)getAllChatsWithCompletion:(fireBaseCompletion)block;

/**
 Send a chat message in room
 */
-(void)sendChat:(NSDictionary *)chatData withCompletion:(fireBaseCompletion)block;

-(void)makerRead:(NSDictionary *)chatData key:(NSString *) key withCompletion:(fireBaseCompletion)block;
/**
 Register for Notification
 */
//-(void)registerForChatNotifications:(BOOL)toGetNotification;


///**
// Check and then Save FCM Token to Firebase
// */
//+(void)checkAndSendFCMToken:(NSString *)fcmToken;
//
//
///**
// Directly save FCM Token to Firebase
// */
//+(void)sendFCMTokenToFirebase:(NSString*)fcmToken;

/**
 Remove firebase observer when leaving chat
 */
-(void)removeMessageVCObservers;

/**
 Remove total chat observer
 */
-(void)removeTotalChatObservers;

/**
 Get User unread count of chats
 */
-(void)getUnreadChatCount;

/**
 Update user total read count
 */
-(void)updateUserTotalReadCount;

/**
 Load previous chats
 */
-(void)loadPreviousChatsWithKey:(NSString*)firstKey withCompletionBlock:(fireBaseCompletion)block;


/**
 Set isKVOProperty
 */
-(void)setKVOProperty:(BOOL)isSet;

-(void) updateDriverFireId:(NSString *) driverFireId;
-(void) updateRiderFireId:(NSString *) riderFireId;
@end
