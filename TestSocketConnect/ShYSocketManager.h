//
//  ShYSocketManager.h
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/21.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface ShYSocketManager : NSObject

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

+ (ShYSocketManager *)share;

- (BOOL)connectToHost:(NSString *)strAddr onPort:(NSString *)strPort error:(NSError **)errPtr;
- (void)disconnect;
- (BOOL)isConnected;

- (void)sendMessage:(NSString *) tag:(NSString *)tag;

@end
