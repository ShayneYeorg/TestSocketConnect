//
//  ShYSocketManager.m
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/21.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import "ShYSocketManager.h"

//虽然可能会有多个模块使用到ShYSocketManager，但是所有模块都是共用一个socket
//socket和这些模块是一对多的关系，所以使用通知来告知所有模块socket的连接状况
NSString * const SOCKET_DID_CONNECT    = @"SOCKET_DID_CONNECT";
NSString * const SOCKET_DID_DISCONNECT = @"SOCKET_DID_DISCONNECT";

@class ShYSocketManager;

static ShYSocketManager *socketManager;

@interface ShYSocketManager () <GCDAsyncSocketDelegate>

//由于可能会有多个模块使用到ShYSocketManager，每个模块都会有对应回调
//ShYSocketManager和这些回调是一对一的关系，所以使用Block
//由于有多组回调，所以使用Dic来存储各组回调，key是模块的tag
@property (nonatomic, strong) NSMutableDictionary *didSendMsgCallbacks;
@property (nonatomic, strong) NSMutableDictionary *didReceiveMsgCallbacks;

@property (nonatomic, strong) NSMutableDictionary *tagModuleContrast;

@end

@implementation ShYSocketManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.didSendMsgCallbacks = [NSMutableDictionary dictionary];
        self.didReceiveMsgCallbacks = [NSMutableDictionary dictionary];
        self.tagModuleContrast = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public

+ (ShYSocketManager *)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!socketManager) {
            socketManager = [[ShYSocketManager alloc] init];
        }
    });
    return socketManager;
}

- (BOOL)connectToHost:(NSString *)strAddr onPort:(NSString *)strPort error:(NSError **)errPtr {
    return [self.asyncSocket connectToHost:strAddr onPort:[strPort intValue] error:errPtr];
}

- (void)disconnect {
    [self.asyncSocket disconnect];
    self.tagModuleContrast = nil;
    self.didSendMsgCallbacks = nil;
    self.didReceiveMsgCallbacks = nil;
    
//    self.asyncSocket.delegate = nil;
//    self.asyncSocket = nil;
}

- (BOOL)isConnected {
    return [self.asyncSocket isConnected];
}

- (void)sendMessage:(NSDictionary *)messageDic tag:(long)tag {
    //保存好发送消息的tag和模块之间的对应关系
    NSString *tagStr = [NSString stringWithFormat:@"%ld", tag];
    if (!self.tagModuleContrast[tagStr] && messageDic[@"module"]) {
        [self.tagModuleContrast setObject:messageDic[@"module"] forKey:tagStr];
    }
    
    NSString *dataStr = [self jsonString:messageDic];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:data withTimeout:-1 tag:tag];
}

#pragma mark - SetUpCallbacks

- (void)setDidSendMessageCallback:(VoidBlock)sendMessageCallback module:(NSString *)moduleName {
    [self.didSendMsgCallbacks setObject:sendMessageCallback forKey:moduleName];
}

- (void)setDidReceiveMessageCallback:(BlockWithDictionary)receiveMessageCallback module:(NSString *)moduleName {
    [self.didReceiveMsgCallbacks setObject:receiveMessageCallback forKey:moduleName];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [[NSNotificationCenter defaultCenter]postNotificationName:SOCKET_DID_CONNECT object:nil userInfo:nil];
    NSLog(@"已连接: %@, 端口: %d", host, port);
    [sock readDataWithTimeout:-1 tag:1]; //这个tag不一定要与发送消息时的tag相同
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [[NSNotificationCenter defaultCenter]postNotificationName:SOCKET_DID_DISCONNECT object:nil userInfo:nil];
    NSLog(@"断开连接...%@", err.description);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (dic) {
        NSString *receiveModule = dic[@"module"];
        if (receiveModule && self.didReceiveMsgCallbacks[receiveModule]) {
            BlockWithDictionary callback = self.didReceiveMsgCallbacks[receiveModule];
            callback(dic);
        }
    }
    
    [sock readDataWithTimeout:-1 tag:tag];
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSString *tagStr = [NSString stringWithFormat:@"%ld", tag];
    if (self.tagModuleContrast[tagStr] && self.didSendMsgCallbacks[self.tagModuleContrast[tagStr]]) {
        VoidBlock callback = self.didSendMsgCallbacks[self.tagModuleContrast[tagStr]];
        callback();
    }
    NSLog(@"已发送Tag: %ld", tag);
    [sock readDataWithTimeout:-1 tag:tag];
}




- (NSString *)jsonString:(NSDictionary *)dicMsg {
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicMsg options:NSJSONWritingPrettyPrinted error:nil];
    if (jsonData) {
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return nil;
}

@end
