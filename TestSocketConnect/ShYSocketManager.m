//
//  ShYSocketManager.m
//  TestSocketConnect
//
//  Created by 杨淳引 on 16/9/21.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import "ShYSocketManager.h"

@class ShYSocketManager;

static ShYSocketManager *socketManager;

@interface ShYSocketManager () <GCDAsyncSocketDelegate>

@end

@implementation ShYSocketManager

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
    self.asyncSocket.delegate = nil;
    self.asyncSocket = nil;
}

- (BOOL)isConnected {
    return [self.asyncSocket isConnected];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

@end
