//
//  ShYSocketManager.h
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/21.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

extern NSString * const MODULE;
extern NSString * const OPERATION;

extern NSString * const OPERATION_ONLINE;
extern NSString * const OPERATION_OFFLINE;
extern NSString * const OPERATION_CHAT;

extern NSString * const SOCKET_DID_CONNECT;
extern NSString * const SOCKET_DID_DISCONNECT;

typedef void (^VoidBlock)();
typedef void (^BlockWithDictionary)(NSDictionary *dic);

@interface ShYSocketManager : NSObject

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

+ (ShYSocketManager *)share;

- (BOOL)connectToHost:(NSString *)strAddr onPort:(NSString *)strPort error:(NSError **)errPtr;
- (void)disconnect;
- (BOOL)isConnected;

- (void)sendMessage:(NSDictionary *)messageDic tag:(long)tag;

- (void)setDidSendMessageCallback:(VoidBlock)sendMessageCallback module:(NSString *)moduleName;
- (void)setDidReceiveMessageCallback:(BlockWithDictionary)receiveMessageCallback module:(NSString *)moduleName;

@end
